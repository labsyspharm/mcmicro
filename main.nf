#!/usr/bin/env nextflow

// Variable naming conventions
// path_* - directories
//   fn_* - filenames
//  cls_* - closures (functions)

// Expecting params
// .in - location of the data

// Default parameters
params.sample_name   = file(params.in).name
params.tools         = "$HOME/mcmicro"
params.illum         = false    // whether to run ImageJ+BaSiC
params.tma           = false    // whether to run Coreograph
params.'skip-ashlar' = false    // whether to skip ASHLAR

// Define paths to tools inside the containers
// NOTE: These values are overwritten by nextflow.config for O2
params.tool_imagej  = '/opt/fiji/Fiji.app'
params.tool_illum   = '/opt/fiji'
params.tool_core    = "${params.tools}/Coreograph"
params.tool_unmicst = '/app'
params.tool_segment = '/app'
params.tool_quant   = '/app' 

// Define all subdirectories
path_raw   = "${params.in}/raw_images"
path_qc    = "${params.in}/qc"
path_ilp   = "${params.in}/illumination_profiles"
path_rg    = "${params.in}/registration"
path_dr    = "${params.in}/dearray"
path_prob  = "${params.in}/prob_maps"
path_seg   = "${params.in}/segmentation"
path_quant = "${params.in}/quantification"

// Define closures / functions
//   Filename from full path: {/path/to/file.ext -> file.ext}
cls_base = { fn -> file(fn).name }

//   Channel from path p if cond is true, empty channel if false
cls_ch = { cond, p -> cond ? Channel.fromPath(p) : Channel.empty() }

//   Extract image ID from filename
cls_tok = { x, sep -> x.toString().tokenize(sep).get(0) }
cls_id  = { fn -> cls_tok(cls_tok(fn,'.'),'_') }
cls_fid = { file -> tuple(cls_id(file.getBaseName()), file) }

// Find raw images; feed them into separate channels for
//   illumination (raw1) and ASHLAR (raw2)
formats = '{.ome.tiff,.ome.tif,.rcpnl,.xdce,.nd,.scan,.htd}'
Channel.fromPath( "${path_raw}/**${formats}" ).into{ raw1; raw2 }
Channel.fromPath( "${params.in}/markers.csv" ).set{ chNames }

// If we're not running illumination, find illumination profiles
predfp = cls_ch( !params.illum, "${path_ilp}/*-dfp.tif" )
preffp = cls_ch( !params.illum, "${path_ilp}/*-ffp.tif" )

// If we're not running ASHLAR, find the pre-stitched image
fn_stitched = "${params.sample_name}.ome.tif"
prestitched = cls_ch( params.'skip-ashlar', "${path_rg}/*.ome.tif" )

// Illumination profiles
process illumination {
    publishDir path_ilp, mode: 'copy'
    
    input:
    file raw1

    output:
    file '*-dfp.tif' into compdfp
    file '*-ffp.tif' into compffp

    when:
    params.illum

    script:
    def xpn = file(raw1).name.tokenize(".").get(0)
    """
    ${params.tool_imagej}/ImageJ-linux64 --ij2 --headless \
      --run ${params.tool_illum}/imagej_basic_ashlar.py \
      "filename='${raw1}',output_dir='.',experiment_name='${xpn}'"
    """
}

// Mix mutually-exclusive channels (dependent on params.illum)
compdfp.mix( predfp ).set{ dfp }
compffp.mix( preffp ).set{ ffp }

// Stitching and registration
process ashlar {
    publishDir path_rg, mode: 'copy'
    
    input:
    file lraw from raw2.toSortedList()
    file lffp from ffp.ifEmpty{ file('EMPTY1') }.toSortedList()
    file ldfp from dfp.ifEmpty{ file('EMPTY2') }.toSortedList()

    output:
    file "${fn_stitched}" into stitched

    when:
    !params.'skip-ashlar'

    script:
    def ilp = ( lffp.name == 'EMPTY1' | ldfp.name == 'EMPTY2' ) ?
	"" : "--ffp $lffp --dfp $ldfp"
    """
    ashlar $lraw -m 30 --pyramid $ilp -f ${fn_stitched}
    """
}

// Mix mutually-exclusive channels (dependent on params.skip-ashlar)
// Forward the result to channel tma or tissue based on params.tma flag
stitched
    .mix( prestitched )
    .branch {
      tissue: !params.tma
      tma: params.tma
    }
    .set {img}

// De-arraying (if TMA)
process dearray {
    publishDir path_qc, mode: 'copy', pattern: 'TMA_MAP.tif'
    publishDir path_dr, mode: 'copy'

    // Mix mutually-exclusive channels (dependent on params.skip-ashlar)
    input:
    file s from img.tma
    
    output:
    file "**{,[A-Z],[A-Z][A-Z]}{[0-9],[0-9][0-9]}.tif" into cores
    file "**_mask.tif" into masks
    file "TMA_MAP.tif" into tmamap

    when:
    params.tma

    """
    matlab -nodesktop -nosplash -r \
    "addpath(genpath('${params.tool_core}')); \
     tmaDearray('./$s','outputPath','.','useGrid','false'); exit"
    """
}

// Collapse the earlier branching between full-tissue and TMA into
//   a single (core, mask) imgs channel for all downstream processing
if( params.tma ) {
    // Match up cores and masks by filename
    cores.flatten().map(cls_fid).set{ id_cores }
    masks.flatten().map(cls_fid).set{ id_masks }
    imgs = id_cores.join( id_masks ).map{ id, c, m -> tuple(c, m) }
}
else
    imgs = img.tissue.map{ x -> tuple(x, file('NO_MASK')) }

// UNet classification
process unmicst {
    publishDir path_prob, mode: 'copy', pattern: '*PM*.tif'

    input:
    tuple file(core), val(mask) from imgs

    output:
    tuple file(core), val(mask),
      file('*Nuclei*.tif'), file('*Contours*.tif') into prob_maps

    """
    python ${params.tool_unmicst}/UnMicst.py $core --outputPath .
    """
}

// Segmentation
process s3seg {
    publishDir path_seg, mode: 'copy', pattern: '*/*'

    input:
    tuple file(core), file(mask), file(pmn), file(pmc) from prob_maps

    output:
    // tuples for quantification
    tuple file(core), file('**cellMask.tif') into seg_qty
    // rest of the files for publishDir
    file '**' into seg_rest

    script:
    def crop = params.tma ? 'dearray' : 'noCrop'
    """
    python ${params.tool_segment}/S3segmenter.py --crop $crop \
       --imagePath $core \
       --maskPath $mask \
       --nucleiClassProbPath $pmn \
       --contoursClassProbPath $pmc \
       --outputPath .
    """
}

// Add channel name file to every (image, mask) tuple
to_qty = seg_qty.combine(chNames)

// Quantification
process quantification {
    publishDir path_quant, mode: 'copy', pattern: '*.csv'
    input:
    tuple file(core), file(mask), file(ch) from to_qty
    output:
    file '**' into quantified
    """
    python ${params.tool_quant}/CommandSingleCellExtraction.py \
    --mask $mask --image $core \
    --output . --channel_names $ch
    """
}

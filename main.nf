#!/usr/bin/env nextflow

// Expecting params
// .in - location of the data

// Default parameters for the pipeline as a whole
params.sample_name   = file(params.in).name
params.illum         = false    // whether to run ImageJ+BaSiC
params.tma           = false    // whether to run Coreograph
params.skipAshlar    = false    // whether to skip ASHLAR

// Default selection of methods for each step
params.probabilityMaps = 'unmicst'

// Default parameters for individual modules
params.ashlarOpts  = '-m 30 --pyramid'
params.unmicstOpts = ''
params.s3segOpts   = ''
params.quantOpts   = ''

// Define all subdirectories
path_raw   = "${params.in}/raw_images"            // Step 0
path_ilp   = "${params.in}/illumination_profiles" // Step 1
path_rg    = "${params.in}/registration"          // Step 2
path_dr    = "${params.in}/dearray"               // Step 3
path_prob  = "${params.in}/probability-maps"      // Step 4
path_seg   = "${params.in}/segmentation"          // Step 5
path_quant = "${params.in}/quantification"        // Step 6
path_qc    = "${params.in}/qc"

// Identify marker information
Channel.fromPath( "${params.in}/markers.csv" ).set{ chNames }

// Step 1 and 2 input
// Find raw images; feed them into separate channels for
//   illumination (step 1 input) and ASHLAR (step 2 input)
formats = '{.ome.tiff,.ome.tif,.rcpnl,.xdce,.nd,.scan,.htd}'
Channel.fromPath( "${path_raw}/**${formats}" )
    .ifEmpty{ if(!params.skipAshlar) error "No images found in ${path_raw}" }
    .into{ s1in; s2in_raw }

// Step 1 precomputed
// If we're not running illumination, look for illumination profiles
(s1pre_dfp, s1pre_ffp) = ( params.illum ? [Channel.empty(), Channel.empty()]
			  : [Channel.fromPath("${path_ilp}/*-dfp.tif"),
			     Channel.fromPath("${path_ilp}/*-ffp.tif")] )

// Step 2 precomputed
// If we're not running ASHLAR, find the pre-stitched image
fn_stitched = "${params.sample_name}.ome.tif"
s2pre = ( !params.skipAshlar ? Channel.empty()
	 : Channel.fromPath("${path_rg}/*.ome.tif").ifEmpty{
	error "Didn't find pre-stitched image in ${path_rg}" })

// Step 1 output
// Illumination profiles
process illumination {
    publishDir path_ilp, mode: 'copy'
    
    input: file s1in
    output:
      file '*-dfp.tif' into s1out_dfp
      file '*-ffp.tif' into s1out_ffp

    when: params.illum

    script:
    def xpn = file(s1in).name.tokenize(".").get(0)
    """
    ${params.tool_imagej}/ImageJ-linux64 --ij2 --headless \
      --run ${params.tool_illum}/imagej_basic_ashlar.py \
      "filename='${s1in}',output_dir='.',experiment_name='${xpn}'"
    """
}

// Closure for sorting by filename instead of the full path
cls_fnsort = {a, b -> a.getName() <=> b.getName()}

// Step 2 input
// s1pre* will contain precomputed profiles (if !params.illum)
// s1out* will contain profiles computed by the pipeline (if params.illum)
// Mix them, as they are mutually exclusive
s2in_ffp = s1out_ffp.mix( s1pre_ffp ).ifEmpty{ file('EMPTY1') }
s2in_dfp = s1out_dfp.mix( s1pre_dfp ).ifEmpty{ file('EMPTY2') }

// Step 2 output
// Stitching and registration
process ashlar {
    publishDir path_rg, mode: 'copy'
    
    input:
      file lraw from s2in_raw.toSortedList()
      file lffp from s2in_ffp.toSortedList(cls_fnsort)
      file ldfp from s2in_dfp.toSortedList(cls_fnsort)

    output: file "${fn_stitched}" into s2out

    when: !params.skipAshlar

    script:
    def ilp = ( lffp.name == 'EMPTY1' | ldfp.name == 'EMPTY2' ) ?
	"" : "--ffp $lffp --dfp $ldfp"
    """
    ashlar $lraw ${params.ashlarOpts} $ilp -f ${fn_stitched}
    """
}

// Step 3 input
// Mix mutually-exclusive step 2 precomputed and step 2 output
// Forward the result to channel tma or tissue based on params.tma flag
s2out
    .mix( s2pre )
    .branch {
      tissue: !params.tma
      tma: params.tma
    }
    .set {s3in}

// Step 3 output
// De-arraying (if TMA)
process dearray {
    publishDir path_qc, mode: 'copy', pattern: 'TMA_MAP.tif'
    publishDir path_dr, mode: 'copy', pattern: '**{[0-9],mask}.tif'

    input: file s from s3in.tma
    
    output:
      file "**{,[A-Z],[A-Z][A-Z]}{[0-9],[0-9][0-9]}.tif" into s3out_cores
      file "**_mask.tif" into s3out_masks
      file "TMA_MAP.tif" into tmamap

    when: params.tma

    """
    matlab -nodesktop -nosplash -r \
    "addpath(genpath('${params.tool_core}')); \
     tmaDearray('./$s','outputPath','.','useGrid','false','cluster',true); exit"
    """
}

// Helper function (closures) to extract image ID from filename
cls_fnid = { file -> file.getBaseName().toString().tokenize('._').head() }

// Finalize step 3 output
// Collapse the earlier branching between full-tissue and TMA into
//   a single (core, mask) imgs channel for all downstream processing
if( params.tma ) {
    // Match up cores and masks by filename
    id_cores = s3out_cores.flatten().map{ f -> tuple(cls_fnid(f),f) }
    id_masks = s3out_masks.flatten().map{ f -> tuple(cls_fnid(f),f) }
    s3out = id_cores.join( id_masks ).map{ id, c, m -> tuple(c, m) }
}
else
    s3out = s3in.tissue.map{ x -> tuple(x, file('NO_MASK')) }

// Step 4 input
// Add channel name file to every (image, mask) tuple
s3out.combine(chNames).into{ s4in_unmicst; s4in_ilastik }

// Step 4 output - UNet classification
process unmicst {
    publishDir "${path_prob}/unmicst", mode: 'copy', pattern: '*PM*.tif'

    input: tuple file(core), val(mask), file(ch) from s4in_unmicst
    output:
	tuple file(core), val(mask),
        file('*Nuclei*.tif'), file('*Contours*.tif'),
        file(ch) into s4out_unmicst

    script:
    """
    python ${params.tool_unmicst}/UnMicst.py $core ${params.unmicstOpts} --outputPath .
    """
}

// Step 4 output - ilastik
process ilastik {
    publishDir "${path_prob}/ilastik", mode: 'copy', pattern: '*'

    input: tuple file(core), val(mask), file(ch) from s4in_ilastik
    output: file('*') into s4out_ilastik
    when: params.probabilityMaps == 'all'
    script:
    """
    python ${params.tool_mcilastik}/CommandIlastikPrepOME.py --input $core --output . \
      --num_channels `tail -n +2 $ch | wc -l`
    cp ${params.tool_mcilastik}/classifiers/exemplar_001.ilp ./model.ilp
    ${params.tool_ilastik}/run_ilastik.sh --headless --project=model.ilp *.hdf5
    """
}

// Step 5 output - segmentation
process s3seg {
    publishDir path_seg, mode: 'copy', pattern: '*/*'

    input:
	tuple file(core), file(mask), file(pmn), file(pmc), file(ch) from s4out_unmicst

    output:
      // tuples for quantification
      tuple file(core), file('**cellMask.tif'), file(ch) into s5out
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
       ${params.s3segOpts} \
       --outputPath .
    """
}

// Step 6 output - quantification
process quantification {
    publishDir path_quant, mode: 'copy', pattern: '*.csv'

    input:  tuple file(core), file(mask), file(ch) from s5out
    output: file '**' into s6out

    """
    python ${params.tool_quant}/CommandSingleCellExtraction.py \
    --mask $mask --image $core \
    ${params.quantOpts} \
    --output . --channel_names $ch
    """
}

// Provenance reconstruction
process provenance {
    executor 'local'
    publishDir path_qc, mode: 'copy'

    output: file 'params.txt' into prov_params

    exec:
    file("${task.workDir}/params.txt").withWriter{ out ->
	params.each{ key, val ->
	    if( key.indexOf('-') == -1 )
	    out.println "$key: $val"
	}
    }
}

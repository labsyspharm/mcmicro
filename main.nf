#!/usr/bin/env nextflow

// Expecting params
// .in - location of the data

// Default parameters for the pipeline as a whole
params.sampleName = file(params.in).name
params.startAt     = 'registration'
params.stopAt      = 'cell-states'
params.tma         = false    // whether to run Coreograph

// Pipeline will look for rawFormats first
// If it finds none, it will look for flatFormats
// This is needed to handle cases like .xdce indexing over multiple .tifs
params.rawFormats  = '{.xdce,.nd,.scan,.htd}'
params.flatFormats = '{.ome.tiff,.ome.tif,.rcpnl,.btf,.nd2,.tif,.czi}'

// Default selection of methods for each step
params.probabilityMaps = 'unmicst'

// Default parameters for individual modules
params.ashlarOpts  = '-m 30'
params.unmicstOpts = ''
params.s3segOpts   = ''
params.quantOpts   = ''
params.nstatesOpts = '-p png'

// Path-specific parameters that cannot be captured by the above *opts
params.maskSpatial = 'cellMask.tif'
params.maskAdd     = ''

// Legacy parameters (to be deprecated in future versions)
params.illum         = false    // whether to run ImageJ+BaSiC
params.skipAshlar    = false    // whether to skip ASHLAR
params.quantificationMask = ''

// Deprecation messages
if( params.quantificationMask != '' )
    error "--quantification-mask is deprecated; please use --mask-spatial and --mask-add instead"
if( params.illum )
    error "--illum is deprecated; please use --start-at illumination"
if( params.skipAshlar )
    error "--skip-ashlar is deprecated; please use --start-at dearray or --start-at probability-maps"

// Steps in the mcmicro pipeline
mcmsteps = ["raw",		// Step 0
	    "illumination",	// Step 1
	    "registration",	// Step 2
	    "dearray",		// Step 3
	    "probability-maps", // Step 4
	    "segmentation",	// Step 5
	    "quantification",	// Step 6
	    "cell-states"]      // Step 7

// Identify starting and stopping index
idxStart = mcmsteps.indexOf( params.startAt )
idxStop  = mcmsteps.indexOf( params.stopAt )
if( idxStart < 0 )       error "Unknown starting step ${params.startAt}"
if( idxStop < 0 )        error "Unknown stopping step ${params.stopAt}"
if( idxStop < idxStart ) error "Stopping step cannot come before starting step"
if( idxStart > 5 )
  error "Starting at steps beyond segmentation is not yet supported."

// Define all subdirectories
paths   = mcmsteps.collect{ "${params.in}/$it" }
path_qc = "${params.in}/qc"

// Check that deprecated locations are empty
msg_dprc = {a,b -> "The use of $a has been deprecated. Please use $b instead."}
Channel.fromPath( "${params.in}/raw_images/*" )
    .subscribe{ it -> error msg_dprc("raw_images/", "raw/") }
Channel.fromPath( "${params.in}/illumination_profiles/*" )
    .subscribe{ it -> error msg_dprc("illumination_profiles/", "illumination/") }

// Identify marker information
Channel.fromPath( "${params.in}/markers.csv", checkIfExists: true ).into{ch4; ch6}

// Helper function for finding raw images and precomputed intermediates
findFiles = { p, path, ife -> p ?
	     Channel.fromPath(path).ifEmpty(ife) : Channel.empty() }

// Helper function to extract image ID from filename
getID = { f, delim ->
    tuple( f.getBaseName().toString().split(delim).head(), f ) }

// Look for index formats; if none found, looks for flat formats
// Look in raw/ or registration/, depending on --start-at argument
chkdir  = idxStart <= 2 ? "${paths[0]}" : "${paths[2]}"
formats = file("${chkdir}/**${params.rawFormats}") ?
    params.rawFormats : params.flatFormats

// Feed raw images into separate channels for
//   illumination (step 1 input) and ASHLAR (step 2 input)
findFiles(idxStart <= 2, "${paths[0]}/**${formats}",
	  {error "No images found in ${paths[0]}"}).into{ s1in; s2in_raw }

// Find precomputed intermediates
// Extract samples ID from each filename for subsequent tuple matching
findFiles(idxStart == 2, "${paths[1]}/*-dfp.tif", {file("EMPTY1")}).set{s1pre_dfp}
findFiles(idxStart == 2, "${paths[1]}/*-ffp.tif", {file("EMPTY2")}).set{s1pre_ffp}
findFiles(idxStart == 3 || (idxStart > 3 && !params.tma), "${paths[2]}/*${formats}",
	  {error "No pre-stitched image in ${paths[2]}"} )
    .map{ f -> getID(f,'\\.') }.set{pre_img}
findFiles(idxStart > 3 && params.tma, "${paths[3]}/*.tif",
	  {error "No cores in ${paths[3]}"})
    .map{ f -> getID(f,'\\.tif') }.set{pre_cores}
findFiles(idxStart > 3 && params.tma, "${paths[3]}/masks/*.tif",
	  {error "No masks in ${paths[3]}/masks"})
    .map{ f -> getID(f,'_mask') }.set{pre_masks}
findFiles(idxStart == 5, "${paths[4]}/unmicst/*Probabilities*.tif",
	  {error "No probability maps found in ${paths[4]}/unmicst"})
    .map{ f -> getID(f,'_Probabilities') }.set{pre_probs}

// Match up precomputed intermediates into tuples for each step
pre_img.into{ pre_s2; pre_wsi }
pre_cores.join( pre_masks ).set{ pre_tma }
pre_wsi.map{ id, x -> tuple(id, x, file('NO_MASK')) }
    .mix( pre_tma ).into{ pre_s3; pre_cm }
pre_cm.join( pre_probs ).set{ pre_s4 }

// Finalize the tuple format to match process outputs
pre_s2.map{ id, f -> f }.set{s2pre}
pre_s3.map{ id, c, m -> tuple(c,m) }.set{s3pre}
pre_s4.map{ id, c, m, p -> tuple(c,m,p) }.set{s4pre}

// Step 1 output - illumination profiles
process illumination {
    publishDir paths[1], mode: 'copy'
    
    input: file s1in
    output:
      file '*-dfp.tif' into s1out_dfp
      file '*-ffp.tif' into s1out_ffp
      tuple val(task.name), val(task.workDir) into prov1

    when: idxStart <= 1 && idxStop >= 1

    script:
    def xpn = file(s1in).name.tokenize(".").get(0)
    """
    ${params.tool_imagej}/ImageJ-linux64 --ij2 --headless \
      --run ${params.tool_illum}/imagej_basic_ashlar.py \
      "filename='${s1in}',output_dir='.',experiment_name='${xpn}'"
    """
}

// Step 2 input
s2in_dfp = s1out_dfp.mix( s1pre_dfp )
s2in_ffp = s1out_ffp.mix( s1pre_ffp )

// Closure for sorting by filename instead of the full path
fnSort = {a, b -> a.getName() <=> b.getName()}

// Step 2 output - stitching and registration
fn_stitched = "${params.sampleName}.ome.tif"
process ashlar {
    publishDir paths[2], mode: 'copy'
    
    input:
      file lraw from s2in_raw.toSortedList()
      file lffp from s2in_ffp.toSortedList(fnSort)
      file ldfp from s2in_dfp.toSortedList(fnSort)

    output:
      file "${fn_stitched}" into s2out
      tuple val(task.name), val(task.workDir) into prov2

    when: idxStart <= 2 && idxStop >= 2
    
    script:
    def ilp = ( ldfp.name == 'EMPTY1' || lffp.name == 'EMPTY2' ) ?
	"" : "--ffp $lffp --dfp $ldfp"
    "ashlar $lraw ${params.ashlarOpts} $ilp --pyramid -f ${fn_stitched}"
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
    publishDir "${path_qc}/dearray", mode: 'copy', pattern: 'TMA_MAP.tif'
    publishDir paths[3], mode: 'copy', pattern: '**{[0-9],mask}.tif'

    input: file s from s3in.tma
    
    output:
      file "**{,[A-Z],[A-Z][A-Z]}{[0-9],[0-9][0-9]}.tif" into s3out_cores
      file "**_mask.tif" into s3out_masks
      file "TMA_MAP.tif" into tmamap
      tuple val(task.name), val(task.workDir) into prov3

    when: idxStart <= 3 && idxStop >= 3 && params.tma

    """
    matlab -nodesktop -nosplash -r \
    "addpath(genpath('${params.tool_core}')); \
     tmaDearray('./$s','outputPath','.','useGrid','false','cluster',true); exit"
    """
}

// Finalize step 3 output by matching up cores to masks
if( params.tma ) {
    id_cores = s3out_cores.flatten().map{ f -> getID(f,'\\.tif') }
    id_masks = s3out_masks.flatten().map{ f -> getID(f,'_mask') }
    s3out = id_cores.join( id_masks ).map{ id, c, m -> tuple(c, m) }
}
else s3out = Channel.empty()

// Step 4 input
// Add channel name file to every (image, mask) tuple
s3out
    .mix( s3pre )
    .combine(ch4)
    .into{ s4in_unmicst; s4in_ilastik }

// Step 4 output - UnMicst
process unmicst {
    publishDir "${paths[4]}/unmicst", mode: 'copy', pattern: '*Probabilities*.tif'
    publishDir "${path_qc}/unmicst", mode: 'copy', pattern: '*Preview*.tif'

    input: tuple file(core), val(mask), file(ch) from s4in_unmicst
    output:
      tuple file(core), val(mask), file('*Probabilities*.tif') into s4out_unmicst
      file('*Preview*.tif') into s4out_pub
      tuple val(task.name), val(task.workDir) into prov4_unmicst

    when: idxStart <= 4 && idxStop >= 4
    script:
    """
    python ${params.tool_unmicst}/UnMicst.py $core ${params.unmicstOpts} \
      --stackOutput --outputPath .
    """
}

// Step 4 output - ilastik
process ilastik {
    publishDir "${paths[4]}/ilastik", mode: 'copy', pattern: '*'

    input: tuple file(core), val(mask), file(ch) from s4in_ilastik
    output:
      file('*') into s4out_ilastik
      tuple val(task.name), val(task.workDir) into prov4_ilastik

    when: params.probabilityMaps == 'all' && idxStop >= 4
    script:
    """
    python ${params.tool_mcilastik}/CommandIlastikPrepOME.py --input $core --output . \
      --num_channels `tail -n +2 $ch | wc -l`
    cp ${params.tool_mcilastik}/classifiers/exemplar_001.ilp ./model.ilp
    ${params.tool_ilastik}/run_ilastik.sh --headless --project=model.ilp *.hdf5
    """
}

// Step 5 input
s5in = s4out_unmicst.mix( s4pre )

// Determine which masks will be needed by quantification
masks = params.maskAdd.tokenize()
switch( masks.size() ) {
    case 0: masks = ""; break;
    case 1: masks = "**${masks[0]}"; break;
    default: masks = "**{${masks.join(',')}}"
}

// Step 5 output - segmentation
process s3seg {
    publishDir paths[5],           mode: 'copy', pattern: '*/*Mask.tif'
    publishDir "${path_qc}/s3seg", mode: 'copy', pattern: '*/*Outlines.tif'

    input:
	tuple file(core), file(mask), file(probs) from s5in

    output:
	// tuples for quantification
        tuple file(core), file("**${params.maskSpatial}"),
          file("$masks") into s5out
        // rest of the files for publishDir
        file '**' into s5out_pub
        tuple val(task.name), val(task.workDir) into prov5

    when: idxStart <= 5 && idxStop >= 5
    
    script:
    def crop = params.tma ? 'dearray' : 'noCrop'
    """
    python ${params.tool_segment}/S3segmenter.py --crop $crop \
       --imagePath $core \
       --maskPath $mask \
       --stackProbPath $probs \
       ${params.s3segOpts} \
       --outputPath .
    """
}

// Step 6 input
s6in = s5out.combine(ch6)


// Step 6 output - quantification
process quantification {
    publishDir paths[6], mode: 'copy', pattern: '*.csv'

    input:  tuple file(core), file(maskSpt), file(maskAdd), file(ch) from s6in
    output:
      file ('*.csv') into s6out
      tuple val(task.name), val(task.workDir) into prov6

    when: idxStart <= 6 && idxStop >= 6

    """
    python ${params.tool_quant}/CommandSingleCellExtraction.py \
    --mask $maskSpt $maskAdd --image $core \
    ${params.quantOpts} \
    --output . --channel_names $ch
    """
}

// Step 7 output
process naivestates {
    publishDir paths[7], mode: 'copy', pattern: '*.csv'
    publishDir paths[7], mode: 'copy', pattern: 'plots/*.*'
    publishDir "${path_qc}/naivestates", mode: 'copy', pattern: 'plots/*/*.*',
      saveAs: { fn -> fn.replaceFirst("plots/","") }
    
    input: file(counts) from s6out
    output:
      file '**' into s7out
      tuple val(task.name), val(task.workDir) into prov7

    when: idxStart <= 7 && idxStop >= 7

    """
    ${params.tool_nstates}/main.R -i $counts -o . ${params.nstatesOpts} \
    --mct ${params.tool_nstates}/typemap.csv
    """
}

// Provenance reconstruction
workflow.onComplete {
    // Create a provenance directory
    path_prov = "${path_qc}/provenance"
    file(path_prov).mkdirs()

    // Store parameters used
    file("${path_qc}/params.yml").withWriter{ out ->
	params.each{ key, val ->
	    if( key.indexOf('-') == -1 )
	    out.println "$key: $val"
	}
    }

    // Combine the provenance of all tasks into a single channel
    // Store commands and logs
    prov1.mix(prov2, prov3, prov4_unmicst, prov4_ilastik, prov5, prov6, prov7)
	.subscribe { name, wkdir ->  if( wkdir != null ) {
	    file("${wkdir}/.command.sh").copyTo("${path_prov}/${name}.sh")
	    file("${wkdir}/.command.log").copyTo("${path_prov}/${name}.log")
	}
    }
}


#!/usr/bin/env nextflow

// Expecting params
// .in - location of the data

// Default parameters for the pipeline as a whole
params.sample_name = file(params.in).name
params.startAt     = 'registration'
params.stopAt      = 'quantification'
params.tma         = false    // whether to run Coreograph

// Default selection of methods for each step
params.probabilityMaps = 'unmicst'

// Default parameters for individual modules
params.ashlarOpts  = '-m 30 --pyramid'
params.unmicstOpts = ''
params.s3segOpts   = ''
params.quantOpts   = ''

// Path-specific parameters that cannot be captured by the above *opts
params.quantificationMask = 'cellMask.tif'

// Legacy parameters (to be deprecated in future versions)
params.illum         = false    // whether to run ImageJ+BaSiC
params.skipAshlar    = false    // whether to skip ASHLAR

// Steps in the mcmicro pipeline
mcmsteps = ["raw",		// Step 0
	    "illumination",	// Step 1
	    "registration",	// Step 2
	    "dearray",		// Step 3
	    "probability-maps", // Step 4
	    "segmentation",	// Step 5
	    "quantification"]	// Step 6

// Identify starting and stopping index
idxStart = mcmsteps.indexOf( params.startAt )
idxStop  = mcmsteps.indexOf( params.stopAt )
if( idxStart < 0 )       error "Unknown starting step ${params.startAt}"
if( idxStop < 0 )        error "Unknown stopping step ${params.stopAt}"
if( params.illum ) {
    println "--illum is deprecated; please use --start-at illumination"
    idxStart = 1
}
if( params.skipAshlar ) {
    println "--skip-ashlar is deprecated; please use --start-at dearray or --start-at probability-maps"
    idxStart = 3
}
if( idxStop < idxStart ) error "Stopping step cannot come before starting step"
if( idxStart > 4 )
  error "Starting at steps beyond probability map computation is not yet supported."

// Define all subdirectories
path_raw   = "${params.in}/${mcmsteps[0]}"
path_ilp   = "${params.in}/${mcmsteps[1]}"
path_rg    = "${params.in}/${mcmsteps[2]}"
path_dr    = "${params.in}/${mcmsteps[3]}"
path_prob  = "${params.in}/${mcmsteps[4]}"
path_seg   = "${params.in}/${mcmsteps[5]}"
path_quant = "${params.in}/${mcmsteps[6]}"
path_qc    = "${params.in}/qc"

// Check that deprecated locations are empty
msg_dprc = {a,b -> "The use of $a has been deprecated. Please use $b instead."}
Channel.fromPath( "${params.in}/raw_images/*" )
    .subscribe{ it -> error msg_dprc("raw_images/", "raw/") }
Channel.fromPath( "${params.in}/illumination_profiles/*" )
    .subscribe{ it -> error msg_dprc("illumination_profiles/", "illumination/") }

// Identify marker information
chNames = Channel.fromPath( "${params.in}/markers.csv", checkIfExists: true )

// Helper function for finding raw images and precomputed intermediates
findFiles = { p, path, ife -> p ?
	     Channel.fromPath(path).ifEmpty(ife) : Channel.empty() }

// Feed raw images into separate channels for
//   illumination (step 1 input) and ASHLAR (step 2 input)
formats = '{.ome.tiff,.ome.tif,.rcpnl,.xdce,.nd,.scan,.htd,.btf,.nd2,.tif,.czi}'
findFiles(idxStart <= 2, "${path_raw}/**${formats}",
	  {error "No images found in ${path_raw}"}).into{ s1in; s2in_raw }

// Each set of intermediates goes into a single channel (no splitting as with raw images)
s1pre_dfp   = findFiles(idxStart == 2, "${path_ilp}/*-dfp.tif", {file("EMPTY1")})
s1pre_ffp   = findFiles(idxStart == 2, "${path_ilp}/*-ffp.tif", {file("EMPTY2")})
s2pre       = findFiles(idxStart == 3 || (idxStart > 3 && !params.tma), "${path_rg}/*${formats}",
			{error "No pre-stitched image in ${path_rg}"} )
s3pre_cores = findFiles(idxStart > 3 && params.tma, "${path_dr}/*.tif",
			{error "No cores in ${path_dr}"})
s3pre_masks = findFiles(idxStart > 3 && params.tma, "${path_dr}/masks/*.tif",
			{error "No masks in ${path_dr}/masks"})

// Step 1 output - illumination profiles
process illumination {
    publishDir path_ilp, mode: 'copy'
    
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
fn_stitched = "${params.sample_name}.ome.tif"
process ashlar {
    publishDir path_rg, mode: 'copy'
    
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
      tuple val(task.name), val(task.workDir) into prov3

    when: idxStart <= 3 && idxStop >= 3 && params.tma

    """
    matlab -nodesktop -nosplash -r \
    "addpath(genpath('${params.tool_core}')); \
     tmaDearray('./$s','outputPath','.','useGrid','false','cluster',true); exit"
    """
}

// Helper function to extract image ID from filename
getID = { file -> file.getBaseName().toString().tokenize('._').head() }

// Finalize step 3 output
// Collapse the earlier branching between full-tissue and TMA into
//   a single (core, mask) imgs channel for all downstream processing
if( params.tma ) {
    // Match up cores and masks by filename
    id_cores = s3out_cores.flatten().mix(s3pre_cores).map{ f -> tuple(getID(f),f) }
    id_masks = s3out_masks.flatten().mix(s3pre_masks).map{ f -> tuple(getID(f),f) }
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
      tuple val(task.name), val(task.workDir) into prov4_unmicst

    when: idxStop >= 4
    script:
    """
    python ${params.tool_unmicst}/UnMicst.py $core ${params.unmicstOpts} --outputPath .
    """
}

// Step 4 output - ilastik
process ilastik {
    publishDir "${path_prob}/ilastik", mode: 'copy', pattern: '*'

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

// Step 5 output - segmentation
process s3seg {
    publishDir path_seg, mode: 'copy', pattern: '*/*'

    input:
	tuple file(core), file(mask), file(pmn), file(pmc), file(ch) from s4out_unmicst

    output:
      // tuples for quantification
      tuple file(core), file("**${params.quantificationMask}"), file(ch) into s5out
      // rest of the files for publishDir
      file '**' into seg_rest
      tuple val(task.name), val(task.workDir) into prov5

    when: idxStop >= 5
    
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
    output:
      file '**' into s6out
      tuple val(task.name), val(task.workDir) into prov6

    when: idxStop >= 6

    """
    python ${params.tool_quant}/CommandSingleCellExtraction.py \
    --mask $mask --image $core \
    ${params.quantOpts} \
    --output . --channel_names $ch
    """
}

// Provenance reconstruction
workflow.onComplete {
    // Create a provenance directory
    path_prov = "${path_qc}/provenance"
    file(path_prov).mkdirs()

    // Store parameters used
    file("${path_prov}/params.yml").withWriter{ out ->
	params.each{ key, val ->
	    if( key.indexOf('-') == -1 )
	    out.println "$key: $val"
	}
    }

    // Combine the provenance of all tasks into a single channel
    // Store commands and logs
    prov1.mix(prov2, prov3, prov4_unmicst, prov4_ilastik, prov5, prov6)
	.subscribe { name, wkdir ->
	file("${wkdir}/.command.sh").copyTo("${path_prov}/${name}.sh")
	file("${wkdir}/.command.log").copyTo("${path_prov}/${name}.log")
    }
}

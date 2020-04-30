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
if( params.illum )       idxStart = 1
if( params.skipAshlar )  idxStart = 3
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
chNames = Channel.fromPath( "${params.in}/markers.csv" )
    .ifEmpty{ error "No marker.csv found in ${params.in}" }

// Find raw images and precomputed intermediates
formats = '{.ome.tiff,.ome.tif,.rcpnl,.xdce,.nd,.scan,.htd}'
s0          = Channel.fromPath( "${path_raw}/**${formats}" )
s1pre_dfp   = Channel.fromPath( "${path_ilp}/*-dfp.tif" )
s1pre_ffp   = Channel.fromPath( "${path_ilp}/*-ffp.tif" )
s2pre       = Channel.fromPath( "${path_rg}/*.ome.tif" )
s3pre_cores = Channel.fromPath( "${path_dr}/*.tif" )
s3pre_masks = Channel.fromPath( "${path_dr}/masks/*.tif" )

// Step 1 input
// Duplicate the raw images channel for illumination and ASHLAR
if( idxStart <= 1 ) s0.into{ s1in; s2in_raw }
else {
    s0.set{ s2in_raw }
    Channel.empty().set{ s1in }
}

// Step 1 output - illumination profiles
process illumination {
    publishDir path_ilp, mode: 'copy'
    
    input: file s1in
    output:
      file '*-dfp.tif' into s1out_dfp
      file '*-ffp.tif' into s1out_ffp

    when: idxStart <= 1

    script:
    def xpn = file(s1in).name.tokenize(".").get(0)
    """
    ${params.tool_imagej}/ImageJ-linux64 --ij2 --headless \
      --run ${params.tool_illum}/imagej_basic_ashlar.py \
      "filename='${s1in}',output_dir='.',experiment_name='${xpn}'"
    """
}

// Step 2 input
// Use basic-illumination output, if computed
// Use pre-computed images (if available), otherwise
if( idxStart <= 1 ) {
    s1out_dfp.set{ s2in_dfp }
    s1out_ffp.set{ s2in_ffp }
}
else {
    s1pre_dfp.ifEmpty{ file('EMPTY1') }.set{ s2in_dfp }
    s1pre_ffp.ifEmpty{ file('EMPTY2') }.set{ s2in_ffp }
}

// Closure for sorting by filename instead of the full path
cls_fnsort = {a, b -> a.getName() <=> b.getName()}

// Step 2 output - stitching and registration
fn_stitched = "${params.sample_name}.ome.tif"
process ashlar {
    publishDir path_rg, mode: 'copy'
    
    input:
      file lraw from s2in_raw.toSortedList()
      file lffp from s2in_ffp.toSortedList(cls_fnsort)
      file ldfp from s2in_dfp.toSortedList(cls_fnsort)

    output: file "${fn_stitched}" into s2out

    when: idxStart <= 2
    
    script:
    def ilp = ( ldfp.name == 'EMPTY1' || lffp.name == 'EMPTY2' ) ?
	"" : "--ffp $lffp --dfp $ldfp"
    """
    ashlar $lraw ${params.ashlarOpts} $ilp -f ${fn_stitched}
    """
}

// Step 3 input (TMA only)
// Use ASHLAR output if computed
// Use prestitched image otherwise
if( params.tma )
{
    if( idxStart <= 2 ) s2out.set{s3in}
    else if( idxStart == 3 )
      s2pre.ifEmpty{ error "No pre-stitched image in ${path_rg}" }.set{s3in}
    else Channel.empty().set{s3in}
}
else Channel.empty().set{s3in}

// Step 3 output
// De-arraying (if TMA)
process dearray {
    publishDir path_qc, mode: 'copy', pattern: 'TMA_MAP.tif'
    publishDir path_dr, mode: 'copy', pattern: '**{[0-9],mask}.tif'

    input: file s from s3in
    
    output:
      file "**{,[A-Z],[A-Z][A-Z]}{[0-9],[0-9][0-9]}.tif" into s3out_cores
      file "**_mask.tif" into s3out_masks
      file "TMA_MAP.tif" into tmamap

    when: idxStart <= 3 && params.tma

    """
    matlab -nodesktop -nosplash -r \
    "addpath(genpath('${params.tool_core}')); \
     tmaDearray('./$s','outputPath','.','useGrid','false','cluster',true); exit"
    """
}


// Finalize step 3 output
// Use Coreograph output, if computed
// Use pre-computed cores+masks, otherwise
if( params.tma ) {
    if( idxStart <= 3 ) {
	s3out_cores.set{tmp_cores}
	s3out_masks.set{tmp_masks}
    }
    else if( idxStart == 4 ) {
	s3pre_cores.ifEmpty{ error "No cores in ${path_dr}" }.set{tmp_cores}
	s3pre_masks.ifEmpty{ error "No masks in ${path_dr}/masks" }.set{tmp_masks}
    }
    else {
	Channel.empty().set{tmp_cores}
	Channel.empty().set{tmp_masks}
    }

    // Match up cores and masks by filename
    cls_fnid = { file -> file.getBaseName().toString().tokenize('._').head() }
    tmp_cores.flatten().map{ f -> tuple(cls_fnid(f),f) }.set{id_cores}
    tmp_masks.flatten().map{ f -> tuple(cls_fnid(f),f) }.set{id_masks}
    id_cores.join( id_masks ).map{ id, c, m -> tuple(c, m) }.set{s3out}
}
else
{
    if( idxStart <= 2 ) s2out.map{ x -> tuple(x, file('NO_MASK')) }.set{s3out}
    else if( idxStart == 3 || idxStart == 4 ) {
	s2pre.ifEmpty{ error "No pre-stitched image in ${path_rg}" }
	    .map{ x -> tuple(x, file('NO_MASK')) }.set{s3out}
    }
    else Channel.empty().set{s3out}
}

s3out.view()

/*
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
*/
// Step 5 output - segmentation
//process s3seg {
//    publishDir path_seg, mode: 'copy', pattern: '*/*'
/*
    input:
	tuple file(core), file(mask), file(pmn), file(pmc), file(ch) from s4out_unmicst

    output:
      // tuples for quantification
      tuple file(core), file("**${params.quantificationMask}"), file(ch) into s5out
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
*/

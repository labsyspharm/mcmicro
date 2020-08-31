#!/usr/bin/env nextflow

if( !nextflow.version.matches('20.07+') ) {
    println "mcmicro requires Nextflow version 20.08 or greater"
    println "Run the following command: nextflow self-update"
    exit 1
}

nextflow.enable.dsl=2

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
params.ashlarOpts   = '-m 30'
params.coreOpts     = ''
params.unmicstOpts  = ''
params.unmicst2Opts = '--channel 0'
params.ilastikOpts  = '--num_channels 1'
params.s3segOpts    = ''
params.quantOpts    = ''
params.nstatesOpts  = '-p png'

// Path-specific parameters that cannot be captured by the above *opts
params.maskSpatial  = 'cellMask.tif'
params.maskAdd      = ''
params.ilastikModel = 'NO_MODEL'

// Legacy parameters (to be deprecated in future versions)
params.illum         = false    // whether to run ImageJ+BaSiC
params.quantificationMask = ''

// Deprecation messages
if( params.quantificationMask != '' )
    error "--quantification-mask is deprecated; please use --mask-spatial and --mask-add instead"
if( params.illum )
    error "--illum is deprecated; please use --start-at illumination"

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
Channel.fromPath( "${params.in}/illumination_profiles/*" )
    .subscribe{ it -> error msg_dprc("illumination_profiles/", "illumination/") }

// Identify marker information
chMrk = Channel.fromPath( "${params.in}/markers.csv", checkIfExists: true )

// Determine which masks will be needed by quantification
masks = params.maskAdd.tokenize()
switch( masks.size() ) {
    case 0: masks = ""; break;
    case 1: masks = "**${masks[0]}"; break;
    default: masks = "**{${masks.join(',')}}"
}

// Identify the ilastik model
s4_mdl = params.ilastikModel != 'NO_MODEL' ?
    file(params.ilastikModel) : 'NO_MODEL'

// Helper functions for finding raw images and precomputed intermediates
findFiles0 = { p, path -> p ?
	      Channel.fromPath(path) : Channel.empty() }
findFiles  = { p, path, ife -> p ?
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
raw = findFiles(idxStart <= 2, "${paths[0]}/**${formats}",
		{error "No images found in ${paths[0]}"})

// Find precomputed intermediates
// Extract samples ID from each filename for subsequent tuple matching
s1pre_dfp = findFiles0(idxStart == 2, "${paths[1]}/*-dfp.tif")
s1pre_ffp = findFiles0(idxStart == 2, "${paths[1]}/*-ffp.tif")
findFiles(idxStart == 3 || (idxStart > 3 && !params.tma), "${paths[2]}/*${formats}",
	  {error "No pre-stitched image in ${paths[2]}"} )
    .map{ f -> getID(f,'\\.') }.set{pre_img}
findFiles(idxStart > 3 && params.tma, "${paths[3]}/*.tif",
	  {error "No cores in ${paths[3]}"})
    .map{ f -> getID(f,'\\.tif') }.set{pre_cores}
findFiles(idxStart > 3 && params.tma, "${paths[3]}/masks/*.tif",
	  {error "No masks in ${paths[3]}/masks"})
    .map{ f -> getID(f,'_mask') }.set{pre_masks}
findFiles(idxStart == 5 && params.probabilityMaps != 'ilastik',
	  "${paths[4]}/unmicst/*Probabilities*.tif",
	  {error "No probability maps found in ${paths[4]}/unmicst"})
    .map{ f -> getID(f,'_Probabilities') }
    .map{ id, f -> tuple(id, f, 'unmicst') }.set{pre_unmicst}
((idxStart == 5 && params.probabilityMaps != 'ilastik') ?
 Channel.fromPath("${paths[4]}/unmicst2/*Probabilities*.tif") :
 Channel.empty())
    .map{ f -> getID(f,'_Probabilities') }
    .map{ id, f -> tuple(id, f, 'unmicst2') }.set{pre_unmicst2}
findFiles(idxStart == 5 && params.probabilityMaps != 'unmicst',
	  "${paths[4]}/ilastik/*Probabilities*.tif",
	  {error "No probability maps found in ${paths[4]}/ilastik"})
    .map{ f -> getID(f,'_Probabilities') }
    .map{ id, f -> tuple(id, f, 'ilastik') }.set{pre_ilastik}

/*
// Match up precomputed intermediates into tuples for each step
pre_img.into{ pre_s2; pre_wsi }
pre_cores.join( pre_masks ).into{ pre_s3; pre_tma }
pre_wsi.map{ id, x -> tuple(id, x, 'NO_MASK') }
    .mix( pre_tma ).into{ pre_cm_un; pre_cm_un2; pre_cm_il }
pre_cm_un.join( pre_unmicst ).set{ pre_s4_un }
pre_cm_un2.join( pre_unmicst2 ).set{ pre_s4_un2 }
pre_cm_il.join( pre_ilastik ).set{ pre_s4_il }
pre_s4_un.mix( pre_s4_un2 ).mix( pre_s4_il ).set{ pre_s4 }

// Finalize the tuple format to match process outputs
pre_s2.map{ id, f -> f }.set{s2pre}
pre_s3.map{ id, c, m -> tuple(c,m) }.set{s3pre}
pre_s4.map{ id, c, m, p, mtd -> tuple(mtd,c,m,p) }.set{s4pre}
*/

params.idxStart = idxStart
params.idxStop  = idxStop

include {illumination} from './modules/illumination' addParams(pubDir: paths[1])
include {registration} from './modules/registration' addParams(pubDir: paths[2])

workflow {
    illumination(raw)
    registration(raw,
		 illumination.out.ffp.mix( s1pre_ffp ),
		 illumination.out.dfp.mix( s1pre_dfp ))
}

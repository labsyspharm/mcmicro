#!/usr/bin/env nextflow

if( !nextflow.version.matches('20.07+') ) {
    println "mcmicro requires Nextflow version 20.08 or greater"
    println "Run the following command to update: nextflow self-update"
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

// Define all subdirectories
paths   = mcmsteps.collect{ "${params.in}/$it" }
path_qc = "${params.in}/qc"

// Check that deprecated locations are empty
msg_dprc = {a,b -> "The use of $a has been deprecated. Please use $b instead."}
Channel.fromPath( "${params.in}/illumination_profiles/*" )
    .subscribe{ it -> error msg_dprc("illumination_profiles/", "illumination/") }

// Identify marker information
chMrk = Channel.fromPath( "${params.in}/markers.csv", checkIfExists: true )

// Identify the ilastik model
s4_mdl = params.ilastikModel != 'NO_MODEL' ?
    file(params.ilastikModel) : 'NO_MODEL'

// Determine which masks will be needed by quantification
masks = params.maskAdd.tokenize()
switch( masks.size() ) {
    case 0: params.qtym = ""; break;
    case 1: params.qtym = "**${masks[0]}"; break;
    default: params.qtym = "**{${masks.join(',')}}"
}

// Helper functions for finding raw images and precomputed intermediates
findFiles0 = { p, path -> p ?
	      Channel.fromPath(path) : Channel.empty() }
findFiles  = { p, path, ife -> p ?
	      Channel.fromPath(path).ifEmpty(ife) : Channel.empty() }

// Look for index formats; if none found, looks for flat formats
// Look in raw/ or registration/, depending on --start-at argument
chkdir  = idxStart <= 2 ? "${paths[0]}" : "${paths[2]}"
formats = file("${chkdir}/**${params.rawFormats}") ?
    params.rawFormats : params.flatFormats

// Feed raw images into separate channels for
//   illumination (step 1 input) and ASHLAR (step 2 input)
raw = findFiles(idxStart <= 2, "${paths[0]}/**${formats}",
		{error "No images found in ${paths[0]}"})

// Helper function to extract image ID from filename
def getID (f, delim) {
    tuple( f.getBaseName().toString().split(delim).head(), f )
}

// Find precomputed intermediates
pre_dfp = findFiles0(idxStart == 2, "${paths[1]}/*-dfp.tif")
pre_ffp = findFiles0(idxStart == 2, "${paths[1]}/*-ffp.tif")
pre_img = findFiles(idxStart == 3 || (idxStart > 3 && !params.tma),
		    "${paths[2]}/*${formats}",
		    {error "No pre-stitched image in ${paths[2]}"})
pre_cores = findFiles(idxStart > 3 && params.tma,
		      "${paths[3]}/*.tif",
		      {error "No cores in ${paths[3]}"})
pre_masks = findFiles(idxStart > 3 && params.tma,
		      "${paths[3]}/masks/*.tif",
		      {error "No TMA masks in ${paths[3]}/masks"})
pre_unmicst = findFiles(idxStart == 5 &&
			(params.probabilityMaps == 'unmicst' ||
			 params.probabilityMaps == 'all'),
			"${paths[4]}/unmicst/*Probabilities*.tif",
			{error "No probability maps found in ${paths[4]}/unmicst"})
pre_ilastik = findFiles(idxStart == 5 &&
			(params.probabilityMaps == 'ilastik' ||
			 params.probabilityMaps == 'all'),
			"${paths[4]}/ilastik/*Probabilities*.tif",
			{error "No probability maps found in ${paths[4]}/ilastik"})
pre_sptMsk = findFiles(idxStart == 6,
		       "${paths[5]}/**${params.maskSpatial}",
		       {error "No spatial masks in ${paths[5]}"})
pre_addMsk = findFiles(idxStart == 6 && params.qtym != '',
		       "${paths[5]}/${params.qtym}",
		       {error "No additional masks in ${paths[5]}"})
pre_qty    = findFiles(idxStart == 7,
		       "${paths[6]}/*.csv",
		       {error "No quantification tables in ${paths[6]}"})

// Compute sample IDs for each found intermediate
id_img     = pre_img.map{ f -> getID(f,'\\.') }
id_cores   = pre_cores.map{ f -> getID(f,'\\.tif') }
id_masks   = pre_masks.map{ f -> getID(f,'_mask') }
id_unmicst = pre_unmicst.map{ f -> getID(f,'_Probabilities') }
    .map{ id, f -> tuple(id, f, 'unmicst') }
id_ilastik = pre_ilastik.map{ f -> getID(f,'_Probabilities') }
    .map{ id, f -> tuple(id, f, 'ilastik') }
id_sptMsk  = pre_sptMsk.map{ f -> tuple(f.getParent().getBaseName(), f) }
id_addMsk  = pre_addMsk.map{ f -> tuple(f.getParent().getBaseName(), f) }
    .groupTuple()
id_qtyMsk  = (params.qtym == '' ?
	      id_sptMsk.map{ id, m -> tuple(id, m, []) } :
	      id_sptMsk.join( id_addMsk ))
    .map{ id, sm, am -> x = id.split('-',2); tuple(x[1], x[0], sm, am) }

// Match up precomputed intermediates into tuples for each step
id_cm   = id_cores.join( id_masks )
id_cm2  = id_img.map{ id, x -> tuple(id, x, 'NO_MASK') }.mix(id_cm)
id_pmap = id_cm2.join( id_unmicst ).mix( id_cm2.join( id_ilastik ) )
id_qty  = id_img.mix( id_cores ).combine( id_qtyMsk, by:0 )

// Finalize the tuple format to match process outputs
pre_tma  = id_cm.map{ id, c, m -> tuple(c,m) }
pre_pmap = id_pmap.map{ id, c, m, p, mtd -> tuple(mtd,c,m,p) }
pre_seg  = id_qty.map{ id, i, mtd, sm, am -> tuple(mtd,i,sm,am) }

// The following parameters are shared by all modules
params.idxStart = idxStart
params.idxStop  = idxStop
params.path_qc  = path_qc

// Import individual modules
include {illumination}   from './modules/illumination'     addParams(pubDir: paths[1])
include {registration}   from './modules/registration'     addParams(pubDir: paths[2])
include {dearray}        from './modules/dearray'          addParams(pubDir: paths[3])
include {probmaps}       from './modules/probability-maps' addParams(pubDir: paths[4])
include {segmentation}   from './modules/segmentation'     addParams(pubDir: paths[5])
include {quantification} from './modules/quantification'   addParams(pubDir: paths[6])
include {naivestates}    from './modules/cell-states'      addParams(pubDir: paths[7])

// Define the primary mcmicro workflow
workflow {
    illumination(raw)
    registration(raw,
		 illumination.out.ffp.mix( pre_ffp ),
		 illumination.out.dfp.mix( pre_dfp ))

    // Are we working with a TMA or a whole-slide image?
    img = registration.out
	.mix(pre_img)
	.branch {
	  wsi: !params.tma
	  tma: params.tma
        }

    // Apply dearray to TMAs only
    dearray(img.tma)

    // Whole slide images have no TMA mask
    img.wsi.map{ x -> tuple(x, 'NO_MASK') }
	.mix(dearray.out)
	.mix(pre_tma) |
	probmaps

    // Combine probability map output with precomputed one
    // Forward the result to segmentation
    probmaps.out.mix(pre_pmap) |
	segmentation

    // Append markers.csv to every tuple
    segmentation.out.mix(pre_seg)
	.combine(chMrk)
	.map{ mtd, c, ms, ma, ch ->
          tuple("${mtd}-${c.getName()}", c, ms, ma, ch) } |
	quantification

    // Cell type callers
    quantification.out.mix(pre_qty) |
	naivestates
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
}

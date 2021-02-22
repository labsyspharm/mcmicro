#!/usr/bin/env nextflow

if( !nextflow.version.matches('20.07+') ) {
    println "mcmicro requires Nextflow version 20.07 or greater"
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

// Some image formats store multiple fields of view in a single file. Other
// formats store each field separately, typically in .tif files, with a separate
// index file to tie them together. We will look for the index files from
// multiple-file formats in a first, separate pass in order to avoid finding the
// individual .tif files instead. If no multi-file formats are detected, then we
// look for the single-file formats. Also, for multi-file formats we need to
// stage the parent directory and not just the index file.
params.multiFormats  = '{.xdce,.nd,.scan,.htd}'
params.singleFormats = '{.ome.tiff,.ome.tif,.rcpnl,.btf,.nd2,.tif,.czi}'

// Default selection of methods for each step
params.probabilityMaps = 'unmicst'

// Default parameters for individual modules
params.ashlarOpts   = '-m 30'
params.coreOpts     = ''
params.unmicstOpts  = ''
params.unmicst2Opts = '--channel 0'
params.ilastikOpts  = '--num_channels 1'
params.s3segOpts    = ''
params.quantOpts    = '--masks cellMask.tif'
params.nstatesOpts  = '-p png'

// Path-specific parameters that cannot be captured by the above *opts
params.maskSpatial  = ''
params.maskAdd      = ''
params.ilastikModel = 'built-in'

// Legacy parameters (to be deprecated in future versions)
params.illum         = false    // whether to run ImageJ+BaSiC
params.quantificationMask = ''

// Deprecation messages
if( params.quantificationMask != '' )
    error "--quantification-mask is deprecated; please use --mask-spatial and --mask-add instead"
if( params.illum )
    error "--illum is deprecated; please use --start-at illumination"
if( params.maskSpatial != '' )
    error "--maskSpatial is deprecated; please use --quant-opts '--masks ...'"
if( params.maskAdd != '' )
    error "--maskAdd is deprecated; please use --quant-opts '--masks ...'"

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
Channel.fromPath( "${params.in}/illumination_profiles/*" )
    .subscribe{ it ->
    error "illumination_profiles/ is deprecated; please use illumination/ instead"
}

// Identify marker information
chMrk = Channel.fromPath( "${params.in}/markers.csv", checkIfExists: true )

// Helper functions for finding raw images and precomputed intermediates
findFiles0 = { p, path -> p ?
	      Channel.fromPath(path) : Channel.empty() }
findFiles  = { p, path, ife -> p ?
	      Channel.fromPath(path).ifEmpty(ife) : Channel.empty() }

// Look for multi formats first, then single formats.
(formatType, formatPattern) =
    file("${paths[0]}/**${params.multiFormats}") ?
    ["multi", params.multiFormats] : ["single", params.singleFormats]
rawFiles = findFiles(idxStart <= 2, "${paths[0]}/**${formatPattern}",
		     {error "No images found in ${paths[0]}"})

// Here we assemble tuples of 1) path to stage for each raw image (might be a
// directory) and 2) relative path to the main file for each image. Processes
// must input the first as a path and the second as a val to avoid incorrect or
// redundant file staging. They must also only use the second (relative) path to
// construct pathnames for scripts etc. mcmicro.Util.escapePathForShell must be
// used when interpolating these paths into script strings, as we are bypassing
// the normal way that paths are passed to channels which handles this escaping
// automatically.
raw = rawFiles
    .map{ tuple(formatType == "single" ? it : it.parent, it) }
    .map{ toStage, relPath -> tuple(toStage, toStage.parent.relativize(relPath)) }

// Helper function to extract image ID from filename
def getID (f, delim) {
    tuple( f.getBaseName().toString().split(delim).head(), f )
}

// Find precomputed intermediates
pre_dfp = findFiles0(idxStart == 2, "${paths[1]}/*-dfp.tif")
pre_ffp = findFiles0(idxStart == 2, "${paths[1]}/*-ffp.tif")
pre_img = findFiles(idxStart == 3 || (idxStart > 3 && !params.tma),
		    "${paths[2]}/*.{ome.tiff,ome.tif,tif,tiff,btf}",
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
pre_segMsk = findFiles(idxStart == 6,
		       "${paths[5]}/**Mask.tif",
		       {error "No segmentation masks in ${paths[5]}"})
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
id_segMsk  = pre_segMsk.map{ f -> tuple(f.getParent().getBaseName(), f) }
    .groupTuple().map{ id, msk -> x = id.split('-',2); tuple(x[1], x[0], msk) }

// Match up precomputed intermediates into tuples for each step
id_cm   = id_cores.join( id_masks )
id_cm2  = id_img.map{ id, x -> tuple(id, x, 'NO_MASK') }.mix(id_cm)
id_pmap = id_cm2.join( id_unmicst ).mix( id_cm2.join( id_ilastik ) )
id_seg  = id_img.mix( id_cores ).combine( id_segMsk, by:0 )

// Finalize the tuple format to match process outputs
pre_tma  = id_cm.map{ id, c, m -> tuple(c,m) }
pre_pmap = id_pmap.map{ id, c, m, p, mtd -> tuple(mtd,c,m,p) }
pre_seg  = id_seg.map{ id, i, mtd, msk -> tuple(mtd,i,msk) }

// The following parameters are shared by all modules
params.idxStart  = idxStart
params.idxStop   = idxStop
params.path_qc   = path_qc
params.path_prov = "${path_qc}/provenance"

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
	.map{ mtd, c, msk -> tuple("${mtd}-${c.getName()}", c, msk) }
    	.combine(chMrk) |
	quantification

    // Cell type callers
    quantification.out.tables.mix(pre_qty) |
	naivestates
}

// Write out parameters used
workflow.onComplete {
    // Create a provenance directory
    file(path_qc).mkdirs()
    
    // Store parameters used
    file("${path_qc}/params.yml").withWriter{ out ->
	params.each{ key, val ->
	    if( key.indexOf('-') == -1 )
	    out.println "$key: $val"
	}
    }
}

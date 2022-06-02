#!/usr/bin/env nextflow

if( !(nextflow.version >= '20.07') ) {
    println "mcmicro requires Nextflow version 20.07 or greater"
    println "Run the following command to update: nextflow self-update"
    exit 1
}

nextflow.enable.dsl=2

import mcmicro.Opts

// Expecting --in parameter
if( !params.containsKey('in') )
    error "Please specify the project directory with --in"

// Default parameters for the pipeline as a whole
params.sampleName  = file(params.in).name
params.startAt     = 'registration'
params.stopAt      = 'quantification'
params.qcFiles     = 'copy'   // what to do with qc/ files when publishing them
params.tma         = false    // whether working with a TMA (true) or whole-slide image (false)
params.dynrange    = false    // misc: autothresholding of channels

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
params.cellStates      = 'scimap'

// Deprecation messages
if( params.containsKey('quantificationMask') )
    error "--quantification-mask is deprecated; please use --quant-opts '--masks ...'"
if( params.containsKey('illum') )
    error "--illum is deprecated; please use --start-at illumination"
if( params.containsKey('coreOpts') )
    error "--coreOpts is deprecated; please use --coreograph-opts"
if( params.containsKey('maskSpatial') )
    error "--maskSpatial is deprecated; please use --quant-opts '--masks ...'"
if( params.containsKey('maskAdd') )
    error "--maskAdd is deprecated; please use --quant-opts '--masks ...'"
if( params.containsKey('nstatesOpts') )
    error "--nstatesOpts is deprecated; please use --naivestates-opts"
if( params.containsKey('quantOpts') )
    error "--quantOpts is deprecated; please use --mcquant-opts"
if( params.probabilityMaps == 'all' )
    error "--probability-maps all is deprecated; please be explicit, e.g., --probability-maps unmicst,ilastik"

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
pre_pmap = findFiles(idxStart == 5,
		     "${paths[4]}/*/*-pmap.tif",
		     {error "No probability maps found in ${paths[4]}"})
    .map{ f -> tuple(f.getParent().getName(), f) }
    .filter{ params.probabilityMaps.contains(it[0]) }
pre_segMsk = findFiles(idxStart == 6,
		       "${paths[5]}/**.tif",
		       {error "No segmentation masks in ${paths[5]}"})
    .map{ f -> tuple(f.getParent().getName(), f) }.groupTuple()
pre_qty    = findFiles(idxStart == 7,
		       "${paths[6]}/*.csv",
		       {error "No quantification tables in ${paths[6]}"})

// Load module specs
modules = Opts.parseModuleSpecs("$projectDir/modules.yml", params)

// The following parameters are shared by all modules
params.idxStart  = idxStart
params.idxStop   = idxStop
params.path_qc   = path_qc
params.path_prov = "${path_qc}/provenance"

// Import individual modules
include {illumination}   from './modules/illumination'
include {registration}   from './modules/registration'
include {dearray}        from './modules/dearray'
include {segmentation}   from './modules/segmentation'
include {quantification} from './modules/quantification'
include {cellstates}     from './modules/cell-states'
include {roadie}         from './roadie'

// Define the primary mcmicro workflow
workflow {
    illumination(modules['illumination'], raw)
    registration(modules['registration'], raw,
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
    dearray(modules['dearray'], img.tma)

    // Merge against precomputed intermediates
    tmacores = dearray.out.cores.mix(pre_cores)
    tmamasks = dearray.out.masks.mix(pre_masks)

    // Reconcile WSI and TMA processing for downstream segmentation
    allimg = img.wsi.mix(tmacores)
    segmentation(modules['segmentation'], modules['watershed'],
        allimg, tmamasks, pre_pmap)

    // Merge segmentation masks against precomputed ones and append markers.csv
    segMsk = segmentation.out.mix(pre_segMsk)
    quantification(modules['quantification'], allimg, segMsk, chMrk)

    // Spatial feature tables -> cell state calling
    sft = quantification.out.mix(pre_qty)
    cellstates(sft, modules['downstream'])

    // Run miscellaneous tasks
    if(params.story) {
        roadie('story', allimg, '', "${params.in}/qc/story", 'copy')
    }
}

// Write out parameters used
workflow.onComplete {
    // Create a provenance directory
    file(path_qc).mkdirs()
    
    // Write out module specs
    Opts.writeModuleSpecs(modules, "${params.in}/qc/modules.yml")

    // Store parameters used
    file("${path_qc}/params.yml").withWriter{ out ->
	out.println "githubTag: $workflow.revision";
	out.println "githubCommit: $workflow.commitId";
	params.each{ key, val ->
	    if( key.indexOf('-') != -1 ) return
        if( [
            'githubTag', 'githubCommit', 'contPfx', 'paramsFile',
            'idxStart', 'idxStop', 'path_qc', 'path_prov'
            ].contains(key) ) return
        if( ['multiFormats', 'singleFormats'].contains(key) )
            out.println "$key: '$val'"
        else
	        out.println "$key: $val"
	  }
    }
}

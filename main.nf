#!/usr/bin/env nextflow

if( !(nextflow.version >= '22.04.3') ) {
    println "mcmicro requires Nextflow version 22.04.3 or greater"
    println "Run the following command to update: nextflow self-update"
    exit 1
}

nextflow.enable.dsl=2

import mcmicro.*

// Expecting --in parameter
if( !params.containsKey('in') )
    error "Please specify the project directory with --in"

// Parse MCMICRO parameters (mcp)
mcp = Opts.parseParams(
    params, 
    "$projectDir/config/schema.yml",
    "$projectDir/config/defaults.yml"
)

// Separate out workflow parameters (wfp) and module specs to simplify code
wfp = mcp.workflow
modules = mcp.modules

// Identify relevant precomputed intermediates
// The actual paths to intermediate files are given by
//   pre.collect{ "${params.in}/$it" }
pre = Flow.precomputed(wfp)

// Check that deprecated locations are empty
Channel.fromPath( "${params.in}/illumination_profiles/*" )
    .subscribe{ it ->
    error "illumination_profiles/ is deprecated; please use illumination/ instead"
}

// Identify marker information
chMrk = Channel.fromPath( "${params.in}/markers.csv", checkIfExists: true )

// Helper functions for finding raw images and precomputed intermediates
findFiles0 = { key, pattern -> pre[key] ?
    Channel.fromPath("${params.in}/$key/$pattern") : Channel.empty()
}
findFiles = { key, pattern, ife -> pre[key] ?
    Channel.fromPath("${params.in}/$key/$pattern").ifEmpty(ife) : Channel.empty()
}

// Some image formats store multiple fields of view in a single file. Other
// formats store each field separately, typically in .tif files, with a separate
// index file to tie them together. We will look for the index files from
// multiple-file formats in a first, separate pass in order to avoid finding the
// individual .tif files instead. If no multi-file formats are detected, then we
// look for the single-file formats. Also, for multi-file formats we need to
// stage the parent directory and not just the index file.
(formatType, formatPattern) =
    file("${params.in}/raw/**${wfp['multi-formats']}") ?
    ["multi", wfp['multi-formats']] : ["single", wfp['single-formats']]
rawFiles = findFiles('raw', "**${formatPattern}",
		     {error "No images found in ${params.in}/raw"})

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
pre_dfp   = findFiles0('illumination', "*-dfp.tif")
pre_ffp   = findFiles0('illumination', "*-ffp.tif")
pre_img   = findFiles('registration', "*.{ome.tiff,ome.tif,tif,tiff,btf}",
    {error "No pre-stitched image in ${params.in}/registration"})
pre_cores = findFiles('dearray', "*.tif",
    {error "No TMA cores in ${params.in}/dearray"})
pre_masks = findFiles('dearray', "masks/*.tif",
    {error "No TMA masks in ${params.in}/dearray/masks"})
pre_pmap  = findFiles('probability-maps', "*/*-pmap.tif",
    {error "No probability maps found in ${params.in}/probability-maps"})
    .map{ f -> tuple(f.getParent().getName(), f) }
    .filter{ wfp['segmentation'].contains(it[0]) }
pre_seg   = findFiles('segmentation', "**.tif",
    {error "No segmentation masks in ${params.in}/segmentation"})
    .map{ f -> tuple(f.getParent().getName(), f) }.groupTuple()
pre_qty   = findFiles('quantification', "*.csv",
    {error "No quantification tables in ${params.in}/quantification"})

// Import individual modules
include {illumination}   from "$projectDir/modules/illumination"
include {registration}   from "$projectDir/modules/registration"
include {dearray}        from "$projectDir/modules/dearray"
include {segmentation}   from "$projectDir/modules/segmentation"
include {quantification} from "$projectDir/modules/quantification"
include {cellstates}     from "$projectDir/modules/cell-states"
include {viz}            from "$projectDir/modules/viz"


// Define the primary mcmicro workflow
workflow {
    illumination(wfp, modules['illumination'], raw)
    registration(wfp, modules['registration'], raw,
		 illumination.out.ffp.mix( pre_ffp ),
		 illumination.out.dfp.mix( pre_dfp ))

/*    // Are we working with a TMA or a whole-slide image?
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

    // Vizualization
    viz(modules['viz'], allimg)*/
}

/*
// Write out parameters used
path_qc = "${params.in}/qc"
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
*/
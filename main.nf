#!/usr/bin/env nextflow

if( !(nextflow.version >= '22.04.3') ) {
    println "mcmicro requires Nextflow version 22.04.3 or greater"
    println "Run the following command to update: nextflow self-update"
    exit 1
}

nextflow.enable.dsl=2

import mcmicro.*

import org.yaml.snakeyaml.Yaml
import org.yaml.snakeyaml.DumperOptions

// Expecting --in parameter
if( !params.containsKey('in') )
    error "Please specify the project directory with --in"

// Parse MCMICRO parameters (mcp)
mcp = Opts.parseParams(
    params, 
    "$projectDir/config/schema.yml",
    "$projectDir/config/defaults.yml"
)

// Separate out workflow parameters (wfp) to simplify code
wfp = mcp.workflow

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
    
stagingDirs = Channel.fromPath("${params.in}/staging/*", type: 'dir')
    .ifEmpty { error "No subdirectories found in staging directory" }
staging_in = stagingDirs
    .map{ tuple(
        Util.getSampleName(it, file("${params.in}/staging")),
        Util.getCycleNameFromDir(it, file("${params.in}/staging")),
        formatType == "single" ? it : it.parent
    )}
// Here we assemble tuples of 1) path to stage for each raw image (might be a
// directory) and 2) relative path to the main file for each image. Processes
// must input the first as a path and the second as a val to avoid incorrect or
// redundant file staging. They must also only use the second (relative) path to
// construct pathnames for scripts etc. mcmicro.Util.escapePathForShell must be
// used when interpolating these paths into script strings, as we are bypassing
// the normal way that paths are passed to channels which handles this escaping
// automatically.
rawFiles = findFiles('raw', "**${formatPattern}",
		     {error "No images found in ${params.in}/raw"})
raw = rawFiles
    .map{ tuple(
        Util.getSampleName(it, file("${params.in}/raw")),
        formatType == "single" ? it : it.parent, 
        it
    )}
    .map{ sampleName, toStage, relPath -> 
        tuple(sampleName, toStage, toStage.parent.relativize(relPath).toString()) }

// Find precomputed intermediates
pre_dfp   = findFiles0('illumination', "**-dfp.tif")
    .map{ tuple(Util.getSampleName(it, file("${params.in}/illumination")), it) }
pre_ffp   = findFiles0('illumination', "**-ffp.tif")
    .map{ tuple(Util.getSampleName(it, file("${params.in}/illumination")), it) }
pre_img   = findFiles('registration', "*.{ome.tiff,ome.tif,tif,tiff,btf}",
    {error "No pre-stitched image in ${params.in}/registration"})
pre_bsub  = findFiles('background', "*.ome.tif",
    {error "No background subtracted image in ${params.in}/background"})
pre_bsubm = findFiles('background', "*.csv",
    {error "No background subtracted markers file in ${params.in}/background"})
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
include {staging}        from "$projectDir/modules/staging"
include {illumination}   from "$projectDir/modules/illumination"
include {registration}   from "$projectDir/modules/registration"
include {dearray}        from "$projectDir/modules/dearray"
include {segmentation}   from "$projectDir/modules/segmentation"
include {quantification} from "$projectDir/modules/quantification"
include {downstream}     from "$projectDir/modules/downstream"
include {viz}            from "$projectDir/modules/viz"
include {background}     from "$projectDir/modules/background"

// Define the primary mcmicro workflow
workflow {
    staging(mcp, staging_in, chMrk)
    //staging.out.view()
    staging.out.map{
        sample, cycle, path ->
        tuple(sample, cycle, path, path.toString().split('/').last())
        }.toSortedList { a, b -> a[1] <=> b[1] }
        .flatMap()
        .map{
            sample, cycle, path, name ->
            tuple(sample, path, name)
        }.set{ sorted_staging }
    raw = raw.mix(sorted_staging)

    illumination(wfp, mcp.modules['illumination'], raw)
    registration(mcp, raw,
		 illumination.out.ffp.mix( pre_ffp ),
		 illumination.out.dfp.mix( pre_dfp ))
    img = registration.out.mix(pre_img)

    // Should background subtraction be applied?
    img = img.
        branch{
            nobs: !wfp.background
            bs: wfp.background
        }
    chMrk = chMrk.
        branch{
            nobs: !wfp.background
            bs: wfp.background
        }
    // Apply background if specified
    background(mcp, img.bs, chMrk.bs)
    // Merge against precomputed intermediates
    bsub_image = background.out.image.mix(pre_bsub)
    bsub_marker = background.out.marker.mix(pre_bsubm)
    // Reconcile non-background subtracted and background 
    // subtracted images for downstream processing
    img = img.nobs.mix(bsub_image)
    // Reconcile the marker file to the background subtracted csv
    chMrk = chMrk.nobs.mix(bsub_marker)

    // Are we working with a TMA or a whole-slide image?
    img = img
        .branch {
            wsi: !wfp.tma
            tma: wfp.tma
        }

    // Apply dearray to TMAs only
    dearray(mcp, img.tma)

    // Merge against precomputed intermediates
    tmacores = dearray.out.cores.mix(pre_cores)
    tmamasks = dearray.out.masks.mix(pre_masks)

    // Reconcile WSI and TMA processing for downstream segmentation
    allimg = img.wsi.mix(tmacores)
    segmentation(mcp, allimg, tmamasks, pre_pmap)

    // Merge segmentation masks against precomputed ones and append markers.csv
    segMsk = segmentation.out.mix(pre_seg)
    quantification(mcp, allimg, segMsk, chMrk)

    // Spatial feature tables -> cell state calling
    sft = quantification.out.mix(pre_qty)
    downstream(mcp, sft)

    // Vizualization
    viz(mcp, allimg, chMrk)
}

// Write out parameters used
path_qc = "${params.in}/qc"
workflow.onComplete {
    // Create a provenance directory
    file(path_qc).mkdirs()
    
    // Write out MCMICRO parameters
    DumperOptions style = new DumperOptions();
    style.setPrettyFlow(true);
    style.setDefaultFlowStyle(DumperOptions.FlowStyle.BLOCK);
    file("${params.in}/qc/params.yml").withWriter{ out -> 
        new Yaml(style).dump(mcp, out) 
    }

    // Store additional metadata
    file("${path_qc}/metadata.yml").withWriter{ out ->
        out.println "githubTag: $workflow.revision";
        out.println "githubCommit: $workflow.commitId";
        out.println "roadie: $params.roadie";
    }
}

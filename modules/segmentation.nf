import mcmicro.*

process s3seg {
    container "${params.contPfx}${module.container}:${module.version}"

    // Output
    publishDir "${pubDir}/$tag",
      mode: 'copy', pattern: '*/*.ome.tif', saveAs: {f -> file(f).name}

    // QC
    publishDir "${params.path_qc}/s3seg/$tag", mode: "${params.qcFiles}",
      pattern: '*/qc/**', saveAs: {f -> file(f).name}

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}
    
    input:

    val module
    tuple val(tag), path(core), file('mask.tif'), path(probs), val(bypass)
    val pubDir

    output:
	// output for quantification
        tuple val(tag), path("*/*.ome.tif"), emit: segmasks

        // qc and provenance
        path('*/qc/**') optional true
        tuple path('.command.sh'), path('.command.log')

    when: params.idxStart <= 5 && params.idxStop >= 5
    
    script:
	def crop = params.tma ?
	'--crop dearray --maskPath mask.tif' :
	''
    """
    python /app/S3segmenter.py $crop \
       --imagePath $core --stackProbPath $probs \
       $bypass ${Opts.moduleOpts(module, params)} --outputPath .
    """
}

include { worker }                 from "$projectDir/lib/worker"
include { moduleOpts }             from "$projectDir/lib/params"

workflow segmentation {
    take:

    modSeg      // Probability map and instance segmentation modules
    modWS       // Watershed module (e.g., S3Segmenter)
    imgs        // Input images
    tmamasks    // TMA masks (if any)
    prepmaps    // Pre-computed probability maps

    main:

    // A channel iterating over the segmentation modules
    moduleSeg = Channel.of( modSeg ).flatten()

    // Define relevant paths
    pathPM  = "${params.in}/probability-maps"
    pathSeg = "${params.in}/segmentation"

    // Compose a mapping for which modules need watershed
    needWS  = moduleSeg.map{ it -> tuple(it.watershed, it.name) }
    
    // Determine IDs of images
    id_imgs  = imgs.map{ f -> tuple(Util.getImageID(f), f) }
    
    // Determine if there are any custom models for each module
    // Overwrite output filenames with <image>-pmap.tif for pmap generators
    // Publish instance segmentation outputs directly to segmentation/
    inpPM = moduleSeg.map{ it -> String m = "${it.name}Model";
		         tuple(it, params.containsKey(m) ?
		               file(params."$m") : 'built-in') }
        .combine(id_imgs)
        .map{ mod, _2, tag, f -> 
             mod.watershed == 'no' ?
             tuple(tag, mod, _2, f, "${pathSeg}/${mod.name}-${tag}", '') :
             tuple(tag, mod, _2, f, "${pathPM}/${mod.name}", tag + '-pmap.tif') }

    // Run probability map generators and instance segmenters
    // All outputs will be published to probability-maps/
    worker( inpPM, '*.tif', 4 )

    // Merge against precomputed probability maps
    //  and information about whether the module needs watershed
    allpmaps = prepmaps.map{ mtd, f ->
        tuple(Util.getFileID(f, '-pmap'), mtd, f) }
        .mix(worker.out.res)
        .combine( needWS, by:1 )   // changes order to (mtd, tag, f, ws)
    
    // Filter out any workers who published their files to segmentation/
    //   i.e., all the instance segmenters
    // Add nuclear segmentation bypass to those that require it
    id_pmaps = allpmaps.filter{ _1, _2, _3, ws -> ws != 'no' }
        .map{ mtd, tag, _3, ws -> ws == 'bypass' ?
             tuple(tag, mtd, _3, '--nucleiRegion bypass') :
             tuple(tag, mtd, _3, '') }

    // Determine IDs of TMA masks
    // Whole-slide images have no TMA masks
    id_wsi = imgs.map{ f -> tuple(Util.getImageID(f), 'NO_MASK') }
        .filter{ !params.tma }
    id_masks = tmamasks.map{ f -> tuple(Util.getFileID(f,'_mask'), f) }
        .mix(id_wsi)

    // Combine everything based on IDs
    inputs = id_imgs.join(id_masks).combine( id_pmaps, by:0 )
    	.map{ tag, img, msk, mtd, pm, bypass ->
	        tuple("${mtd}-${tag}", img, msk, pm, bypass) }

    // Apply s3seg to probability-maps only
    s3seg(modWS, inputs, pathSeg)

    // Merge against instance segmentation outputs
    instSeg = allpmaps.filter{ _1, _2, _3, ws -> ws == 'no' }
        .map{ mtd, tag, _3, _4 -> tuple("${mtd}-${tag}", _3) }.groupTuple()
    
    emit:

    s3seg.out.segmasks.mix(instSeg)
}

process s3seg {
    container "${params.contPfx}${module.container}:${module.version}"

    // Output
    publishDir "${pubDir}/$tag",
      mode: 'copy', pattern: '*/*.ome.tif', saveAs: {f -> file(f).name}

    // QC
    publishDir "${params.path_qc}/s3seg/$tag",
      mode: 'copy', pattern: '*/qc/**', saveAs: {f -> file(f).name}

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}
    
    input:

    val module
    tuple val(tag), path(core), file('mask.tif'), path(probs)
    val pubDir

    output:
	// output for quantification
        tuple val(tag), path("*/*.ome.tif"), emit: segmasks

        // qc and provenance
        path('*/qc/**')
        tuple path('.command.sh'), path('.command.log')

    when: params.idxStart <= 5 && params.idxStop >= 5
    
    script:
	def crop = params.tma ?
	'--crop dearray --maskPath mask.tif' :
	''
    """
    python /app/S3segmenter.py $crop \
       --imagePath $core --stackProbPath $probs \
       ${params.s3segOpts} --outputPath .
    """
}

include {worker} from './lib/worker'
include {getFileID} from './lib/util'

workflow segmentation {
    take:

    modulePM		// Probability map and instance segmentation modules
    moduleWS		// Watershed module (e.g., S3Segmenter)
    imgs		// Input images
    tmamasks		// TMA masks (if any)
    prepmaps		// Pre-computed probability maps

    main:

    // Determine if there are any custom models for probability map modules
    // Overwrite output filenames with <image>-pmap.tif
    inpPM = modulePM.map{ it -> String m = "${it.name}Model";
		         tuple(it, params.containsKey(m) ?
		               file(params."$m") : 'built-in') }
	.combine(imgs)
        .map{ _1, _2, f -> tuple(_1, _2, f, getFileID(f,'\\.') + '-pmap.tif') }

    // Run probability map generators and instance segmenters
    worker( inpPM, '*.tif', 4, "${params.in}/probability-maps" )

    // Merge against precomputed probability maps
    id_pmaps = prepmaps.map{ mtd, f ->
        tuple(getFileID(f, '-pmap'), mtd, f) }
        .mix(worker.out.res)

    // Determine IDs of images
    id_imgs  = imgs.map{ f -> tuple(getFileID(f,'\\.'), f) }
    
    // Determine IDs of TMA masks
    // Whole-slide images have no TMA masks
    id_wsi = imgs.map{ f -> tuple(getFileID(f,'\\.'), 'NO_MASK') }
	.filter{ !params.tma }
    id_masks = tmamasks.map{ f -> tuple(getFileID(f,'_mask'), f) }
	.mix(id_wsi)

    // Combine everything based on IDs
    inputs = id_imgs.join(id_masks).combine( id_pmaps, by:0 )
	.map{ id, img, msk, mtd, pm ->
	tuple("${mtd}-${img.getBaseName().split('\\.').head()}", img, msk, pm) }

    s3seg(moduleWS, inputs, "${params.in}/segmentation")
    
    emit:

    s3seg.out.segmasks
}

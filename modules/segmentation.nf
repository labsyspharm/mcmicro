process s3seg {
    container "${params.contPfx}${module.container}:${module.version}"

    // Output
    publishDir "${params.pubDir}/$tag",
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
	tuple val(tag), val(method), path(core), file('mask.tif'), path(probs)

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

include {getFileID} from './lib/util'

workflow segmentation {
    take:
      module	
      imgs
      tmamasks
      pmaps

    main:

    // Determine IDs of images
    id_imgs  = imgs.map{ f -> tuple(getFileID(f,'\\.'), f) }

    // Determine IDs of TMA masks
    // Whole-slide images have no TMA masks
    id_wsi = imgs.map{ f -> tuple(getFileID(f,'\\.'), 'NO_MASK') }
	.filter{ !params.tma }
    id_masks = tmamasks.map{ f -> tuple(getFileID(f,'_mask'), f) }
	.mix(id_wsi)

    // Determine IDs of probability maps
    id_pmaps = pmaps.map{ mtd, f ->
	tuple(getFileID(f, '_Probabilities'), f, mtd) }

    // Combine everything based on IDs
    inputs = id_imgs.join(id_masks).combine( id_pmaps, by:0 )
	.map{ id, img, msk, pm, mtd ->
	tuple("${mtd}-${img.getBaseName().split('\\.').head()}", mtd, img, msk, pm) }

    s3seg(module, inputs)
    
    emit:

    s3seg.out.segmasks
}

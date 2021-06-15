process s3seg {
    // Output
    publishDir "${params.pubDir}/$tag",
      mode: 'copy', pattern: '*/*Mask.tif', saveAs: {f -> file(f).name}

    // QC
    publishDir "${params.path_qc}/s3seg/$tag",
      mode: 'copy', pattern: '*/*Outlines.tif', saveAs: {f -> file(f).name}

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}
    
    input:
	tuple val(tag), val(method), path(core), file('mask.tif'), path(probs)

    output:
	// output for quantification
        tuple val(method), path(core), path("**Mask.tif"), emit: segmasks

        // qc and provenance
        path('**')
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
    res = id_imgs.join(id_masks).combine( id_pmaps, by:0 )
	.map{ id, img, msk, pm, mtd ->
	tuple("${mtd}-${img.getBaseName().split('\\.').head()}", mtd, img, msk, pm) }
    
    emit:

    res
//	s3seg.out.segmasks
}

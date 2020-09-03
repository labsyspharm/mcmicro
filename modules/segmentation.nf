process s3seg {
    publishDir "${params.pubDir}/$tag",
      mode: 'copy', pattern: '*/*Mask.tif', saveAs: {f -> file(f).name}
    publishDir "${params.path_qc}/s3seg/$tag",
      mode: 'copy', pattern: '*/*Outlines.tif', saveAs: {f -> file(f).name}

    input:
	tuple val(tag), val(method), path(core), file('mask.tif'), path(probs)

    output:
	// tuples for quantification
        tuple val(method), path(core), path("**${params.maskSpatial}"),
          path("$params.qtym"), emit: segmasks

        // rest of the files for publishDir
        path('**')

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

workflow segmentation {
    take:
	input

    main:
        input.map{ s, c, m, p -> tuple("${s}-${c.getBaseName()}", s, c, m, p) } |
	s3seg

    emit:
	s3seg.out.segmasks
}

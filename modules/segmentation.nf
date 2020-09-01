process s3seg {
    publishDir params.pubDir,             mode: 'copy', pattern: '*/*Mask.tif'
    publishDir "${params.path_qc}/s3seg", mode: 'copy', pattern: '*/*Outlines.tif'

    input:
	tuple val(core), path("${core}"), file('mask.tif'), path(probs)

    output:
	// tuples for quantification
        tuple path("${core}"), path("**${params.maskSpatial}"),
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
	// Determine which masks will be needed by quantification
        masks = params.maskAdd.tokenize()
        switch( masks.size() ) {
          case 0: params.qtym = ""; break;
  	  case 1: params.qtym = "**${masks[0]}"; break;
          default: params.qtym = "**{${masks.join(',')}}"
        }

        input.map{ s, c, m, p -> tuple("${s}-${c.getName()}", c, m, p) } |
	s3seg

    emit:
	s3seg.out.segmasks
}

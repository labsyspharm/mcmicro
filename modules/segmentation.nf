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

workflow segmentation {
    take:
	input

    main:
        include {getFileID} from './lib/util'
    
        input.map{ s, c, m, p ->
	  tuple("${s}-${c.getBaseName().split('\\.').head()}", s, c, m, p) } |
	s3seg

    emit:
	s3seg.out.segmasks
}

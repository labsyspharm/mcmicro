process coreograph {
    publishDir "${params.path_qc}/coreo", mode: 'copy', pattern: 'TMA_MAP.tif'
    publishDir params.pubDir, mode: 'copy', pattern: '**{[0-9],mask}.tif'

    input: path s
    
    output:
      path "**{,[A-Z],[A-Z][A-Z]}{[0-9],[0-9][0-9]}.tif", emit: cores
      path "**_mask.tif", emit: masks
      path "TMA_MAP.tif"

    when: params.idxStart <= 3 && params.idxStop >= 3 && params.tma

    """
    python /app/UNetCoreograph.py ${params.coreOpts}\
      --imagePath $s --outputPath .
    """
}

workflow dearray {
    take:
	tma

    main:
	coreograph(tma)
        id_cores = coreograph.out.cores.flatten().map{ f ->
	    tuple( f.getBaseName().toString().split('\\.tif').head(), f ) }
        id_masks = coreograph.out.masks.flatten().map{ f ->
	    tuple( f.getBaseName().toString().split('_mask').head(), f ) }

    emit:
	s3out = id_cores.join( id_masks ).map{ id, c, m -> tuple(c, m) }
}

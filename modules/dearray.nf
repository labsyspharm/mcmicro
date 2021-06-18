process coreograph {
    // Output
    publishDir params.pubDir, mode: 'copy', pattern: '**{[0-9],mask}.tif'

    // QC
    publishDir "${params.path_qc}/coreo", mode: 'copy', pattern: 'TMA_MAP.tif'
    publishDir "${params.path_qc}/coreo", mode: 'copy', pattern: 'centroidsY-X.txt'
    
    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}
    
    input: path s
    
    output:
      path "**{,[A-Z],[A-Z][A-Z]}{[0-9],[0-9][0-9]}.tif", emit: cores
      path "**_mask.tif", emit: masks
      path "TMA_MAP.tif"
      path "centroidsY-X.txt"
      tuple path('.command.sh'), path('.command.log')    

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

    emit:
        cores = coreograph.out.cores.flatten()
        masks = coreograph.out.masks.flatten()
}

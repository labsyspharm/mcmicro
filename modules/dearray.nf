include { moduleOpts } from "$projectDir/lib/params"

process coreograph {
    container "${params.contPfx}${module.container}:${module.version}"
    
    // Output
    publishDir "${params.in}/dearray", mode: 'copy', pattern: '**{[0-9],mask}.tif'

    // QC
    publishDir "${params.path_qc}/coreo", mode: "${params.qcFiles}",
      pattern: 'TMA_MAP.tif'
    publishDir "${params.path_qc}/coreo", mode: "${params.qcFiles}",
      pattern: 'centroidsY-X.txt'
    
    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}
    
    input:
      val module
      path s
    
    output:
      path "**{,[A-Z],[A-Z][A-Z]}{[0-9],[0-9][0-9]}.tif", emit: cores
      path "**_mask.tif", emit: masks
      path "TMA_MAP.tif"
      path "centroidsY-X.txt"
      tuple path('.command.sh'), path('.command.log')    

    when: params.idxStart <= 3 && params.idxStop >= 3 && params.tma

    """
    ${module.cmd} ${module.input} $s ${moduleOpts(module, params)}
    """
}

workflow dearray {
  take:
    module
    tma

  main:
    coreograph(module, tma)

  emit:
    cores = coreograph.out.cores.flatten()
    masks = coreograph.out.masks.flatten()
}

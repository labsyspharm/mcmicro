import mcmicro.*

process coreograph {
    container "${params.contPfx}${module.container}:${module.version}"
    
    // Output
    publishDir "${params.in}/dearray", mode: 'copy', pattern: '**{[0-9],mask}.tif'

    // QC
    publishDir "${Paths.QC(params.in, module.name)}", mode: "${params.qcFiles}", 
      pattern: '{TMA_MAP.tif,centroidsY-X.txt}'
    
    // Provenance
   publishDir "${Paths.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> Util.cleanFilename(fn.replace('.command', task.name))}
    
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
    ${module.cmd} ${module.input} $s ${Opts.moduleOpts(module, params)}
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

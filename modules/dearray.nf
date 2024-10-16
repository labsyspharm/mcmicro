import mcmicro.*

process coreograph {
    container "${params.contPfx}${module.container}:${module.version}"
    
    // Output
    publishDir "${params.in}/dearray", mode: "${params.publish_dir_mode}",
      pattern: '{*.ome.tif,**mask.tif}'

    // QC
    publishDir "${Flow.QC(params.in, module.name)}",
      mode: "${mcp.workflow['qc-files']}", pattern: '{TMA_MAP.tif,centroidsY-X.txt}'
    
    // Provenance
   publishDir "${Flow.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> fn.replace('.command', "${module.name}")}
    
    input:
      val mcp
      val module
      path s
    
    output:
      path "*.ome.tif", emit: cores
      path "**_mask.tif", emit: masks
      path "TMA_MAP.tif"
      path "centroidsY-X.txt"
      tuple path('.command.sh'), path('.command.log')    

    when: Flow.doirun('dearray', mcp.workflow)

    """
    ${module.cmd} ${module.input} $s ${Opts.moduleOpts(module, mcp)}
    """
}

workflow dearray {
  take:
    mcp     // MCMICRO parameters (as returned by Opts.parseParams())
    tma     // Image of the entire TMA

  main:
    coreograph(mcp, mcp.modules['dearray'], tma)

  emit:
    cores = coreograph.out.cores.flatten()
    masks = coreograph.out.masks.flatten()
}

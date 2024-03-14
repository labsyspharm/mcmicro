import mcmicro.*

include {roadie} from "$projectDir/roadie"

process coreograph {
    container "${params.contPfx}${module.container}:${module.version}"
    
    // Output -- publish masks only, images need to be pyramidized
    publishDir "${params.in}/dearray", mode: "${params.publish_dir_mode}",
      pattern: '**mask.tif'

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
      path "**{,[A-Z],[A-Z][A-Z]}{[0-9],[0-9][0-9]}.tif", emit: cores
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

    // Pass the core images through palom to pyramidize them
    inputs = coreograph.out.cores.flatten()
    roadie('pyramidize', inputs, '', true, "${params.in}/dearray", "${params.publish_dir_mode}")

  emit:
    cores = roadie.out
    masks = coreograph.out.masks.flatten()
}

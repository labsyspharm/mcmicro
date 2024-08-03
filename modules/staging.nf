import mcmicro.*

import groovy.text.GStringTemplateEngine

process phenoimager2mc {
    // Use the container specification from the parameter file
    container "${params.contPfx}${module.container}:${module.version}"
    publishDir "${params.in}/raw", mode: "${params.publish_dir_mode}",
      pattern: '*.tif'
    
    // Provenance
    publishDir "${Flow.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> fn.replace('.command', "${module.name}")}
    
    input:
      val mcp
      val module
      tuple val(cycle), path(indir), path(marker)

    output:
      tuple val(cycle), path("*.tif"), emit: img
      tuple path('.command.sh'), path('.command.log')

    when: Flow.doirun('staging', mcp.workflow)
    
    script:
      def formatMap = [
        marker: marker,
        cycle: cycle,
        indir: indir,
      ]

      def command = new GStringTemplateEngine()
        .createTemplate(module.cmd)
        .make(formatMap)
        .toString()

      """
      ${command} ${Opts.moduleOpts(module, mcp)}
      """
}

workflow staging {
    take:
      mcp     // MCMICRO parameters as read by Opts.parseParams()
      indir   // input directories
      marker  // marker file

    main:
      inputs = indir
        .combine(marker)

      phenoimager2mc(mcp, mcp.modules['staging'], inputs)

    emit:
      phenoimager2mc.out.img
}

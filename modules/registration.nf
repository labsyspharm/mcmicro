import mcmicro.*

process ashlar {

    time '4hours'
    memory '60 GB'
    executor 'sge'

    container "${params.contPfx}${module.container}:${module.version}"
    publishDir "${params.in}/registration", mode: 'copy', pattern: '*.tif'
    
    // Provenance
    publishDir "${Flow.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> fn.replace('.command', "${module.name}")}
    
    input:
      val mcp
      val module
      val sampleName
      path lraw       // Only for staging
      val lrelPath    // Use this for paths
      path lffp
      path ldfp

    output:
      path "*.ome.tif", emit: img
      tuple path('.command.sh'), path('.command.log')

    when: Flow.doirun('registration', mcp.workflow)
    
    script:
    def imgs = lrelPath.collect{ Util.escapeForShell(it) }.join(" ")
    def ilp = "--ffp $lffp --dfp $ldfp"
    if (ilp == '--ffp  --dfp ') ilp = ''  // Don't supply empty --ffp --dfp
    """
    ashlar $imgs ${Opts.moduleOpts(module, mcp)} $ilp -o ${sampleName}.ome.tif
    """
}

workflow registration {
    take:
      mcp     // MCMICRO parameters as read by Opts.parseParams()
      raw     // raw image tiles
      ffp     // flat-field profiles
      dfp     // dark-field profiles

    main:
      rawst = raw.toSortedList{a, b -> a[0] <=> b[0]}.transpose()
      sampleName  = file(params.in).name

      ashlar(
        mcp,
        mcp.modules['registration'],
        sampleName,
        rawst.first(),
        rawst.last(),
        ffp.toSortedList{a, b -> a.getName() <=> b.getName()},
        dfp.toSortedList{a, b -> a.getName() <=> b.getName()}
      )

    emit:
      ashlar.out.img
}

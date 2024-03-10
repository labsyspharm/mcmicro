import mcmicro.*

process ashlar {
    container "${params.contPfx}${module.container}:${module.version}"
    publishDir "${params.in}/registration", mode: "${params.publish_dir_mode}",
      pattern: '*.tif'
    
    // Provenance
    publishDir "${Flow.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> fn.replace('.command', "${module.name}")}
    
    input:
      val mcp
      val module
      tuple val(sampleName), path(lraw), val(lrelPath), path(lffp), path(ldfp)

    output:
      path "*.ome.tif", emit: img
      tuple path('.command.sh'), path('.command.log')

    when: Flow.doirun('registration', mcp.workflow)
    
    script:
      // Options
      def opts = Opts.moduleOpts(module, mcp)
        .replace('{samplename}', sampleName)

      // Images
      def imgs = opts.contains("filepattern|") || opts.contains("fileseries|") ? "" :
        lrelPath.collect{ Util.escapeForShell(it) }.join(" ")

      // Illumination profiles
      def ilp = "--ffp $lffp --dfp $ldfp"
      if (ilp == '--ffp  --dfp ') ilp = ''  // Don't supply empty --ffp --dfp

    """
    ashlar $imgs $opts $ilp -o ${sampleName}.ome.tif
    """
}

workflow registration {
    take:
      mcp     // MCMICRO parameters as read by Opts.parseParams()
      raw     // raw image tiles
      ffp     // flat-field profiles
      dfp     // dark-field profiles

    main:

    srt = {a, b -> file(a).getName() <=> file(b).getName()}

    rawg = raw.groupTuple(sort: srt)
    ffpg = ffp.groupTuple(sort: srt)
    dfpg = dfp.groupTuple(sort: srt)

    inputs = rawg.join(ffpg, remainder:true).join(dfpg, remainder:true)
      .map{tuple(
        it[0], it[1], it[2],
        it[3] == null ? [] : it[3],    // Convert null to empty list
        it[4] == null ? [] : it[4]     // Ditto
      )}

    ashlar(mcp, mcp.modules['registration'], inputs)

    emit:
      ashlar.out.img
}

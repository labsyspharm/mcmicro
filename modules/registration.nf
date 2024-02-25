import mcmicro.*

// Here we assemble tuples of 1) sample name, 2) path to stage for each raw image
// (might be a directory) and 3) relative path to the main file for each image. 
// Processes must input the first as a path and the second as a val to avoid incorrect
// or redundant file staging. They must also only use the second (relative) path to
// construct pathnames for scripts etc. mcmicro.Util.escapePathForShell must be
// used when interpolating these paths into script strings, as we are bypassing
// the normal way that paths are passed to channels which handles this escaping
// automatically.
def prepare(x, wfp) {
  rawdir = file("${params.in}/raw")
  formatType = file("${rawdir}/**${wfp['multi-formats']}") ? 'multi' : 'single'
  x.map{ tuple(
      Util.getSampleName(it, rawdir),
      formatType == "single" ? it : it.parent, 
      it) 
    }
    .map{ sampleName, toStage, relPath -> 
      tuple(sampleName, toStage, toStage.parent.relativize(relPath).toString()) }
}

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
      // Options
      def opts = Opts.moduleOpts(module, mcp)

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

    rawPrep = prepare(raw, mcp.workflow).groupTuple(sort: true)

/*      ashlar(
        mcp,
        mcp.modules['registration'],
        rawPrep,
        ffp.toSortedList{a, b -> a.getName() <=> b.getName()},
        dfp.toSortedList{a, b -> a.getName() <=> b.getName()}
      )*/

    emit:
//      ashlar.out.img
      rawPrep
}

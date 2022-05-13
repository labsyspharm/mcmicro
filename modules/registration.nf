import mcmicro.Util

include { moduleOpts }     from "$projectDir/lib/params"

process ashlar {
    container "${params.contPfx}${module.container}:${module.version}"
    publishDir "${params.in}/registration", mode: 'copy', pattern: '*.tif'
    
    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}
    
    input:
      val module
      path lraw    // Only for staging
      val lrelPath // Use this for paths
      path lffp
      path ldfp

    output:
      path "${params.sampleName}.ome.tif", emit: img
      tuple path('.command.sh'), path('.command.log')

    when: params.idxStart <= 2 && params.idxStop >= 2
    
    script:
    def imgs = lrelPath.collect{ Util.escapeForShell(it) }.join(" ")
    def ilp = "--ffp $lffp --dfp $ldfp"
    if (ilp == '--ffp  --dfp ') ilp = ''  // Don't supply empty --ffp --dfp
    "ashlar $imgs ${moduleOpts(module)} $ilp -o ${params.sampleName}.ome.tif"
}

workflow registration {
    take:
      module
      raw
      ffp
      dfp

    main:
      rawst = raw.toSortedList{a, b -> a[0] <=> b[0]}.transpose()
      ashlar(
	module,
        rawst.first(),
        rawst.last(),
        ffp.toSortedList{a, b -> a.getName() <=> b.getName()},
        dfp.toSortedList{a, b -> a.getName() <=> b.getName()}
      )

    emit:
      ashlar.out.img
}

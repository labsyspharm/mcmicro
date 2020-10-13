process ashlar {
    publishDir params.pubDir, mode: 'copy', pattern: '*.tif'
    
    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}
    
    input:
      path lraw
      path lffp
      path ldfp

    output:
	path "${params.sampleName}.ome.tif", emit: img
        tuple path('.command.sh'), path('.command.log')

    when: params.idxStart <= 2 && params.idxStop >= 2
    
    script:
    def ilp = "--ffp $lffp --dfp $ldfp"
    if (ilp == '--ffp  --dfp ') ilp = ''  // Don't supply empty --ffp --dfp 
    "ashlar $lraw ${params.ashlarOpts} $ilp --pyramid -f ${params.sampleName}.ome.tif"
}

workflow registration {
    take:
      raw
      ffp
      dfp

    main:
      ashlar( 
        raw.toSortedList(),
        ffp.toSortedList{a, b -> a.getName() <=> b.getName()},
        dfp.toSortedList{a, b -> a.getName() <=> b.getName()}
      )

    emit:
      ashlar.out.img
}

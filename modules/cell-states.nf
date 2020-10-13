process naivestates {
    // Output
    publishDir params.pubDir, mode: 'copy', pattern: '*.csv'
    publishDir params.pubDir, mode: 'copy', pattern: 'plots/*.*'

    // QC
    publishDir "${params.path_qc}/naivestates", mode: 'copy',
      pattern: 'plots/*/*.*', saveAs: { fn -> fn.replaceFirst("plots/","") }

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}
    
    input:  path(counts)
    output:
	path('**')
        tuple path('.command.sh'), path('.command.log')


    when: params.idxStart <= 7 && params.idxStop >= 7

    """
    /app/main.R -i $counts -o . ${params.nstatesOpts} \
    --mct /app/typemap.csv
    """
}


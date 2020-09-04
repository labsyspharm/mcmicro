process naivestates {
    publishDir params.pubDir, mode: 'copy', pattern: '*.csv'
    publishDir params.pubDir, mode: 'copy', pattern: 'plots/*.*'

    publishDir "${params.path_qc}/naivestates", mode: 'copy',
      pattern: 'plots/*/*.*', saveAs: { fn -> fn.replaceFirst("plots/","") }
    
    input:  path(counts)
    output: path('**')

    when: params.idxStart <= 7 && params.idxStop >= 7

    """
    /app/main.R -i $counts -o . ${params.nstatesOpts} \
    --mct /app/typemap.csv
    """
}


process quantification {
    publishDir params.pubDir, mode: 'copy', pattern: '*.csv'

    input:  tuple path(core), path(maskSpt), path(maskAdd), path(ch)
    output: path('*.csv')

    when: params.idxStart <= 6 && params.idxStop >= 6

    """
    python /app/CommandSingleCellExtraction.py \
    --mask $maskSpt $maskAdd --image $core \
    ${params.quantOpts} --output . --channel_names $ch
    """
}

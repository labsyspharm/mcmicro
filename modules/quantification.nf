process quantification {
    publishDir params.pubDir, mode: 'copy', pattern: '*.csv'
    
    input:
	tuple val(tag), path("$tag"),
          path(maskSpt), path(maskAdd), path(ch)
    output: path('*.csv')

    when: params.idxStart <= 6 && params.idxStop >= 6

    """
    python /app/CommandSingleCellExtraction.py \
    --mask $maskSpt $maskAdd --image $tag \
    ${params.quantOpts} --output . --channel_names $ch
    """
}


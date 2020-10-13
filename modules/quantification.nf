process quantification {
    // Output
    publishDir params.pubDir, mode: 'copy', pattern: '*.csv'

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}
    
    input:
	tuple val(tag), path("$tag"),
          path(maskSpt), path(maskAdd), path(ch)
    output:
	path '*.csv', emit: tables
        tuple path('.command.sh'), path('.command.log')

    when: params.idxStart <= 6 && params.idxStop >= 6

    """
    python /app/CommandSingleCellExtraction.py \
    --mask $maskSpt $maskAdd --image $tag \
    ${params.quantOpts} --output . --channel_names $ch
    """
}


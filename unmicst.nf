#!/usr/bin/env nextflow

tool_unmicst = "$HOME/projects/UnMicst"

cores = Channel.fromPath( "$HOME/test/exemplar-002/dearray/*.tif" )

println "Project : $workflow.projectDir"

process unmicst {
    conda "${workflow.projectDir}/conda/unmicst.yml"
    publishDir "$HOME/test/exemplar-002/prob_maps", mode: 'copy'
    
    input:
    file cores
    
    output:
    file '*.tif'

    """
    python ${tool_unmicst}/UnMicst.py $cores --outputPath .
    """
}

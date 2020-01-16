#!/usr/bin/env nextflow

params.tools = "$HOME/mcmicro"

process coreograph {
    publishDir params.tools, mode: 'copy'

    output:
    file '**' into tool_core
    
    """
    git clone https://github.com/HMS-IDAC/Coreograph.git
    cd Coreograph
    git checkout e21b137e9bde2b95f0402836bd9bb2658f436aea
    """
}

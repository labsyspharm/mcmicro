#!/usr/bin/env nextflow

params.tools = "$HOME/mcmicro"

process setup_coreograph {
    publishDir params.tools, mode: 'copy'

    output:
    file '**' into tool_core
    
    """
    git clone https://github.com/HMS-IDAC/Coreograph.git
    cd Coreograph
    git checkout e21b137e9bde2b95f0402836bd9bb2658f436aea
    curl -o TMAsegmentation/model1.mat https://mcmicro.s3.amazonaws.com/models/model1.mat
    """
}

process setup_unmicst {
    publishDir params.tools, mode: 'copy'

    output:
    file '**' into tool_unmicst

    """
    git clone https://github.com/HMS-IDAC/UnMicst.git
    cd UnMicst
    git checkout 94139df231e9092f678cc24a714f83af2bf2033a
    """
}

#!/usr/bin/env nextflow

params.tools = "$HOME/mcmicro"

process setup_coreograph {
    publishDir params.tools, mode: 'copy'

    output:
    file '**' into tool_core
    
    """
    git clone https://github.com/HMS-IDAC/Coreograph.git
    cd Coreograph
    git checkout 8bb702c0b1f36c81fa15efe2095aeb425caee7fb
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

process setup_s3segmenter {
    publishDir params.tools, mode: 'copy'

    output:
    file '**' into tool_s3seg

    """
    git clone https://github.com/HMS-IDAC/S3segmenter.git
    cd S3segmenter
    git checkout 6118c586d5af594a30b9822412ac6b4224de4a36
    """
}

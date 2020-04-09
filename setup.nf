#!/usr/bin/env nextflow

process setup_illumination {
    executor 'local'
    publishDir params.tools, mode: 'copy'

    output:
    file '**' into tool_ilp

    when:
    workflow.profile == "O2"
    
    """
    wget https://downloads.imagej.net/fiji/latest/fiji-linux64.zip && \
      unzip fiji-linux64.zip && rm fiji-linux64.zip

    wget https://www.helmholtz-muenchen.de/fileadmin/ICB/software/BaSiC/BaSiCPlugin.zip && \
      unzip BaSiCPlugin.zip && \
      mv BaSiCPlugin/BaSiC_.jar Fiji.app/plugins/ && \
      mv BaSiCPlugin/Dependent/*.jar Fiji.app/jars/ && \
      rm -r BaSiCPlugin.zip BaSiCPlugin __MACOSX

    rm Fiji.app/jars/jtransforms-2.4.jar

    git clone https://github.com/labsyspharm/basic-illumination.git
    cd basic-illumination
    git checkout tags/${params.illumVersion}
    """
}

process setup_coreograph {
    executor 'local'
    publishDir params.tools, mode: 'copy'

    output:
    file '**' into tool_core
    
    """
    git clone https://github.com/HMS-IDAC/Coreograph.git
    cd Coreograph
    git checkout c4bd1432c3e01771f08ef6fed99d6bf5a98d37ef
    curl -o TMAsegmentation/model1.mat https://mcmicro.s3.amazonaws.com/models/model1.mat
    """
}

process setup_unmicst {
    executor 'local'
    publishDir params.tools, mode: 'copy'

    output:
    file '**' into tool_unmicst

    when:
    workflow.profile == "O2"

    """
    git clone https://github.com/HMS-IDAC/UnMicst.git
    cd UnMicst
    git checkout tags/${params.unmicstVersion}
    """
}

process setup_s3segmenter {
    executor 'local'
    publishDir params.tools, mode: 'copy'

    output:
    file '**' into tool_s3seg

    when:
    workflow.profile == "O2"
    
    """
    git clone https://github.com/HMS-IDAC/S3segmenter.git
    cd S3segmenter
    git checkout tags/${params.s3segVersion}
    """
}

process setup_quantification {
    executor 'local'
    publishDir params.tools, mode: 'copy'

    output:
    file '**' into tool_quant

    when:
    workflow.profile == "O2"

    """
    git clone https://github.com/labsyspharm/quantification
    cd quantification
    git checkout tags/${params.quantVersion}
    """
}

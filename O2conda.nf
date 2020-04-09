#!/usr/bin/env nextflow
process conda_ashlar {
    executor 'local'

    when:
    workflow.profile == "O2"

    """
    conda env create -f $baseDir/conda/ashlar.yml -p ${params.O2base}/conda/ashlar
    """
}

process conda_unmicst {
    executor 'local'
    
    when:
	workflow.profile == "O2"
    
    """
    conda env create -f $baseDir/conda/unmicst.yml -p ${params.O2base}/conda/unmicst
    """
}

process conda_s3seg {
    executor 'local'
    
    when:
	workflow.profile == "O2"
    
    """
    conda env create -f $baseDir/conda/s3seg.yml -p ${params.O2base}/conda/s3seg
    """
}

process conda_quant {
    executor 'local'
    
    when:
	workflow.profile == "O2"
    
    """
    conda env create -f $baseDir/conda/quantification.yml -p ${params.O2base}/conda/quantification
    """    
}

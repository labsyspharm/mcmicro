/*
 * pipeline input parameters
*/
// params.datadir = "$projectDir/data/input/"
params.input_dir = "$projectDir/data/Registered"
params.register_dir = "/Registered"
params.codebook = "$projectDir/data/codebook.json"


log.info """\
    SPATIAL TRANSCRIPTOMICS PIPELINE
    ================================
    test : ${params.test}  
    input datadir: ${params.input_dir}
    """
    .stripIndent()

// nextflow.enable.dsl=2

process TILING {

  input:
  path x

  output:
  path 'Tiled'
//  path '*_results'

  script:
  """
  python $projectDir/bin/tiling.py -i ${x} 
  """
}

process TO_SPACETX {

  input:
  path TILED

  output:
  path SpaceTx
//  path 'data_results'

  script:
  """
  python $projectDir/bin/format_to_spacetx.py -i $TILED
  """
}

process DECODE {

  input:
  path SpaceTx

  output:
  stdout
//  path 'SpaceTx'
//  path 'data_results'

  script:
  """
  python $projectDir/bin/decoding.py
  """
}
workflow {
  tiling_ch = TILING(params.input_dir)
  tiling_ch.view()
  spacetx_ch = TO_SPACETX(tiling_ch)
//  tiling_ch = TO_SPACETX()
//  decoding_ch = DECODE()
//  decoding_ch.view()
//  test_name = Channel.from(params.test)
//  sample_in = Channel.from(params.sample_name)
//  script_file = Channel.fromPath(params.script_Python_Registration)  
//  last_channel = Channel.from(image_registration(test_name))
//  TILING(result_ch)
}

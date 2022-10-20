/*
 * pipeline input parameters
*/
// params.datadir = "$projectDir/data/input/"
params.input_dir = "$projectDir"
params.register_dir = "/Registered"
params.codebook = "$projectDir/data/codebook.json"
// params.output = "$projectDir/data/output"
// params.script_Python_Registration  = './code/python/registration.py'
log.info """\
    SPATIAL TRANSCRIPTOMICS PIPELINE
    ================================
    test : ${params.test}  
//    input datadir: ${params.datadir}
//    sample name  : ${params.sample_name}
//    outdir       : ${params.output}
//    project dir  : ${projectDir}
    """
    .stripIndent()

// nextflow.enable.dsl=2

process image_registration {
  publishDir "$params.output", mode: 'copy', overwrite: true

  input:
  val x
//  val y
//  path y
//  path x
//  val datadir_in
//  val sample_in

  output:
//  stdout
  path 'Registered'

  script:
  """
  python $projectDir/bin/python_draft.py -t ${x} -o 'Registered'
  """
}


process TILING_TEST {

  input:
//  path prev_img

  output:
  path 'Tiled'
//  path '*_results'

  script:
  """
  python $projectDir/bin/to_spacetx_print_results.py
  """
}                  

process TILING {

  input:
  path x

  output:
  path Tiled
//  path '*_results'

  script:
  """
  python $projectDir/bin/tiling_test.py -s data -d $projectDir -p ${x}
  """
}

process TO_SPACETX {

  input:
  path x

  output:
//  path 'SpaceTx'
//  path 'data_results'

  script:
  """
  python $projectDir/bin/to_spacetx.py -i $projectDir -c ${x}
  """
}


workflow {
  tiling_ch = TILING(params.register_dir)
  tiling_ch.view()
//  tiling_ch.view()
//  result_spacetx = TO_SPACETX(params.codebook)
//  final_process = RESULT(result_spacetx.out)
//  result_spacetx.view{}
//  result_ch = image_registration(params.test)
//  result_ch.view()
//  test_name = Channel.from(params.test)
//  sample_in = Channel.from(params.sample_name)
//  script_file = Channel.fromPath(params.script_Python_Registration)  
//  last_channel = Channel.from(image_registration(test_name))
//  TILING(result_ch)
}

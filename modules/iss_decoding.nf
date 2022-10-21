// Import utility functions from lib/mcmicro/*.groovy
import mcmicro.*

process starfish_tile {

    container "${params.contPfx}${module.container}:${module.version}"
    publishDir "${params.in}/iss_processing", mode: 'copy', pattern: "*.tif"

    publishDir "${Flow.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> fn.replace('.command', "${module.name}-${task.index}")}

  input:
    val mcp
    val module
    path code_tile

  output:
    path("*.json"), emit: results

    tuple path('.command.sh'), path('.command.log')

  when: mcp.workflow["iss_decoding"]

    """    
    python $code_tile ${Opts.moduleOpts(module, mcp)}
    """
}

process starfish_convert {

    container "${params.contPfx}${module.container}:${module.version}"
    publishDir "${params.in}/iss_processing", mode: 'copy', pattern: "*.tif"

    publishDir "${Flow.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> fn.replace('.command', "${module.name}-${task.index}")}

  input:
    val mcp
    val module
    path code_convert

  output:
    path("*.json"), emit: results

    tuple path('.command.sh'), path('.command.log')

  when: mcp.workflow["iss_decoding"]

    """    
    python $code_convert ${Opts.moduleOpts(module, mcp)}
    """
}

process starfish_decode {

    // Use the container specification from the parameter file
    // No change to this line is required
    container "${params.contPfx}${module.container}:${module.version}"
    
    // Specify the project subdirectory for writing the outputs to
    // The pattern: specification must match the output: files below
    // TODO: replace report with the desired output directory
    // TODO: replace the pattern to match the output: clause below
    publishDir "${params.in}/iss_processing", mode: 'copy', pattern: "*.tif"

    // Stores .command.sh and .command.log from the work directory
    //   to the project provenance
    // No change to this line is required
    publishDir "${Flow.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> fn.replace('.command', "${module.name}-${task.index}")}

    // Inputs for the process
    // mcp - MCMICRO parameters (workflow, options, etc.)
    // module - module specifications (name, container, options, etc.)
    // img/sft - pairs of images and their matching spatial feature tables
  input:
    val mcp
    val module
    path code_decode

    // Process outputs that should be captured and 
    //  a) returned as results
    //  b) published to the project directory
    // TODO: replace *.html with the pattern of the tool output files
  output:
    path("*.json"), emit: results

    // Provenance files -- no change is needed here
    tuple path('.command.sh'), path('.command.log')

    // Specifies whether to run the process
    // Here, we simply take the flag from the workflow parameters
    // TODO: change snr to match the true/false workflow parameter in defaults.yml
  when: mcp.workflow["iss_decoding"]

    // The command to be executed inside the tool container
    // The command must write all outputs to the current working directory (.)
    // Opts.moduleOpts() will identify and return the appropriate module options
    """    
    python $code_decode ${Opts.moduleOpts(module, mcp)}
    """
}

workflow starfish {

    // Inputs:
    // mcp - MCMICRO parameters (workflow, options, etc.)
    // imgs - images
    // cbk - Codebook
  take:
    mcp

  main:

    // Apply the process to each (image, sft) pair

    // code_tile = Channel.fromPath("$projectDir/starfish/bin/decoding.py")
    ///code_convert = Channel.fromPath("$projectDir/starfish/bin/decoding.py")
    
    code_decode = Channel.fromPath("$projectDir/starfish/bin/decoding.py")
    starfish_decode(mcp,mcp.modules['iss_decoding'],code_decode)

    // Return the outputs produced by the tool
  emit:
    starfish_decode.out.results
}
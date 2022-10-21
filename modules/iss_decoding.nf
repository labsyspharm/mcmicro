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
    path img_dir

  output:
    path 'TILED'
    tuple path('.command.sh'), path('.command.log')

  when: mcp.workflow["iss_decoding"]

    """
    python $code_tile --input ${img_dir} --output TILED
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
    path code
    path TILED

  output:
    path 'SpaceTx'
    tuple path('.command.sh'), path('.command.log')

  when: mcp.workflow["iss_decoding"]

    """
    python $code -i $TILED -o SpaceTx
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
    publishDir "${params.in}/iss_processing", mode: 'copy', pattern: "*.csv"

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
    path code
    path SpaceTx

    // Process outputs that should be captured and
    //  a) returned as results
    //  b) published to the project directory
    // TODO: replace *.html with the pattern of the tool output files
  output:
    path("*.csv"), emit: results

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
    python $code -i SpaceTx
    """
}

workflow starfish {

    // Inputs:
    // mcp - MCMICRO parameters (workflow, options, etc.)
    // imgs - images
    // cbk - Codebook
  take:
    mcp
    img_dir

  main:

    // Apply the process to each (image, sft) pair

    // code_tile = Channel.fromPath("$projectDir/starfish/bin/decoding.py")
    ///code_convert = Channel.fromPath("$projectDir/starfish/bin/decoding.py")
    
    code_tile = Channel.fromPath("$projectDir/starfish/bin/tiling.py")
    TILED = starfish_tile(mcp, mcp.modules['iss_decoding'], code_tile, img_dir)

    println TILED
    code_convert = Channel.fromPath("$projectDir/starfish/bin/format_to_spacetx.py")
    SpaceTx = starfish_convert(mcp, mcp.modules['iss_decoding'], code_convert, TILED[0])

    code_decode = Channel.fromPath("$projectDir/starfish/bin/decoding.py")
    results = starfish_decode(mcp, mcp.modules['iss_decoding'], code_decode, SpaceTx[0])
    // Return the outputs produced by the tool

  emit:
    results[0]
}
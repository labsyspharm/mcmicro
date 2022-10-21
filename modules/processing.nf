// Import utility functions from lib/mcmicro/*.groovy
import mcmicro.*

// Process name will appear in the the nextflow execution log
// While not strictly required, it's a good idea to make the 
//   process name match your tool name to avoid user confusion
process backsub {

    // Use the container specification from the parameter file
    // No change to this line is required
    container "${params.contPfx}${module.container}:${module.version}"

    // Specify the project subdirectory for writing the outputs to
    // The pattern: specification must match the output: files below
    // TODO: replace report with the desired output directory
    // TODO: replace the pattern to match the output: clause below
    publishDir "${params.in}/processing", mode: 'copy', pattern: "bsub_out.ome.tif"
    publishDir "${params.in}/processing", mode: 'copy', pattern: "markers_out.csv"

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
    path(chMrk)
    val module
    path(pre_img)

    // Process outputs that should be captured and 
    //  a) returned as results
    //  b) published to the project directory
    // TODO: replace *.html with the pattern of the tool output files
  output:
    // Output background subtracted image and markers.csv as tuple
    tuple path('*.ome.tif'), path('*.csv'), emit: result
    // Provenance files -- no change is needed here
    tuple path('.command.sh'), path('.command.log')

    // Specifies whether to run the process
    // Here, we simply take the flag from the workflow parameters
  when: mcp.workflow["bsub_test"]

    // The command to be executed inside the tool container
    // The command must write all outputs to the current working directory (.)
    // Opts.moduleOpts() will identify and return the appropriate module options
    """    
    python /background_sub.py -r $pre_img -o /processing/bsub_out.ome.tif -m $chMrk -mo /processing/markers_out.csv ${Opts.moduleOpts(module, mcp)}
    """
}

workflow bsub_test {
  
    // Inputs:
    // mcp - MCMICRO parameters (workflow, options, etc.)
    // imgs - images
    // sfts - spatial feature tables
  take:
    mcp
    pre_img
    chMrk
  main:
    // find way to write inputs for function
    backsub(mcp, chMrk, mcp.modules['bsub_test'], pre_img)

    // Return the outputs produced by the tool
  emit:
    backsub.out.result
}

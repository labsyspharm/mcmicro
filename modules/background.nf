// Import utility functions from lib/mcmicro/*.groovy
import mcmicro.*

// Process name will appear in the the nextflow execution log
// While not strictly required, it's a good idea to make the 
//   process name match your tool name to avoid user confusion
process backsub {

    // Use the container specification from the parameter file
    container "${params.contPfx}${module.container}:${module.version}"

    // Specify the project subdirectory for writing the outputs to
    // The pattern: specification must match the output: files below
    // Subdirectory: background
    // Hardcoded output file names
    publishDir "${params.in}/background", mode: 'copy', pattern: "*.ome.tif"
    publishDir "${params.in}/background", mode: 'copy', pattern: "*.csv"

    // Stores .command.sh and .command.log from the work directory
    //   to the project provenance
    // No change to this line is required
    publishDir "${Flow.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> fn.replace('.command', "${module.name}-${task.index}")}
    
    // Inputs for the process
    // mcp - MCMICRO parameters (workflow, options, etc.)
    // module - module specifications (name, container, options, etc.)
    // path to the markers.csv
    // path to the registered image
  input:
    val mcp
    val module
    path(marker)
    path(image)

    // outputs are returned as results with appropriate patterns
  output:
    // Output background subtracted image and markers.csv
    path('*.ome.tif'), emit: image_out
    path('*.csv'), emit: marker_out
    // Provenance files
    tuple path('.command.sh'), path('.command.log')

    // Specifies whether to run the process
    // Here, we simply take the flag from the workflow parameters
  when: mcp.workflow["background"]

    // The command to be executed inside the tool container
    // The command must write all outputs to the current working directory (.)
    // Opts.moduleOpts() will identify and return the appropriate module options
    """
    /opt/conda/bin/python /tmp/background_sub.py -o ./background_subtracted_image.ome.tif -mo ./markers_bs.csv -r $image -m $marker ${Opts.moduleOpts(module, mcp)}
    """
}
workflow background {
  
    // Inputs:
    // mcp - MCMICRO parameters (workflow, options, etc.)
    // image - image
    // marker - marker file
  take:
    mcp // MCMICRO parameters (workflow, options, etc.)
    image // image to apply background subtraction to
    marker // marker file
  main:
    // run the backsub process with the mcmicro parameters, module value
    // markers path and pre-registered image path
    backsub(mcp, mcp.modules['background'], marker, image)
    
    // Return the outputs produced by the tool
  emit:
    backsub.out.image_out
    backsub.out.marker_out
}

// Import utility functions from lib/mcmicro/*.groovy
import mcmicro.*

// For nested string formatting
import groovy.text.GStringTemplateEngine

// Process name will appear in the the nextflow execution log
// While not strictly required, it's a good idea to make the 
//   process name match your tool name to avoid user confusion
process backsub {

    // Use the container specification from the parameter file
    container "${params.contPfx}${module.container}:${module.version}"

    // Specify the project subdirectory for writing the outputs to
    // The pattern: specification must match the output: files below
    // Subdirectory: background
    publishDir "${params.in}/background", mode: 'copy', pattern: "*.ome.tif"
    publishDir "${params.in}/background", mode: 'copy', pattern:'markers_bs.csv'

    // Stores .command.sh and .command.log from the work directory
    //   to the project provenance
    // No change to this line is required
    publishDir "${Flow.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> fn.replace('.command', "${module.name}-${task.index}")}
    
  // Inputs for the process
  // mcp - MCMICRO parameters (workflow, options, etc.)
  // module - module specifications (name, container, options, etc.)
  // tuple - image file ID, image file path, markers.csv file path
  input:
    val mcp
    val module
    tuple val(image_id), path(image), path(marker)

  // outputs are returned as results with appropriate patterns
  output:
    // Output background subtracted image and markers_bs.csv
    path("*.ome.tif"), emit: image_out
    path('markers_bs.csv'), emit: marker_out
    // Provenance files
    tuple path('.command.sh'), path('.command.log')

  // Specifies whether to run the process
  // Here, we simply take the flag from the workflow parameters
  when: mcp.workflow["background"]

  script:
    // String replacement Map for the syntax of ${variable_name} in
    //   module.cmd
    def formatMap = [
      marker: marker,
      image_id: image_id,
      image: image,
    ]
    def command = new GStringTemplateEngine()
      .createTemplate(module.cmd)
      .make(formatMap)
      .toString()

    """
    $command ${Opts.moduleOpts(module, mcp)}
    """
}

workflow background {
  
  // Inputs:
  take:
    mcp // MCMICRO parameters (workflow, options, etc.)
    imgs // images to apply background subtraction to
    marker // marker file

  main:
    // Assemble inputs from multiple channels
    inputs = imgs
      .map{ f -> tuple(Util.getImageID(f), f) }
      .combine(marker)
    backsub(mcp, mcp.modules['background'], inputs)
    
  // Return the outputs produced by the tool
  emit:
    image = backsub.out.image_out
    marker = backsub.out.marker_out
}
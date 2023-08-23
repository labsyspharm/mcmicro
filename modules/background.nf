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
    // path to the markers.csv
    // path to the registered image
  input:
    val mcp
    val module
    path(marker)
    path(image)
    val sampleName

    // outputs are returned as results with appropriate patterns
  output:
    // Output background subtracted image and markers.csv
    path("*.ome.tif"), emit: image_out
    path('markers_bs.csv'), emit: marker_out
    // Provenance files
    tuple path('.command.sh'), path('.command.log')

    // Specifies whether to run the process
    // Here, we simply take the flag from the workflow parameters
  when: mcp.workflow["background"]
  script:

    // Compose parameters using module options
    def imgin  = "${module.image} $image"

    // If the module specifies a way to provide an output file name, use it
    // Otherwise, keep this argument empty
    def imgout = (module['image-output'] == "") ? "" :
      "${module['image-output']} ${sampleName+'_backsub'}.ome.tif"

    // If the module specifies a way to on marker files, use it
    // Otherwise, keep this argument empty
    def mrkin  = (module.markers == "") ? "" : "${module.markers} $marker"
    def mrkout = (module['markers-output'] == "") ? "" : "${module['markers-output']} markers_bs.csv"

    // Compose the full command to be executed inside the container
    """
    ${module.cmd} ${imgin} ${mrkin} ${imgout} ${mrkout} ${Opts.moduleOpts(module, mcp)}
    """
}

workflow background {
  
    // Inputs:
  take:
    mcp // MCMICRO parameters (workflow, options, etc.)
    image // image to apply background subtraction to
    marker // marker file
  main:
    // run the backsub process with the mcmicro parameters, module value
    // markers path and pre-registered image path
    sampleName = file(params.in).name
    backsub(mcp, mcp.modules['background'], marker, image, sampleName)
    
    // Return the outputs produced by the tool
  emit:
    image = backsub.out.image_out
    marker = backsub.out.marker_out
}
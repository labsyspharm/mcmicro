/*
A template for adding new modules to MCMICRO

Step 1: Add module specs to config/defaults.yml

  a: Add a flag specifying whether the module should be run to workflow:
  b: Add default module options to options:
  c: Add module name and container specs to modules:

  For example, support we wanted to add a module that produces a QC report
    about the signal-to-noise ratio (snr). The three additions to defaults.yml
    may then look as follows:

  workflow:
    report: false
  options:
    snr: --cool-parameter 42
  modules:
    report:
      name: snr
      container: myorganization/snr
      version: 1.0.0

Step 2: Modify the code below as needed

Step 3: Run the module from the main workflow in main.nf

  a: add an include statement to import the relevant workflow. For example:

    ...
    include {downstream}     from "$projectDir/modules/downstream"
    include {viz}            from "$projectDir/modules/viz"
    include {report}         from "$projectDir/modules/report"   // <- importing the new module
  
  b: add a statement calling the module near the bottom of the main workflow:

    ...
    downstream(mcp, sft)

    report(mcp, allimg, sft)     // <- calling the new module

    // Vizualization
    viz(mcp, allimg)
    ...

*/

// Import utility functions from lib/mcmicro/*.groovy
import mcmicro.*

// Process name will appear in the the nextflow execution log
// While not strictly required, it's a good idea to make the 
//   process name match your tool name to avoid user confusion
process snr {

    // Use the container specification from the parameter file
    // No change to this line is required
    container "${params.contPfx}${module.container}:${module.version}"

    // Specify the project subdirectory for writing the outputs to
    // The pattern: specification must match the output: files below
    // TODO: replace report with the desired output directory
    // TODO: replace the pattern to match the output: clause below
    publishDir "${params.in}/report", mode: 'copy', pattern: "*.html"

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
    tuple path(img), path(sft)

    // Process outputs that should be captured and 
    //  a) returned as results
    //  b) published to the project directory
    // TODO: replace *.html with the pattern of the tool output files
  output:
    path("*.html"), emit: results

    // Provenance files -- no change is needed here
    tuple path('.command.sh'), path('.command.log')

    // Specifies whether to run the process
    // Here, we simply take the flag from the workflow parameters
    // TODO: change snr to match the true/false workflow parameter in defaults.yml
  when: mcp.workflow["report"]

    // The command to be executed inside the tool container
    // The command must write all outputs to the current working directory (.)
    // Opts.moduleOpts() will identify and return the appropriate module options
    """    
    python /app/mytool.py --image $img --features $sft ${Opts.moduleOpts(module, mcp)}
    """
}

workflow report {
  
    // Inputs:
    // mcp - MCMICRO parameters (workflow, options, etc.)
    // imgs - images
    // sfts - spatial feature tables
  take:
    mcp
    imgs
    sfts

  main:
    
    // Match images against feature tables
    id_imgs = imgs.map{ it -> tuple(Util.getImageID(it), it) }
    id_sfts = sfts.map{ it -> tuple(Util.getFileID(it, '--'), it) }

    // Apply the process to each (image, sft) pair
    id_imgs.combine(id_sfts, by:0)
        .map{ tag, img, sft -> tuple(img, sft) } | snr

    // Return the outputs produced by the tool
  emit:
    snr.out.results
}
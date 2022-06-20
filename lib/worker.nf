import mcmicro.*

// General worker process
//
// Inputs:
//   tag     - used to match against other files at the pipeline level
//             the tag is assigned to the outputs without being modified by the worker
//   module  - a list of module parameters (usually comes from config/modules.config)
//     .name      - named of the module
//     .container - associated Docker container image
//     .version   - Docker container image tag
//     .cmd       - command to be executed inside the container
//     .input     - how the input will be provided to the module
//     .model     - (optional) how a custom model will be provided to the module
//   model   - a custom model file that a user specifies through --${module.name}-model
//   inp     - input file to process (e.g., .ome.tif for probability-map generation)
//   fnOut   - (optional) if not '', outputs will be renamed to this upon publication
//   outfmt  - a regular expression defining the outputs to capture
//   idxStep - index of the processing step associated with the module
//   pubDir  - directory to publish outputs to
//
// Outputs:
//   The process captures files matching outfmt and publishes them to pubDir
//   It also captures and publishes all files in the plots/ subdirectory
//   Lastly, it captures all files in the qc/ subdirectory and publishes them to project/qc/
//
// Relevant params:
//   .contPfx - container prefix ('' for Docker, 'docker://' for Singularity)
//   .${module.name}Opts - custom module parameters specified via --${module.name}-opts
process worker {
    container "${params.contPfx}${module.container}:${module.version}"
    tag "${module.name}-${task.index}"
    
    // Output files in the pre-configured output format (outfmt) and optional plots
    publishDir "${pubDir}", mode: 'copy',
      pattern: "$outfmt", saveAs: {fn -> fnOut != '' ? fnOut : fn}
    publishDir "${pubDir}", mode: 'copy', pattern: 'plots/**'

    // QC
    publishDir "${Paths.QC(params.in, module.name)}", mode: "${params.qcFiles}",
      pattern: 'qc/**', saveAs: { fn -> fn.replaceFirst("qc/","") }
    
    // Provenance
    publishDir "${Paths.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> fn.replace('.command', "${module.name}-${task.index}")}

    input:
        tuple val(tag), val(module), file(model), path(inp), val(pubDir), val(fnOut)
        val(outfmt)
        val(idxStep)

    output:

    // Every worker emits a tuple (tag, module used, result)
    // The tag is used to match against files in other pipeline steps
    tuple val(tag), val("${module.name}"), path("$outfmt"), emit: res

    // Modules have the option of producing additional files in plots/ and qc/
    //   subdirectories. These are captured and published to the project directory.
    path('plots/**') optional true
    path('qc/**') optional true

    // Provenance
    tuple path('.command.sh'), path('.command.log')

    when:
	params.idxStart <= idxStep && params.idxStop >= idxStep
    
    // We are creating a copy of the model file to deal with some tools locking files
    // Without this copying, the lock prevents parallel execution of multiple processes
    //   if they all use the same model file.
    script:

    // Find module specific parameters and compose a command
    def cmd = "${module.cmd} ${module.input} $inp ${Opts.moduleOpts(module, params)}"
    String m = "${module.name}Model"

    if( params.containsKey(m) ) {
	def mdlcp = "cp-${model.name}"
        """
        cp $model $mdlcp
        $cmd ${module.model} $mdlcp    
        """
    } else {
        """
        $cmd
        """
    }
}

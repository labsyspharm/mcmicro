// General worker process
//
// Inputs:
//   module  - a list of module parameters (usually comes from config/modules.config)
//     .name      - named of the module
//     .container - associated Docker container image
//     .version   - Docker container image tag
//     .cmd       - command to be executed inside the container
//     .input     - how the input will be provided to the module
//     .model     - (optional) how a custom model will be provided to the module
//   model   - a custom model file that a user specifies through --${module.name}-model
//   inp     - input file to process (e.g., .ome.tif for probability-map generation)
//   outfmt  - a regular expression defining the outputs to capture
//   idxStep - index of the processing step associated with the module
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
    
    // Output probability map
    publishDir "${params.pubDir}/${module.name}", mode: 'copy', pattern: "$outfmt"
    publishDir "${params.pubDir}/${module.name}", mode: 'copy', pattern: 'plots/**'

    // QC
    publishDir "${params.path_qc}/${module.name}", mode: 'copy',
      pattern: 'qc/**', saveAs: { fn -> fn.replaceFirst("qc/","") }
    
    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}

    input: tuple val(module), file(model), path(inp), val(outfmt), val(idxStep)

    output:

    tuple val("${module.name}"), path("$outfmt"), emit: res
    path('plots/**') optional true
    path('qc/**') optional true
    tuple path('.command.sh'), path('.command.log')

    when:
	params.idxStart <= idxStep && params.idxStop >= idxStep
    
    // We are creating a copy of the model file to deal with some tools locking files
    // Without this copying, the lock prevents parallel execution of multiple processes
    //   if they all use the same model file.
    script:

    // Find module specific parameters and compose a command
    def mparam = params."${module.name}Opts"
    def cmd = "${module.cmd} ${module.input} $inp $mparam"
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

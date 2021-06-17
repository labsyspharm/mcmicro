process ilastik {
    // Output probability map
    publishDir "${params.pubDir}/ilastik", mode: 'copy', pattern: '*_Probabilities*.tif'

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}

    input:
	path core
        file(model)
    
    output:
      tuple val('ilastik'), path('*_Probabilities*.tif'), emit: pm
      tuple path('.command.sh'), path('.command.log')

    when:
	params.idxStart <= 4 && params.idxStop >= 4 &&
	params.probabilityMaps.contains('ilastik')

    // We are creating a copy of the model file to deal with some tools locking files
    // Without this copying, the lock prevents parallel execution of multiple processes
    //   if they all use the same model file.
    script:

    def cmd = "python /app/mc-ilastik.py --input $core --output . ${params.ilastikOpts}"
    
    if( params.containsKey('ilastikModel') ) {
	def mdlcp = "cp-${model.name}"
	"""
        cp $model $mdlcp
        $cmd --model $mdlcp
        """
    } else {
	"""
        $cmd
        """
    }
}

process pmproc {
    container "${module.container}:${module.version}"
    
    // Output probability map
    publishDir "${params.pubDir}/${module.name}", mode: 'copy', pattern: '*_Probabilities*.tif'

    // QC
    publishDir "${params.path_qc}/${module.name}", mode: 'copy', pattern: '*Preview*.tif'
    
    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}

    input: tuple val(module), file(model), path(core)

    output:

    tuple val("${params.module.name}"), path('*_Probabilities*.tif'), emit: pm
    path('*Preview*.tif') optional true
    tuple path('.command.sh'), path('.command.log')

    when:
	params.idxStart <= 4 && params.idxStop >= 4
    
    script:

    // Find module specific parameters
    def mparam = params."${module.name}Opts"
    """
    ${module.cmd} ${module.input} $core $mparam    
    """
}

workflow probmaps {
    take:
	
    input
    modules

    main:

    // Determine if there are any custom models specified
    res = modules.map{ it ->
	tuple(it, params.containsKey("${it.name}Model") ?
	      file(params."${it.name}Model") : 'built-in') }
	.combine( input )
    
    /*
    // Identify the ilastik model
    ilastik_mdl = params.containsKey('ilastikModel') ?
	file(params.ilastikModel) : 'built-in'

    unmicst(input)
    cypository(input)
    ilastik(input, ilastik_mdl)
     */

    emit:

    res
//    pmproc.out.pm
}

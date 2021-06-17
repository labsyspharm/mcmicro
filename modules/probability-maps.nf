process unmicst {
    // Output probability map
    publishDir "${params.pubDir}/unmicst", mode: 'copy', pattern: '*_Probabilities*.tif'

    // QC
    publishDir "${params.path_qc}/unmicst", mode: 'copy', pattern: '*Preview*.tif'

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}

    input: path core
    
    output:
      tuple val('unmicst'), path('*_Probabilities*.tif'), emit: pm
      path('*Preview*.tif')
      tuple path('.command.sh'), path('.command.log')

    when:
	params.idxStart <= 4 && params.idxStop >= 4 &&
	params.probabilityMaps.contains('unmicst')

    """
    python /app/unmicstWrapper.py $core ${params.unmicstOpts} --stackOutput --outputPath .
    """
}

process cypository {
    // Output probability map
    publishDir "${params.pubDir}/cypository", mode: 'copy', pattern: '*_Probabilities*.tif'

    // QC
    publishDir "${params.path_qc}/cypository", mode: 'copy', pattern: '*Preview*.tif'

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}

    input: path core

    output:
      tuple val('cypository'), path('*_Probabilities*.tif'), emit: pm
      path('*Preview*.tif')
      tuple path('.command.sh'), path('.command.log')

    when:
	params.idxStart <= 4 && params.idxStop >= 4 &&
	params.probabilityMaps.contains('cypository')

    """
    python /app/deployMaskRCNN.py $core ${params.cypositoryOpts} --stackOutput --outputPath .
    """
}

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
        file(mdl) name 'input.ilp'
    
    output:
      tuple val('ilastik'), path('*_Probabilities*.tif'), emit: pm
      tuple path('.command.sh'), path('.command.log')

    when:
	params.idxStart <= 4 && params.idxStop >= 4 &&
	params.probabilityMaps.contains('ilastik')

    // We are copying input.ilp to model.ilp, because ilastik locks the model file.
    // Without this copying, the lock prevents parallel execution of multiple processes
    //   if they all use the same model file.
    script:
        def model = params.ilastikModel != "built-in" ? 'input.ilp' :
	"/app/classifiers/exemplar_001_nuclei.ilp"
    """
    cp $model ./model.ilp
    python /app/CommandIlastikPrepOME.py \
      ${params.ilastikOpts} --input $core --output .
    /ilastik-release/run_ilastik.sh --headless --project=model.ilp *.hdf5
    """
}

workflow probmaps {
    take:
	input

    main:
	// Identify the ilastik model
        ilastik_mdl = params.ilastikModel != 'built-in' ?
	  file(params.ilastikModel) : 'built-in'

    unmicst(input)
    cypository(input)
    ilastik(input, ilastik_mdl)

    emit:
	unmicst.out.pm
        .mix( cypository.out.pm )
        .mix( ilastik.out.pm )
}

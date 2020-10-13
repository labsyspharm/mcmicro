process unmicst {
    // Output probability map
    publishDir "${params.pubDir}/unmicst", mode: 'copy', pattern: '*Probabilities*.tif'

    // QC
    publishDir "${params.path_qc}/unmicst", mode: 'copy', pattern: '*Preview*.tif'

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}

    input:
	tuple path(core), val(mask)
    
    output:
      tuple val('unmicst'), path(core), val(mask),
        path('*Probabilities*.tif'), emit: pm
      path('*Preview*.tif')
      tuple path('.command.sh'), path('.command.log')

    when:
	params.idxStart <= 4 && params.idxStop >= 4 &&
	(params.probabilityMaps == 'unmicst' ||
	 params.probabilityMaps == 'all')

    """
    python /app/unmicstWrapper.py $core ${params.unmicstOpts} --stackOutput --outputPath .
    """
}

process ilastik {
    // Output probability map
    publishDir "${params.pubDir}/ilastik", mode: 'copy', pattern: '*Probabilities*.tif'

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}

    input:
	tuple path(core), val(mask)
        file(mdl) name 'input.ilp'
    
    output:
      tuple val('ilastik'), path(core), val(mask),
        path('*Probabilities*.tif'), emit: pm
      tuple path('.command.sh'), path('.command.log')

    when: params.idxStart <= 4 && params.idxStop >= 4 &&
	(params.probabilityMaps == 'ilastik' ||
	 params.probabilityMaps == 'all')
    
    script:
        def model = params.ilastikModel != "built-in" ? 'input.ilp' :
	"/app/classifiers/exemplar_001_nuclei.ilp"
    """
    python /app/CommandIlastikPrepOME.py \
      ${params.ilastikOpts} --input $core --output .
    cp $model ./model.ilp
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
        ilastik(input, ilastik_mdl)

    emit:
	unmicst.out.pm.mix( ilastik.out.pm )
}

process unmicst {
    publishDir "${params.pubDir}/unmicst", mode: 'copy', pattern: '*Probabilities*.tif'
    publishDir "${params.path_qc}/unmicst", mode: 'copy', pattern: '*Preview*.tif'

    input:
	tuple path(core), val(mask)
    
    output:
      tuple val('unmicst'), path(core), val(mask),
        path('*Probabilities*.tif'), emit: pm
      path('*Preview*.tif')

    when:
	params.idxStart <= 4 && params.idxStop >= 4 &&
	(params.probabilityMaps == 'unmicst' ||
	 params.probabilityMaps == 'all')

    """
    python /app/${params.unmicstPy} $core ${params.unmicstOpts} --stackOutput --outputPath .
    """
}

process ilastik {
    publishDir "${params.pubDir}/ilastik", mode: 'copy', pattern: '*Probabilities*.tif'

    input:
	tuple path(core), val(mask)
        file(mdl) name 'input.ilp'
    
    output:
      tuple val('ilastik'), path(core), val(mask),
        path('*Probabilities*.tif'), emit: pm

    when: params.idxStart <= 4 && params.idxStop >= 4 &&
	(params.probabilityMaps == 'ilastik' ||
	 params.probabilityMaps == 'all')
    
    script:
        def model = params.ilastikModel != "NO_MODEL" ? 'input.ilp' :
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
        ilastik_mdl = params.ilastikModel != 'NO_MODEL' ?
	  file(params.ilastikModel) : 'NO_MODEL'

	unmicst(input)
        ilastik(input, ilastik_mdl)

    emit:
	unmicst.out.pm.mix( ilastik.out.pm )
}

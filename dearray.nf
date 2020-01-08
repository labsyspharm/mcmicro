#!/usr/bin/env nextflow

params.in = '/home/sokolov/test/exemplar-002'
path_rg  = "${params.in}/registration"
path_dr  = "${params.in}/dearray"
path_drm = "${params.in}/dearray/masks"

rg = Channel.fromPath( "${path_rg}/*.ome.tif" ).toSortedList()

/*
process mock_ashlar {
    intput:
	file rg
    output:
	file "stitched.ome.tif" into stitched

    '''
    cp $rg stitched.ome.tif
    '''
}
*/

process dearray {
    output:
    file "*.tif" into cores
    file "*_mask.tif" into core_masks

    '''
    #!/usr/bin/env matlab

    addpath(genpath('~/mcmicro/Coreograph'))
    tmaDearray('/home/sokolov/test/exemplar-002/registration/stitched.ome.tif', ...
               'outputPath','.','useGrid','true')    
    '''
}

cores
    .flatMap()
    .collectFile( storeDir: path_dr )
    .subscribe { println "File ${it.name} saved to ${it.getParent()}" }

core_masks
    .flatMap()
    .collectFile( storeDir: path_drm )
    .subscribe { println "File ${it.name} saved to ${it.getParent()}" }

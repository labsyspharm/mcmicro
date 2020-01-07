#!/usr/bin/env nextflow

// Input location of the exemplar
params.in = '/home/sokolov/test/mcmicro_nf/exemplar-002'

// Create intermediate directories
path_rg = "${params.in}/registration"
file(path_rg).mkdir()

// Channels for the initial inputs (raw images and illumination profiles)
raw = Channel
    .fromPath( "${params.in}/raw_images/*.ome.tiff" )
    .toSortedList()
dfp = Channel
    .fromPath( "${params.in}/illumination_profiles/*-dfp.tif" )
    .toSortedList()
ffp = Channel
    .fromPath( "${params.in}/illumination_profiles/*-ffp.tif" )
    .toSortedList()

// Stitching and registration
process ashlar {
    container 'labsyspharm/ashlar:latest'

    input:
    file raw
    file dfp
    file ffp

    output:
    stdout result
    file 'stitched.ome.tif' into stitched

    """
    ashlar $raw -m 30 --pyramid --ffp $ffp --dfp $dfp -f stitched.ome.tif
    """
}

// Handle final and intermediate outputs
result.subscribe { print it }
stitched
    .collectFile( storeDir: path_rg )
    .subscribe { println "Stitched image saved to $it" }

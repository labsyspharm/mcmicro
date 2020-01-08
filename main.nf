#!/usr/bin/env nextflow

// Default parameters
params.in = '/home/sokolov/test/exemplar-002'
params.TMA = true

// Define all subdirectories
path_raw = "${params.in}/raw_images"
path_ilp = "${params.in}/illumination_profiles"
path_rg  = "${params.in}/registration"
path_dr  = "${params.in}/dearray"
path_drm = "${params.in}/dearray/masks"

// Create intermediate directories
file(path_rg).mkdir()
file(path_drm).mkdirs()   // Also handles the parent path_dr

// Channels for the initial inputs (raw images and illumination profiles)
raw = Channel.fromPath( "${path_raw}/*.ome.tiff" ).toSortedList()
dfp = Channel.fromPath( "${path_ilp}/*-dfp.tif" ).toSortedList()
ffp = Channel.fromPath( "${path_ilp}/*-ffp.tif" ).toSortedList()

// Stitching and registration
process ashlar {
    container 'labsyspharm/ashlar:latest'
    publishDir path_rg, mode: 'copy', overwrite: false
    
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

// Display stdout
result.subscribe { print it }

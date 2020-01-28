#!/usr/bin/env nextflow

// Default parameters
params.tools = "$HOME/mcmicro"
params.TMA   = true

// Define tools
params.tool_core    = "${params.tools}/Coreograph"
params.tool_unmicst = "${params.tools}/UnMicst"

// Define all subdirectories
path_raw  = "${params.in}/raw_images"
path_ilp  = "${params.in}/illumination_profiles"
path_rg   = "${params.in}/registration"
path_dr   = "${params.in}/dearray"
path_drm  = "${params.in}/dearray/masks"
path_prob = "${params.in}/prob_maps"

// Closure: Filename from full path: {/path/to/file.ext -> file.ext}
cls_base = { fn -> file(fn).name }

// Create intermediate directories
file(path_rg).mkdir()
file(path_drm).mkdirs()   // Also handles the parent path_dr
file(path_prob).mkdir()

// Channels for the initial inputs (raw images and illumination profiles)
raw = Channel.fromPath( "${path_raw}/*.ome.tiff" ).toSortedList()
dfp = Channel.fromPath( "${path_ilp}/*-dfp.tif" ).toSortedList()
ffp = Channel.fromPath( "${path_ilp}/*-ffp.tif" ).toSortedList()

// Stitching and registration
process ashlar {
    publishDir path_rg, mode: 'copy'
    
    input:
    file raw
    file dfp
    file ffp

    output:
    file 'stitched.ome.tif' into stitched

    """
    ashlar $raw -m 30 --pyramid --ffp $ffp --dfp $dfp -f stitched.ome.tif
    """
}

// De-arraying (if TMA)
process dearray {
    publishDir path_dr,  mode: 'copy', pattern: "**[0-9].tif", saveAs: cls_base
    publishDir path_drm, mode: 'copy', pattern: "**_mask.tif", saveAs: cls_base

    input:
    file stitched
    
    output:
    file "**/{[A-Z],[A-Z][A-Z]}{[0-9],[0-9][0-9]}.tif" into cores
    file "**_mask.tif" into core_masks

    """
    matlab -nodesktop -nosplash -r \
    "addpath(genpath('${params.tool_core}')); \
     tmaDearray('./$stitched','outputPath','.','useGrid','true'); exit"
    """
}

cores
    .flatten()
    .subscribe { println "Received ${it.name} in cores" }

core_masks
    .flatten()
    .subscribe { println "Received ${it.name} in masks" }

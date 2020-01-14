#!/usr/bin/env nextflow

params.in        = '/home/sokolov/test/exemplar-002'
params.tool_core = '/home/sokolov/mcmicro/Coreograph'

path_rg  = "${params.in}/registration"
path_dr  = "${params.in}/dearray"
path_drm = "${params.in}/dearray/masks"

// Filename from full path: {/path/to/file.ext -> file.ext}
cls_base = { fn -> file(fn).name }

rg = Channel.fromPath( "${path_rg}/*.ome.tif" ).toSortedList()

process dearray {
    publishDir path_dr,  mode: 'copy', pattern: "**[0-9].tif", saveAs: cls_base
    publishDir path_drm, mode: 'copy', pattern: "**_mask.tif", saveAs: cls_base

    input:
    file rg
    
    output:
    file "**/{[A-Z],[A-Z][A-Z]}{[0-9],[0-9][0-9]}.tif" into cores
    file "**_mask.tif" into core_masks

    """
    matlab -nodesktop -nosplash -r \
    "addpath(genpath('${params.tool_core}')); \
     tmaDearray('./$rg','outputPath','.','useGrid','true'); exit"
    """
}

cores
    .flatten()
    .subscribe { println "Received ${it.name} in cores" }

core_masks
    .flatten()
    .subscribe { println "Received ${it.name} in masks" }

#!/usr/bin/env nextflow

// Default parameters
params.tools       = "$HOME/mcmicro"
params.TMA         = true
params.skip_ashlar = false

// Define tools
// NOTE: Some of these values are overwritten by nextflow.config
params.tool_core    = "${params.tools}/Coreograph"
params.tool_unmicst = "${params.tools}/UnMicst"
params.tool_segment = "${params.tools}/S3segmenter"

// Define all subdirectories
path_raw  = "${params.in}/raw_images"
path_ilp  = "${params.in}/illumination_profiles"
path_rg   = "${params.in}/registration"
path_dr   = "${params.in}/dearray"
path_drm  = "${params.in}/dearray/masks"
path_prob = "${params.in}/prob_maps"

// Create intermediate directories
file(path_rg).mkdir()
file(path_drm).mkdirs()   // Also handles the parent path_dr
file(path_prob).mkdir()

// Define closures / functions
//   Filename from full path: {/path/to/file.ext -> file.ext}
cls_base = { fn -> file(fn).name }

//   Channel from path p if cond is true, empty channel if false
cls_ch = { cond, p -> cond ? Channel.fromPath(p) : Channel.empty() }

//   Extract image ID from filename
cls_id  = { fn -> fn.toString().tokenize('_').get(0) }
cls_fid = { file -> tuple(cls_fnid(file.getBaseName()), file) }

// If we're running ASHLAR, find raw images and illumination profiles
raw = cls_ch( !params.skip_ashlar, "${path_raw}/*.ome.tiff" ).toSortedList()
dfp = cls_ch( !params.skip_ashlar, "${path_ilp}/*-dfp.tif" ).toSortedList()
ffp = cls_ch( !params.skip_ashlar, "${path_ilp}/*-ffp.tif" ).toSortedList()

// If we're not running ASHLAR, find the pre-stitched image
prestitched = cls_ch( params.skip_ashlar, "${path_rg}/stitched.ome.tif" )

// Stitching and registration
process ashlar {
    publishDir path_rg, mode: 'copy'
    
    input:
    file raw
    file ffp
    file dfp

    output:
    file 'stitched.ome.tif' into stitched

    when:
    !params.skip_ashlar

    """
    ashlar $raw -m 30 --pyramid --ffp $ffp --dfp $dfp -f stitched.ome.tif
    """
}

// De-arraying (if TMA)
process dearray {
    publishDir path_dr,  mode: 'copy', pattern: "**[0-9].tif"
    publishDir path_drm, mode: 'copy', pattern: "**_mask.tif"

    // Mix mutually-exclusive channels (dependent on params.skip_ashlar)
    input:
    file s from stitched.mix( prestitched )
    
    output:
    file "**{[A-Z],[A-Z][A-Z]}{[0-9],[0-9][0-9]}.tif" into cores
    file "**_mask.tif" into core_masks

    """
    matlab -nodesktop -nosplash -r \
    "addpath(genpath('${params.tool_core}')); \
     tmaDearray('./$s','outputPath','.','useGrid','true'); exit"
    """
}

// UNet classification
process unmicst {
    publishDir path_prob, mode: 'copy'

    input:
    file core from cores.flatten()

    output:
    file '*.tif'

    """
    python ${params.tool_unmicst}/UnMicst.py $core --outputPath .
    """
}

//cores
//    .flatten()
//    .map(cls_fid)

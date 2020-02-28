#!/usr/bin/env nextflow

// Expect the following params
// .name - Name of the exemplar, e.g., "exemplar-001", "exemplar-002", etc.
// .path - Path of the local folder for downloading to

dir_raw = "raw_images"
dir_ilp = "illumination_profiles"

// Map the exemplar name to remote URL
switch( params.name ) {
    case "exemplar-001":
	url = 'https://mcmicro.s3.amazonaws.com/exemplars/001/exemplar-001'
	nc  = 3
	break
    case "exemplar-002":
	url = 'https://mcmicro.s3.amazonaws.com/exemplars/002/exemplar-002'
	nc  = 10
	break
    default:
	error "Unknown exemplar name"
}

// Sequence of individual cycles to download
seq = Channel.of( 1..nc )

process getExemplar {
    publishDir "${params.path}/${params.name}", mode: 'copy'

    input:
	val i from seq
    
    output:
	file '**'
    
    shell:
    '''
    mkdir !{dir_raw}
    mkdir !{dir_ilp}

    name="!{params.name}-cycle-$(printf %02d !{i})"
    name_raw="!{dir_raw}/$name.ome.tiff"
    name_dfp="!{dir_ilp}/$name-dfp.tif"
    name_ffp="!{dir_ilp}/$name-ffp.tif"

    curl -f -o $name_raw "!{url}/$name_raw"
    curl -f -o $name_dfp "!{url}/$name_dfp"
    curl -f -o $name_ffp "!{url}/$name_ffp"
    '''
}

#!/usr/bin/env nextflow

// Expect the following params
// .name - Name of the exemplar, e.g., "exemplar-001", "exemplar-002", etc.
// .path - Path of the local folder for downloading to

dir_raw = "raw_images"
dir_ilp = "illumination_profiles"

base001 = 'https://mcmicro.s3.amazonaws.com/exemplars/001/exemplar-001'
seq001 = Channel.of( 1..10 )

process get001 {
    publishDir "${params.path}/${params.name}", mode: 'copy'

    input:
	val i from seq001
    
    output:
	file '**'

    when:
	params.name == 'exemplar-001'

    shell:
    '''
    mkdir !{dir_raw}
    mkdir !{dir_ilp}

    name="!{params.name}-cycle-$(printf %02d !{i})"
    name_raw="!{dir_raw}/$name.ome.tiff"
    name_dfp="!{dir_ilp}/$name-dfp.tif"
    name_ffp="!{dir_ilp}/$name-ffp.tif"

    curl -o $name_raw "!{base001}/$name_raw"
    curl -o $name_dfp "!{base001}/$name_dfp"
    curl -o $name_ffp "!{base001}/$name_ffp"
    '''
}

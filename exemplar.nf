#!/usr/bin/env nextflow

// Expect the following params
// .name - Name of the exemplar, e.g., "exemplar-001", "exemplar-002", etc.
// .path - Path of the local folder for downloading to

// Optional parameters
// .nc - Number of cycles to download (between 1 and 10)

dir_raw = "raw"
dir_ilp = "illumination"

// Map the exemplar name to remote URL
switch( params.name ) {
    case "exemplar-001":
	url = 'https://mcmicro.s3.amazonaws.com/exemplars/001/exemplar-001'
	params.nc  = 3
	break
    case "exemplar-002":
	url = 'https://mcmicro.s3.amazonaws.com/exemplars/002/exemplar-002'
	params.nc  = 10
	break
    default:
	error "Unknown exemplar name"
}

// Sequence of individual cycles to download
seq = Channel.of( 1..params.nc )
nm = params.nc * 4 + 1			// Four markers per channel, plus header

process getImages {
    publishDir "${params.path}/${params.name}", mode: 'move'

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

process getMarkers {
    publishDir "${params.path}/${params.name}", mode: 'move'

    output:
	file '**'

    """
    curl -f "${url}/markers.csv" | head -n ${nm} > markers.csv
    """
}

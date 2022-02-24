#!/usr/bin/env nextflow

if( params.containsKey('help') ) {
    println """
    Download MCMICRO exemplar datasets

    Expected parameters
      --name - Name of the exemplar, e.g., "exemplar-001", "exemplar-002", etc.'
      --path - Path to the destination folder'
    
    Optional parameters
      --from-cycle - Index of the first cycle to download
      --to-cycle   - Index of the final cycle to download
      --nc         - Number of cycles to download (overrides --from-cycle and --to-cycle)
    
    Examples:
      1. Download the first five cycles of exemplar-001 to the current directory

         nextflow labsyspharm/mcmicro/exemplar.nf --name exemplar-001 --path . --nc 5

      2. Download cycle 3 through 9 (inclusively) of exemplar-002 to /data

         nextflow labsyspharm/mcmicro/exemplar.nf \\
           --name exemplar-002 --path /data \\
           --from-cycle 3 --to-cycle 9
    """
    exit 0
}

params.nc = 0
dir_raw   = "raw"
dir_ilp   = "illumination"

// Map the exemplar name to remote URL
switch( params.name ) {
    case "exemplar-001":
	url = 'https://mcmicro.s3.amazonaws.com/exemplars/001/exemplar-001'
	params.fromCycle  = 6
    params.toCycle    = 8
	break
    case "exemplar-002":
	url = 'https://mcmicro.s3.amazonaws.com/exemplars/002/exemplar-002'
	params.fromCycle  = 1
    params.toCycle    = 10
	break
    default:
	error "Unknown exemplar name"
}

// Sequence of individual cycles to download
if(params.nc > 0 ) {
    seq   = Channel.of( 1..params.nc )
    mFrom = 2
    mTo   = params.nc * 4 + 1    // Four markers per channel, plus header
}
else {
    seq = Channel.of( params.fromCycle..params.toCycle )
    mFrom = (params.fromCycle-1) * 4 + 2
    mTo   = (params.toCycle) * 4 + 1
}

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
    curl -f "${url}/markers.csv" | sed -n "1p;${mFrom},${mTo}p" > markers.csv
    """
}

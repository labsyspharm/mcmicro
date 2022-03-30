#!/usr/bin/env nextflow

nextflow.enable.dsl=2

if( params.containsKey('help') ) {
    println """
    Download MCMICRO exemplar datasets

    Expected parameters
      --name       - Name of the exemplar, e.g., "exemplar-001", "exemplar-002", etc.
    
    Optional parameters
      --help       - Print this message and exit
      --path       - Path to the destination folder (Default: . or current directory)
      --from-cycle - Index of the first cycle to download
      --to-cycle   - Index of the final cycle to download
      --nc         - Number of cycles to download (overrides --from-cycle and --to-cycle)
    
    Examples:
      1. Download the first five cycles of exemplar-001 to the current directory

         nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-001 --nc 5

      2. Download cycle 3 through 9 (inclusively) of exemplar-002 to /data

         nextflow run labsyspharm/mcmicro/exemplar.nf \\
           --name exemplar-002 --path /data \\
           --from-cycle 3 --to-cycle 9
    """
    exit 0
}

params.nc   = 0
params.path = '.'
dir_ilp     = "illumination"

// Map the exemplar name to remote URL
switch( params.name ) {
    case "exemplar-001":
	url = 'https://mcmicro.s3.amazonaws.com/exemplars/001/exemplar-001'
	params.fromCycle  = 6
	params.toCycle    = 8
    dir_img           = "raw"
	break
    case "exemplar-002":
	url = 'https://mcmicro.s3.amazonaws.com/exemplars/002/exemplar-002'
	params.fromCycle  = 1
    params.toCycle    = 10
    dir_img           = "raw"
	break
    case "exemplar-003":
    url = 'https://mcmicro.s3.amazonaws.com/exemplars/003/exemplar-003'
    params.fromCycle  = 1
    params.toCycle    = 1
    dir_img           = "registration"
    default:
	error "Unknown exemplar name"
}

process getImages {
    publishDir "${params.path}/${params.name}", mode: 'move'

    input: val i
    output:	file '**'
    
    shell:
    '''
    mkdir !{dir_img}
    name="!{params.name}-cycle-$(printf %02d !{i})"
    name_raw="!{dir_img}/$name.ome.tiff"
    curl -f -o $name_raw "!{url}/$name_raw"
    '''
}

process getIllumination {
    publishDir "${params.path}/${params.name}", mode: 'move'

    input: val i
    output:	file '**'

    shell:
    '''
    mkdir !{dir_ilp}
    name="!{params.name}-cycle-$(printf %02d !{i})"
    name_dfp="!{dir_ilp}/$name-dfp.tif"
    name_ffp="!{dir_ilp}/$name-ffp.tif"
    curl -f -o $name_dfp "!{url}/$name_dfp"
    curl -f -o $name_ffp "!{url}/$name_ffp"
    '''
}

process getMarkers {
    publishDir "${params.path}/${params.name}", mode: 'move'

    input: 
      val a
      val b

    output:
      file '**'

    """
    curl -f "${url}/markers.csv" | sed -n "1p;${a},${b}p" > markers.csv
    """
}

workflow {
    // Sequence of individual cycles to download
    if(params.nc > 0 ) {
        seq   = Channel.of( 1..params.nc )
        mFrom = 2
        mTo   = params.nc * 4 + 1    // Four markers per channel, plus header
    }
    else {
        seq   = Channel.of( params.fromCycle..params.toCycle )
        mFrom = (params.fromCycle-1) * 4 + 2
        mTo   = (params.toCycle) * 4 + 1
    }

    getImages(seq)
    getIllumination(seq)
    getMarkers(mFrom, mTo)
}

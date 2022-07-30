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

// Define remote URLs and default parameters
switch( params.name ) {
    case "exemplar-001":
	url = 'https://mcmicro.s3.amazonaws.com/exemplars/001/exemplar-001'
    hasParams         = false
    registered        = false
	params.fromCycle  = 6
	params.toCycle    = 8
	break
    case "exemplar-002":
	url = 'https://mcmicro.s3.amazonaws.com/exemplars/002/exemplar-002'
    hasParams         = true
    registered        = false
	params.fromCycle  = 1
    params.toCycle    = 10
	break
    case "exemplar-003":
    url = 'https://mcmicro.s3.amazonaws.com/exemplars/003/exemplar-003'
    hasParams         = true
    registered        = true
    break
    default:
	error "Unknown exemplar name"
}

process getImages {
    publishDir "${params.path}/${params.name}", mode: 'move'

    input:
        val name
        val loc
    output:	file '**'
    
    script:
    def img = "${loc}/${name}.ome.tiff"
    """
    mkdir ${loc}
    curl -f -o ${img} ${url}/${img}
    """
}

process getIllumination {
    publishDir "${params.path}/${params.name}", mode: 'move'

    input: val name
    output:	file '**'

    script:
    def ilp = 'illumination'
    def dfp = "${ilp}/${name}-dfp.tif"
    def ffp = "${ilp}/${name}-ffp.tif"
    """
    mkdir $ilp
    curl -f -o $dfp ${url}/$dfp
    curl -f -o $ffp ${url}/$ffp
    """
}

process getMarkers {
    publishDir "${params.path}/${params.name}", mode: 'move'

    input: val post
    output: file 'markers.csv'

    """
    curl -f "${url}/markers.csv" ${post} > markers.csv
    """
}

process getParams {
    publishDir "${params.path}/${params.name}", mode: 'move'

    output: file 'params.yml'
    when: hasParams

    """
    curl -f -o params.yml "${url}/params.yml"
    """
}

workflow {

    // Is the exemplar pre-registered?
    if(registered) {

        // Write downloaded images directly to registration/
        getImages(params.name, 'registration')

        // No post-processing of markers.csv
        getMarkers('')

    } else {

        // Determine the sequence of individual cycles to download
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

        // Compose filenames and write downloads to raw/
        fn = seq.map{it -> "${params.name}-cycle-${String.format("%02d", it)}"}
        getImages(fn, 'raw')

        // Fetch illumination profiles
        getIllumination(fn)

        // Cut the appropriate rows from markers.csv
        getMarkers("| sed -n \"1p;${mFrom},${mTo}p\"")
    }

    getParams()
}

#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.help      = false
params.name      = null
params.nc        = 0
params.path      = '.'
params.fromCycle = null
params.toCycle   = null

def printHelp() {
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
}

// Define remote URLs and default parameters
def exemplarSpecs(name) {
    def specs = [
        'exemplar-001': [
            url:        'https://mcmicro.s3.amazonaws.com/exemplars/001/exemplar-001',
            hasParams:  false,
            registered: false,
            fromCycle:  6,
            toCycle:    8
        ],
        'exemplar-002': [
            url:        'https://mcmicro.s3.amazonaws.com/exemplars/002/exemplar-002',
            hasParams:  true,
            registered: false,
            fromCycle:  1,
            toCycle:    10
        ],
        'exemplar-003': [
            url:        'https://mcmicro.s3.amazonaws.com/exemplars/003/exemplar-003',
            hasParams:  true,
            registered: true
        ]
    ]

    if( !specs.containsKey(name) )
        error "Unknown exemplar name"
    return specs[name]
}

process getImages {
    publishDir "${params.path}/${params.name}", mode: 'move'

    input:
        val url
        val name
        val loc
    output:	path '**'

    script:
    def img = "${loc}/${name}.ome.tiff"
    """
    mkdir ${loc}
    curl -f -o ${img} ${url}/${img}
    """
}

process getIllumination {
    publishDir "${params.path}/${params.name}", mode: 'move'

    input:
        val url
        val name
    output:	path '**'

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

    input:
        val url
        val post
    output: path 'markers.csv'

    script:
    """
    curl -f "${url}/markers.csv" ${post} > markers.csv
    """
}

process getParams {
    publishDir "${params.path}/${params.name}", mode: 'move'

    input: val url
    output: path 'params.yml'

    script:
    """
    curl -f -o params.yml "${url}/params.yml"
    """
}

workflow {

    if( params.help ) {
        printHelp()
        exit 0
    }

    def spec = exemplarSpecs(params.name)
    def url  = spec.url

    // Is the exemplar pre-registered?
    if( spec.registered ) {

        // Write downloaded images directly to registration/
        getImages(url, params.name, 'registration')

        // No post-processing of markers.csv
        getMarkers(url, '')

    } else {

        // Determine the sequence of individual cycles to download
        def seq
        def mFrom
        def mTo
        def nc = params.nc as Integer
        if( nc > 0 ) {
            seq   = channel.of( 1..nc )
            mFrom = 2
            mTo   = nc * 4 + 1    // Four markers per channel, plus header
        }
        else {
            def fromCycle = (params.fromCycle ?: spec.fromCycle) as Integer
            def toCycle   = (params.toCycle ?: spec.toCycle) as Integer
            seq   = channel.of( fromCycle..toCycle )
            mFrom = (fromCycle-1) * 4 + 2
            mTo   = toCycle * 4 + 1
        }

        // Compose filenames and write downloads to raw/
        def fn = seq.map{ i -> "${params.name}-cycle-${String.format("%02d", i)}" }
        getImages(url, fn, 'raw')

        // Fetch illumination profiles
        getIllumination(url, fn)

        // Cut the appropriate rows from markers.csv
        getMarkers(url, "| sed -n \"1p;${mFrom},${mTo}p\"")
    }

    if( spec.hasParams )
        getParams(url)
}

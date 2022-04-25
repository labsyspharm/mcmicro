process autothreshold {
    container "${params.contPfx}${params.roadie}"

    publishDir "${params.path_qc}/dynrange",
      mode: 'copy', pattern: 'output.csv', saveAs: {f -> "${tag}.csv"}

    input:  tuple val(tag), path(input_image)
    output: path("output.csv")
    when:   params.dynrange
    script: template 'autothresh.py'
}

include {getImageID} from '../lib/util'

workflow roadie {
    take: imgs
    main: imgs.map{ f -> tuple(getImageID(f), f) } | autothreshold
}

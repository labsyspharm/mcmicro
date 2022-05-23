import mcmicro.Util

process autothreshold {
    container "${params.contPfx}${params.roadie}"

    publishDir "${params.path_qc}/dynrange",
      mode: 'copy', pattern: 'output.csv', saveAs: {f -> "${tag}.csv"}

    input:  tuple val(tag), path(input_image)
    output: path("output.csv")
    when:   params.dynrange
    script: template 'autothresh.py'
}

workflow roadie {
    take: imgs
    main: imgs.map{ f -> tuple(Util.getImageID(f), f) } | autothreshold
}

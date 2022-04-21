process autothreshold {
    container "${params.contPfx}${params.roadie}"

    input:  tuple val(tag), path(input_image)
    output: path("output.csv")
    when:   params.thresh
    script: template 'autothresh.py'
}

include {getImageID} from '../lib/util'

workflow roadie {
    take:
        imgs
    
    main:

    imgs.map{ f -> tuple(getImageID(f), f) }
        | autothreshold
}
process autothreshold {
    container 'labsyspharm/roadie:2022-03-14'

    input:
        path('image.ome.tif')
    
    script:
    template 'autothresh.py'
}

workflow roadie {
    take:
      module
      imgs
    
    main:

    autothreshold(imgs)
}
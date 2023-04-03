import mcmicro.*

process mcquant {
    container "${params.contPfx}${module.container}:${module.version}"

    // Output
    publishDir "${params.in}/quantification", mode: 'copy', pattern: '*.csv'

    // Provenance
    publishDir "${Flow.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> fn.replace('.command', "${module.name}-${task.index}")}
    
    input:
      val mcp
      val module
      tuple val(tag), path("$tag"), path(masks), path(ch)
    
    output:
      path '*.csv', emit: tables
      tuple path('.command.sh'), path('.command.log')

    when: Flow.doirun('quantification', mcp.workflow)

    """
    shopt -s nullglob
    python /app/CommandSingleCellExtraction.py --image $tag \
    ${Opts.moduleOpts(module, mcp)} --output . --channel_names $ch
    """
}

workflow quantification {
    take:
      mcp
      imgs
      segmasks
      markers

    main:

    // Determine IDs of images
    id_imgs = imgs.map{ f -> tuple(Util.getImageID(f), f) }

    // Determine IDs of segmentation masks
    id_msks = segmasks.map{ id, msk -> x = id.split('-',2); tuple(x[1], x[0], msk) }

    // Combine everything based on IDs
    inputs = id_msks.combine(id_imgs, by:0)
      .map{ id, mtd, msk, img -> 
        tuple("${Util.getImageID(img)}--${mtd}.ome.tif", img, msk) }
      .combine( markers )
    mcquant(mcp, mcp.modules['quantification'], inputs)
    
    emit:
      mcquant.out.tables.flatten()
}

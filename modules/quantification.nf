import mcmicro.Util
include {moduleOpts} from "$projectDir/lib/params"

process mcquant {
    container "${params.contPfx}${module.container}:${module.version}"

    // Output
    publishDir "${params.in}/quantification", mode: 'copy', pattern: '*.csv'

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}
    
    input:
      val module
      tuple val(tag), path("$tag"), path(masks), path(ch)
    
    output:
      path '*.csv', emit: tables
      tuple path('.command.sh'), path('.command.log')

    when: params.idxStart <= 6 && params.idxStop >= 6

    """
    python /app/CommandSingleCellExtraction.py --image $tag \
    ${moduleOpts(module)} --output . --channel_names $ch
    """
}

workflow quantification {
    take:
      module
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
      .map{ id, mtd, msk, img -> tuple("${mtd}-${img.getName()}", img, msk) }
      .combine( markers )
    mcquant(module, inputs)
    
    emit:
      mcquant.out.tables.flatten()
}

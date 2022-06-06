import mcmicro.*

include {roadie} from "$projectDir/roadie"

process autominerva {
    container "${params.contPfx}${module.container}:${module.version}"

    // Output
    publishDir "${params.in}/viz", mode: 'copy', pattern: "$tag/**"

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}
    
  input:

    val module
    tuple val(tag), path(img), path(story)

  output:
    path("${tag}/**"), emit: viz

    // qc and provenance
    path('*/qc/**') optional true
    tuple path('.command.sh'), path('.command.log')

  when: params.viz

    """    
    python /app/minerva-author/src/save_exhibit_pyramid.py $img $story $tag
    """
}

workflow viz {
  take:
    module
    imgs

  main:
    
    // Proceed to generate stories only if visualization is requested
    inputs = imgs.branch {
        story: params.viz
        other: true
    }

    stories = roadie('story', inputs.story, '', "${params.in}/qc/story", 'copy')
        .map{ it -> tuple(Util.getImageID(it), it) }
    images = imgs.map{ it -> tuple(Util.getImageID(it), it) }

    inputs = images.combine(stories, by:0)
    autominerva(module, inputs)

  emit:
    autominerva.out.viz
}
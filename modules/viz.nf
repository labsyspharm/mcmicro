import mcmicro.*

include {roadie} from "$projectDir/roadie"

process autominerva {
    container "${params.contPfx}${module.container}:${module.version}"

    // Output
    publishDir "${params.in}/viz", mode: 'copy', pattern: "$tag/**"

    // Provenance
    publishDir "${Flow.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> fn.replace('.command', "${module.name}-${task.index}")}
    
  input:
    val wfp
    val module
    tuple val(tag), path(img), path(story)

  output:
    path("${tag}/**"), emit: viz

    // qc and provenance
    path('*/qc/**') optional true
    tuple path('.command.sh'), path('.command.log')

  when: Flow.doirun('viz', wfp)

    """    
    python /app/minerva-author/src/save_exhibit_pyramid.py $img $story $tag
    """
}

workflow viz {
  take:
    mcp
    imgs

  main:
    
    // Proceed to generate stories only if visualization is requested
    inputs = imgs.branch {
        story: mcp.workflow['viz']
        other: true
    }

    stories = roadie('story', inputs.story, '', "${params.in}/qc/story", 'copy')
        .map{ it -> tuple(Util.getImageID(it), it) }
    images = imgs.map{ it -> tuple(Util.getImageID(it), it) }

    inputs = images.combine(stories, by:0)
    autominerva(mcp.modules['viz'], inputs)

  emit:
    autominerva.out.viz
}
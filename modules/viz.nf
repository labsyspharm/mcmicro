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
    tuple val(tag), path(img), path(markers)

  output:
    path("${tag}/**"), emit: viz

    // qc and provenance
    path('*/qc/**') optional true
    tuple path('.command.sh'), path('.command.log')

  when: Flow.doirun('viz', wfp)

    """
    python /app/story.py --in $img --m $markers --out story.json
    python /app/minerva-author/src/save_exhibit_pyramid.py $img story.json $tag
    """
}

workflow viz {
  take:
    mcp
    imgs
    markers

  main:
    
    inputs = imgs.map{ it -> tuple(Util.getImageID(it), it) }.combine( markers )
    autominerva(mcp.workflow, mcp.modules['viz'], inputs)

  emit:
    autominerva.out.viz
}
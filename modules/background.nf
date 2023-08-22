include {worker} from "$projectDir/lib/worker"

workflow background {
  take:
    mcp
    input
    marker

  main:

    marker = path(marker)
    sampleName = file(params.in).name
    // Determine if there are any custom models specified
    inp = Channel.of( mcp.modules['background'] )
        .flatten()
        .map{ it -> String m = "${it.name}Model";
            tuple(it, mcp.workflow.containsKey(m) ?
            file(mcp.workflow[m]) : 'built-in') }
        .combine(input)
        .map{ mod, _2, _3 ->
        tuple( '', mod, _2, _3, "${params.in}/background/${mod.name}", '') }
    worker( mcp, inp, '*.ome.{tif,tiff}', 'background' )

  emit:
    image = input
    marker = marker
}

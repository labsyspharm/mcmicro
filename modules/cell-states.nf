include {worker} from "$projectDir/lib/worker"

workflow cellstates {
    take:

    input
    modules

    main:

    // Determine if there are any custom models specified
    inp = Channel.of( modules )
        .flatten()
        .map{ it -> String m = "${it.name}Model";
		      tuple(it, params.containsKey(m) ?
		            file(params."$m") : 'built-in') }
        .combine(input)
        .map{ mod, _2, _3 ->
        tuple( '', mod, _2, _3, "${params.in}/cell-states/${mod.name}", '') }
    worker( inp, '*.{csv,h5ad}', 7 )

    emit:

    worker.out.res
}

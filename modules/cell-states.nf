include {worker} from './lib/worker'

workflow cellstates {
    take:

    input
    modules

    main:

    // Determine if there are any custom models specified
    inp = modules.map{ it -> String m = "${it.name}Model";
		      tuple(it, params.containsKey(m) ?
		            file(params."$m") : 'built-in') }
	.combine(input)
    worker( inp, '*.{csv,h5ad}', 7 )

    emit:

    worker.out.res
}

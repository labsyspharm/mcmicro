include {worker} from './lib/worker'

workflow cellstates {
    take:

    input
    modules

    main:

    // Determine if there are any custom models specified
    modules.map{ it -> String m = "${it.name}Model";
		tuple(it, params.containsKey(m) ?
		      file(params."$m") : 'built-in') }
	.combine(input)
	.combine(Channel.of('*.{csv,h5ad}'))
	.combine(Channel.of(7)) |
	worker

    emit:

    worker.out.res
}

include {worker} from './lib/worker'

workflow probmaps {
    take:
	
    input
    modules

    main:

    // Determine if there are any custom models specified
    inp = modules.map{ it -> String m = "${it.name}Model";
		      tuple(it, params.containsKey(m) ?
		            file(params."$m") : 'built-in') }
	.combine(input)
    worker( inp, '*.tif', 4 )
    
    emit:

    worker.out.res
}

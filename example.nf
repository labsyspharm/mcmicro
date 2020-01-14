process gen {
    output:
    file '*.tif' into images

    '''
    printf 'AB' > A1.tif
    printf '12' > A1_mask.tif
    printf 'CD' > A2.tif
    printf '34' > A2_mask.tif
    '''
}

images
    .flatten()
    .map { file ->
	def key = file
	    .getBaseName()
	    .toString()
	    .tokenize('_')
	    .get(0)
	return tuple(key,file)
    }
    .groupTuple(size: 2)
    .map { key, flist ->
	tuple(key, flist.get(0), flist.get(1))
    }
    .set {image_pairs}

process display {
    input:
    tuple core_id, file(x), file(y) from image_pairs

    output:
    file 'result.txt' into result
    
    """
    cat $x $y > result.txt
    """
}

result
    .subscribe { println "Received: " + it.text }

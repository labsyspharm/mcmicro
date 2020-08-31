process illumination {
    publishDir params.pubDir, mode: 'copy'
    
    input: path fn
    output:
	path '*-dfp.tif', emit: dfp
        path '*-ffp.tif', emit: ffp

    when: params.idxStart <= 1 && params.idxStop >= 1
    
    script:
    def xpn = fn.name.tokenize(".").get(0)
    """
    /opt/fiji/Fiji.app/ImageJ-linux64 --ij2 --headless \
      --run /opt/fiji/imagej_basic_ashlar.py \
      "filename='${fn}',output_dir='.',experiment_name='${xpn}'"
    """
}

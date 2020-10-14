process illumination {
    // Output profiles
    publishDir params.pubDir, mode: 'copy', pattern: '*.tif'

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}
    
    input: path fn
    output:
      path '*-dfp.tif', emit: dfp
      path '*-ffp.tif', emit: ffp
      tuple path('.command.sh'), path('.command.log')

    when: params.idxStart <= 1 && params.idxStop >= 1
    
    script:
    def xpn = fn.name.tokenize(".").get(0)
    """
    /opt/fiji/Fiji.app/ImageJ-linux64 --ij2 --headless \
      --run /opt/fiji/imagej_basic_ashlar.py \
      "filename='${fn}',output_dir='.',experiment_name='${xpn}'"
    """
}

import mcmicro.Util

def escapeForImagej(s) {
    // When passing an arbitrary string as an ImageJ macro parameter value, we
    // must backslash-escape backslashes and double-quotes and wrap the whole
    // thing with double-quotes.
    "\"" + s.toString().replace("\\", "\\\\").replace("\"", "\\\"") + "\""
}

process illumination {
    container "${params.contPfx}${module.container}:${module.version}"

    // Output profiles
    publishDir "${params.in}/illumination", mode: 'copy', pattern: '*.tif'

    // Provenance
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.sh',
      saveAs: {fn -> "${task.name}.sh"}
    publishDir "${params.path_prov}", mode: 'copy', pattern: '.command.log',
      saveAs: {fn -> "${task.name}.log"}
    
    input:
      val module
      tuple path(raw), val(relPath) // raw is only for staging, use relPath for paths
    output:
      path '*-dfp.tif', emit: dfp
      path '*-ffp.tif', emit: ffp
      tuple path('.command.sh'), path('.command.log')

    when: params.idxStart <= 1 && params.idxStop >= 1
    
    script:
    def fn = escapeForImagej(relPath)
    def xpn = escapeForImagej(relPath.subpath(0, 1).toString().tokenize(".")[0])
    def macroParams = Util.escapeForShell(
        """filename=$fn,output_dir=".",experiment_name=$xpn"""
    )
    """
    /opt/fiji/Fiji.app/ImageJ-linux64 --ij2 --headless \
      --run /opt/fiji/imagej_basic_ashlar.py \
      $macroParams
    """
}

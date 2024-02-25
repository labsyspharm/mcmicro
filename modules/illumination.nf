import mcmicro.*
import java.nio.file.Paths

include {prepare} from "$projectDir/modules/registration"

def escapeForImagej(s) {
    // When passing an arbitrary string as an ImageJ macro parameter value, we
    // must backslash-escape backslashes and double-quotes and wrap the whole
    // thing with double-quotes.
    "\"" + s.toString().replace("\\", "\\\\").replace("\"", "\\\"") + "\""
}

process basic {
    container "${params.contPfx}${module.container}:${module.version}"

    // Output profiles
    publishDir "${params.in}/illumination/${sname}", mode: "${params.publish_dir_mode}",
      pattern: '*.tif'

    // Provenance
    publishDir "${Flow.QC(params.in, 'provenance')}", mode: 'copy', 
      pattern: '.command.{sh,log}',
      saveAs: {fn -> fn.replace('.command', "${module.name}-${task.index}")}
    
    input:
      val wfp
      val module
      tuple val(sname), path(raw), val(relPath) // raw is only for staging, use relPath for paths
    output:
      path '*-dfp.tif', emit: dfp
      path '*-ffp.tif', emit: ffp
      tuple path('.command.sh'), path('.command.log')

    when: Flow.doirun('illumination', wfp)
    
    script:
    def relPath = Paths.get(relPath)
    def fn = escapeForImagej(relPath)
    def xpn = escapeForImagej(relPath.subpath(0, 1))
    def macroParams = Util.escapeForShell(
        """filename=$fn,output_dir=".",experiment_name=$xpn"""
    )
    """
    /opt/fiji/Fiji.app/ImageJ-linux64 --ij2 --headless \
      --run /opt/fiji/imagej_basic_ashlar.py \
      $macroParams
    """
}

workflow illumination {
  take:
    mcp     // MCMICRO parameters as read by Opts.parseParams()
    raw     // raw image tiles

  main:
    rawPrep = prepare(raw, mcp.workflow)

    // basic(mcp.workflow, mcp.modules['illumination'], rawPrep)

  emit:
    rawPrep
//    basic.out
}
import mcmicro.*

process provenance {

  executor 'local'
  cpus 1
  memory '10MB'
  publishDir "${Flow.QC(params.in, '')}", mode: 'copy', pattern: '*.yml'

  input:
    val mcp

  output:
    path('params.yml')
    path('metadata.yml')

  exec:
    fnp = task.workDir.resolve('params.yml').toUri()
    fnm = task.workDir.resolve('metadata.yml').toUri()

    // Write out MCMICRO parameters
    Opts.writeMap(mcp, fnp)

    // Store additional metadata
    new File(fnm).withWriter{ out ->
        out.println "githubTag: $workflow.revision";
        out.println "githubCommit: $workflow.commitId";
        out.println "roadie: $params.roadie";
    }    
}

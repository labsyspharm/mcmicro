import mcmicro.*

process provenance {
  publishDir "${Flow.QC(params.in, '')}", mode: 'copy', pattern: '*.yml'

  input:
    val mcp

  output:
    path('params.yml')
    path('metadata.yml')

  exec:
    fnp = task.workDir.resolve('params.yml').toString()
    fnm = task.workDir.resolve('metadata.yml').toString()

    // Write out MCMICRO parameters
    Opts.writeMap(mcp, fnp)

    // Store additional metadata
    file(fnm).withWriter{ out ->
        out.println "githubTag: $workflow.revision";
        out.println "githubCommit: $workflow.commitId";
        out.println "roadie: $params.roadie";
    }
}

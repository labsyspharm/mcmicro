nextflow.enable.dsl=2

import org.yaml.snakeyaml.Yaml

def roadieHelp() {
  println """
  Roadie: miscellaneous MCMICRO-related tasks
    
  Usage:
    To run a task,
      nextflow run labsyspharm/mcmicro/roadie.nf --do <task> <options>

    To list available tasks,
      nextflow run labsyspharm/mcmicro/roadie.nf --list-tasks

    To get help about individual tasks,
      nextflow run labsyspharm/mcmicro/roadie.nf --help <task>

  Examples:

    Show help for the recyze task:
      nextflow run labsyspharm/mcmicro/roadie.nf --help recyze

    Make a 1024x1024 crop from myimage.ome.tif:
      nextflow run labsyspharm/mcmicro/roadie.nf --do recyze \\
        --in myimage.ome.tif --x 0 --y 0 --w 1024 --h 1024

    Derive an auto-minerva story and write the output to result/:
      nextflow run labsyspharm/mcmicro/roadie.nf --do story \\
        --in myimage.ome.tif --out result/
    """
}

process showHelp {
    executor 'local'
    container "${params.contPfx}${params.roadie}"

    when: params.containsKey('help')
    input: path(code)
    output: stdout

    """
    echo ''
    python $code --help
    """
}

process runTask {
    container "${params.contPfx}${params.roadie}"
    publishDir "${specs.pubDir}", mode: "${specs.pubMode}"

    input: each path(code); path(input); val(opts); val(specs)
    output: path("${specs.output}")
    
    """
    python $code --in $input $opts
    """
}

// Internal interface to be used by MCMICRO
workflow roadie {
  take:
    task
    input
    opts

    pubDir    // Where to publish results to
    pubMode   // What type of publishing (copy, move, symlink)

  main:
    // Parse task specs
    tasks = new Yaml().load(file("$projectDir/roadie/tasks.yml"))
    specs = tasks.containsKey(task) ? tasks[task] : (error "Unknown task.")

    // Pad specs with the publication strategy
    specs.pubDir  = pubDir
    specs.pubMode = pubMode  

    // Identify and execute the script
    code = Channel.fromPath("$projectDir/roadie/scripts/${task}.py")
    runTask(code, input, opts, specs)

  emit:
    runTask.out
}

// Command-line interface
workflow {
    // By default, write all output to the current directory
    params.out = '.'

    if((params.containsKey('help') && (params.help instanceof Boolean)) ||
     (!params.containsKey('help') && 
      !params.containsKey('do') && 
      !params.containsKey('list-tasks')
     )) {
      roadieHelp()
      exit 0
    }

    // Parse task specs
    tasks = new Yaml().load(file("$projectDir/roadie/tasks.yml"))

    // List available tasks
    if(params.containsKey('list-tasks')) {
      println "Available tasks:"
      tasks.each{ key, val -> 
        println "  " + key.padRight(12, ' ') + "- " + val.description
      }
      exit 0
    }

    // Retrieve the appropriate specs
    task = params.containsKey('do') ? params.do : params.help
    specs = tasks.containsKey(task) ? tasks[task] : (error "Unknown task.")

    // Identify the script
    code = Channel.fromPath("$projectDir/roadie/scripts/${task}.py")

    // Display task help, if requested
    showHelp(code).view()

    // Verify the presence of input parameters
    if(params.containsKey('do')) {
      if(!params.containsKey('in'))
        error "Please provide input via --in"

      // Forward the appropriate parameters to the task script
      opts = params.inject('') {
        prev, key, val -> specs.params.indexOf(key) > -1 ?
        prev + ' --' + key + ' ' + val : prev + ''
      }

      // Split up the out argument into its directory/file components
      // Directory will be passed to the publishDir directive
      // Filename will be passed to the tool
      out = file(params.out)
      (outd, outf) = out.isDirectory() ? [params.out, ''] : 
        [out.getParent(), out.getName()]
      opts = opts + ' ' + ((outf == '') ? outf : "--out " + outf)

      // Identify the input file and execute the task
      inp = Channel.fromPath(params.in)
      roadie(task, inp, opts, outd, 'move')
    }
}

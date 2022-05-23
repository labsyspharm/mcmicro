nextflow.enable.dsl=2

import org.yaml.snakeyaml.Yaml

// By default, write all output to the current directory
params.outputTo = '.'

if((params.containsKey('help') && (params.help instanceof Boolean)) ||
   (!params.containsKey('help') && 
    !params.containsKey('do') && 
    !params.containsKey('list-tasks')
   )) {
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

    Make a 1024x1024 crop from myimage.ome.tif and write output to result/:
      nextflow run labsyspharm/mcmicro/roadie.nf --do recyze \\
        --in-path myimage.ome.tif \\
        --x 0 --y 0 --w 1024 --h 1024 \\
        --output-to result/
    """
    exit 0
}

process showHelp {
    executor 'local'
    container "${params.contPfx}${params.roadie}"

    when: params.containsKey('help')
    input: path(code); val(specs)
    output: stdout

    """
    echo ''
    python $code ${specs.help}
    """
}

process runTask {
    container "${params.contPfx}${params.roadie}"
    publishDir "${params.outputTo}", mode: 'move'

    when: params.containsKey('do')
    input: path(code); path(input); val(specs)
    output: path("${specs.output}")
    
    script:
        def opts = params.inject('') {
            prev, key, val -> specs.params.indexOf(key) > -1 ?
                prev + ' --' + key + ' ' + val : prev + ''
        }
    """
    python $code --${specs.input} $input $opts
    """
}

workflow {
    // Parse task specs
    tasks = new Yaml().load(file("$projectDir/roadie/tasks.yml"))

    // List available tasks
    if(params.containsKey('list-tasks')) {
        println "Available tasks:"
        tasks.each{ key, val -> println "  " + key + "  - " + val.description}
        exit 0
    }

    // Retrieve the appropriate specs
    task = params.containsKey('do') ? params.do : params.help
    specs = tasks.containsKey(task) ? tasks[task] : (error "Unknown task.")

    // Identify the script
    code = Channel.fromPath("$projectDir/roadie/templates/${task}.py")

    // Display task help, if requested
    showHelp(code, specs).view()

    // Verify the presence of input parameters
    if(params.containsKey('do') && !params.containsKey(specs.input))
      error "Please provide input via --" + specs.input

    // Identify the input file and execute the task
    inp = params.containsKey(specs.input) ? 
      Channel.fromPath(params[specs.input]) : Channel.empty()
    runTask(code, inp, specs)
}

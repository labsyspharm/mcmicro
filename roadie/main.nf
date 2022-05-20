nextflow.enable.dsl=2

if((params.containsKey('help') && (params.help instanceof Boolean)) ||
   (!params.containsKey('help') && 
    !params.containsKey('do') && 
    !params.containsKey('list-tasks')
   )) {
    println """
  Roadie: miscellaneous MCMICRO-related tasks
    
  Usage:
    To run a task,
      nextflow run labsyspharm/mcmicro/roadie --do <task> <options>

    To list available tasks,
      nextflow run labsyspharm/mcmicro/roadie --list-tasks

    To get help about individual tasks,
      nextflow run labsyspharm/mcmicro/roadie --help <task>

  Examples:
      
    nextflow run labsyspharm/mcmicro/roadie --help recyze

    nextflow run labsyspharm/mcmicro/roadie --do recyze \\
      --in-path myimage.ome.tif \\
      --out-path crop.ome.tif \\
      --x 0 --y 0 --w 1024 --h 1024
    """
    exit 0
}

// Task specs (TODO: Move to an external YAML)
def tasks = [
    'recyze': [
        'input'  : 'in-path',
        'output' : 'out-path',
        'params' : ['x', 'x2', 'y', 'y2', 'w', 'h', 'channels'],
        'help'   : '-h'
    ]
]

process showHelp {
    container params.roadie

    when: params.containsKey('help')
    input: path(code); val(specs)
    output: stdout

    """
    echo ''
    python $code ${specs.help}
    """
}

process runTask {
    container params.roadie
    publishDir "${file(params[specs.output]).getParent()}"

    when: params.containsKey('do')
    input: path(code); path(input); val(specs)
    output: path("$out")
    
    script:
        def opts = params.inject('') {
            prev, key, val -> specs.params.indexOf(key) > -1 ?
                prev + " --" + key + " " + val : prev + ''
        }
        out = file(params[specs.output]).getName()
    """
    python $code --${specs.input} $input --${specs.output} $out $opts
    """
}

workflow {
    // List available tasks
    if(params.containsKey('list-tasks')) {
        println "Available tasks:"
        tasks.each{ key, val -> println "  " + key}
        exit 0
    }

    // Retrieve the appropriate specs
    task = params.containsKey('do') ? params.do : params.help
    specs = tasks.containsKey(task) ? tasks[task] : (error "Unknown task.")

    // Identify the script
    code = Channel.fromPath("$projectDir/templates/${task}.py")

    // Display task help, if requested
    showHelp(code, specs).view()

    // Verify the presence of input/output parameters
    if(params.containsKey('do')) {
        if(!params.containsKey(specs.input))  error "Please provide input via --" + specs.input
        if(!params.containsKey(specs.output)) error "Please specify output via --" + specs.output
    }

    // Identify the input file and execute the task
    inp = Channel.fromPath(params[specs.input])
    runTask(code, inp, specs)
}

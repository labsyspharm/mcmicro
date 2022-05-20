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
        'input'  : '--in-path',
        'output' : '--out-path',
        'params' : ['--x', '--x2', '--y', '--y2', '--w', '--h'],
        'help'   : '-h'
    ]
]

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
}

import org.yaml.snakeyaml.Yaml

// Parses module specifications
def parseModuleSpecs(filename) {
    mods = new Yaml().load(file(filename))

    // Filter segmentation modules based on --probability-maps
    mods['segmentation'] = mods['segmentation'].findAll{
        params.probabilityMaps.contains(it.name)
    }

    // Filter downstream modules based on --cell-states
    mods['downstream'] = mods['downstream'].findAll{
        params.cellStates.contains(it.name)
    }

    mods
}

// Determines modules options
def moduleOpts(module) {

    // Check for pipeline-level segmentation channel(s)
    String copts = ''
    if(params.containsKey('segmentationChannel') &&
        module.containsKey('channel')) {

        // Account for 0-based indexing
        if(!module.containsKey('idxbase'))
            error module.name + " spec in modules.yml is missing idxbase key"
        if(module.idxbase == 0)
            idx = params.segmentationChannel.toString().tokenize()
                .collect{"${(it as int)-1}"}.join(' ')
        else
            idx = params.segmentationChannel

        copts = module.channel + ' ' + idx
      }
    
    // Identify all remaining module options by checking for
    //   --module-opts on the command line, or
    //   the existence of opts: in the modules.yml file
    String s = "${module.name}Opts"
    String mopts = ''
    if(params.containsKey(s)) mopts = params."$s"
    else if(module.containsKey('opts')) mopts = module.opts

    copts + ' ' + mopts
}

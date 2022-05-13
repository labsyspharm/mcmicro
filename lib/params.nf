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

        // Module spec must specify whether indexing is 0-based or 1-based
        if(!module.containsKey('idxbase'))
            error module.name + " spec in modules.yml is missing idxbase key"

        // Identify the list of indices
        List idx = params.segmentationChannel.toString().tokenize()

        // Account for 0-based indexing
        if(module.idxbase == 0)
            idx = idx.collect{"${(it as int)-1}"}

        // S3segmenter will work with the first index only
        if(module.name == 's3seg')
            idx = idx[0..0]

        copts = module.channel + ' ' + idx.join(' ')
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

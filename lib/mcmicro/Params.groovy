package mcmicro

import org.yaml.snakeyaml.Yaml

// Parses module specifications
// module - module spec, as parsed by parseModuleSpecs()
// gp - global parameters (usually params in the NF space)
static def parseModuleSpecs(filename, gp) {
    mods = new Yaml().load(file(filename))

    // Filter segmentation modules based on --probability-maps
    mods['segmentation'] = mods['segmentation'].findAll{
        gp.probabilityMaps.contains(it.name)
    }

    // Filter downstream modules based on --cell-states
    mods['downstream'] = mods['downstream'].findAll{
        gp.cellStates.contains(it.name)
    }

    mods
}

// Determines modules options
// module - module spec, as parsed by parseModuleSpecs()
// gp - global parameters (usually params in the NF space)
static def moduleOpts(module, gp) {

    // Check for pipeline-level segmentation channel(s)
    String copts = ''
    if(gp.containsKey('segmentationChannel') &&
        module.containsKey('channel')) {

        // Module spec must specify whether indexing is 0-based or 1-based
        if(!module.containsKey('idxbase'))
            error module.name + " spec in modules.yml is missing idxbase key"

        // Identify the list of indices
        List idx = gp.segmentationChannel.toString().tokenize()

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
    if(gp.containsKey(s)) mopts = gp."$s"
    else if(module.containsKey('opts')) mopts = module.opts

    copts + ' ' + mopts
}

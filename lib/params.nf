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
    // Check for --module-opts
    String s = "${module.name}Opts"
    if( params.containsKey(s) ) return params."$s"

    // Check for defaults opts in the module specs
    if( module.containsKey('opts') ) return module.opts

    // No options provided
    ''
}

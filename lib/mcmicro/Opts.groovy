package mcmicro

import org.yaml.snakeyaml.Yaml
import org.yaml.snakeyaml.DumperOptions

// Recursively updates a spec/opts tree with new values
// orig - original Map
// repl - replacement Map containing new values
static def updateModuleSpecs(orig, repl) {

    // Recurse on Maps
    if((repl instanceof Map) && (orig instanceof Map)) {
        repl.each{ key, val ->
            if( orig.containsKey(key) && 
              ((orig[key] instanceof Map) && (val instanceof Map)) ||
              ((orig[key] instanceof List) && (val instanceof List)) ) {
                orig[key] = updateModuleSpecs(orig[key], val)
            }
            else orig[key] = val
        }
    }

    // Match List items by the name field
    else if((repl instanceof List) && (orig instanceof List)) {
        repl.each{ repli ->
            def i = orig.findIndexOf{it.name == repli.name}
            if(i > -1) orig[i] = updateModuleSpecs(orig[i], repli)
            else orig << repli
        }
    }

    else throw new Exception("New spec format doesn't match the original")

    orig
}

// Parses module specifications
// module - module spec, as parsed by parseModuleSpecs()
// gp - global parameters (usually params in the NF space)
static def parseModuleSpecs(filename, gp) {
    Map mods = new Yaml().load(new File(filename))

    // Process manual overrides
    if(gp.containsKey('modules')) {
        Map umods = new Yaml().load(new File(gp.modules))
        updateModuleSpecs(mods, umods)
    }

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

// Write module specifications to filename in YAML format
static def writeModuleSpecs(specs, filename) {
    DumperOptions style = new DumperOptions();
    style.setPrettyFlow(true);
    style.setDefaultFlowStyle(DumperOptions.FlowStyle.BLOCK);
    new File(filename).withWriter{ out -> 
        new Yaml(style).dump(specs, out) 
    }
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

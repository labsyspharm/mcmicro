package mcmicro

import org.yaml.snakeyaml.Yaml
import org.yaml.snakeyaml.DumperOptions

/**
 * Recursively updates a module spec tree with new values
 *
 * @param orig original Map
 * @param repl replacement Map containing new values
 */
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

/**
 * Parses workflow parameters
 *
 * @param filename file that contains module specifications
 * @param wfp workflow parameters
 */
static def parseModuleSpecs(filename, wfp) {
    Map mods = new Yaml().load(new File(filename))

    // Process manual overrides
    if(wfp.containsKey('modules')) {
        Map umods = new Yaml().load(new File(wfp.modules))
        updateModuleSpecs(mods, umods)
    }

    // Filter segmentation modules based on --probability-maps
    mods['segmentation'] = mods['segmentation'].findAll{
        wfp.probabilityMaps.contains(it.name)
    }

    // Filter downstream modules based on --cell-states
    mods['downstream'] = mods['downstream'].findAll{
        wfp.downstream.contains(it.name)
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

/**
 * Determines modules options
 *
 * @param module module spec, as parsed by parseModuleSpecs()
 * @param wfp workflow parameters
 */
static def moduleOpts(module, wfp) {

    // Check for pipeline-level segmentation channel(s)
    String copts = ''
    if(wfp.containsKey('segmentationChannel') &&
        module.containsKey('channel')) {

        // Module spec must specify whether indexing is 0-based or 1-based
        if(!module.containsKey('idxbase'))
            error module.name + " spec in modules.yml is missing idxbase key"

        // Identify the list of indices
        List idx = wfp.segmentationChannel.toString().tokenize()

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
    if(wfp.containsKey(s)) mopts = wfp."$s"
    else if(module.containsKey('opts')) mopts = module.opts

    copts + ' ' + mopts
}

/**
 * Checks for the existence of parameter key in wfp and, if it exists,
 * constructs a deprecation message of the form
 * "--$key is deprecated; please use $alt"
 */
static def deprCheckEx(wfp, key, alt) {
    if(wfp.containsKey(key))
        throw new Exception("--" + key + " is deprecated; please use " + alt)
}

/**
 * Checks if key equals to val in wfp and, if so,
 * constructs a deprecation message of the form
 * "--$key is deprecated; please use $alt"
 */
static def deprCheckEq(wfp, key, val, alt) {
    if(wfp[key] == val) {
        String msg = "--" + key + " " + val + " is deprecated; please use " + alt
        throw new Exception(msg)
    }
}

/**
 * Checks for deprecated parameters and displays error messages
 *
 * @param wfp workflow parameters
 */
static def deprecateParams(wfp) {
    deprCheckEx(wfp, 'quantificationMask', "--quant-opts '--masks ...'")
    deprCheckEx(wfp, 'illum', '--start-at illumination')
    deprCheckEx(wfp, 'core-opts', '--coreograph-opts')
    deprCheckEx(wfp, 'mask-spatial', "--quant-opts '--masks ...'")
    deprCheckEx(wfp, 'mask-add', "--quant-opts '--masks ...'")
    deprCheckEx(wfp, 'nstates-opts', "--naivestates-opts")
    deprCheckEx(wfp, 'quant-opts', "--mcquant-opts")
    deprCheckEx(wfp, 'cell-states', "--downstream")

    deprCheckEq(wfp, 'probabilityMaps', 'all', 'e.g., --probability-maps unmicst,ilastik')
}

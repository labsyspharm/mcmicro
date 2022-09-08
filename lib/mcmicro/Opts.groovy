package mcmicro

import org.yaml.snakeyaml.Yaml
import org.yaml.snakeyaml.DumperOptions

/**
 * Converts a camelCase parameter name to snake_case
 */
static def camel2snake(s) {
    s.replaceAll( /([A-Z])/, /-$1/ ).toLowerCase()
}

/**
 * Recursively updates a YAML tree with new values
 *
 * @param orig original Map
 * @param repl replacement Map containing new values
 */
static def updateMap(orig, repl) {

    // Recurse on Maps
    if((repl instanceof Map) && (orig instanceof Map)) {
        repl.each{ key, val ->
            if( orig.containsKey(key) && 
              ((orig[key] instanceof Map) && (val instanceof Map)) ||
              ((orig[key] instanceof List) && (val instanceof List)) ) {
                orig[key] = updateMap(orig[key], val)
            }
            else orig[key] = val
        }
    }

    // Match List items by the name field
    else if((repl instanceof List) && (orig instanceof List)) {
        repl.each{ repli ->
            def i = orig.findIndexOf{it.name == repli.name}
            if(i > -1) orig[i] = updateMap(orig[i], repli)
            else orig << repli
        }
    }

    else throw new Exception("New parameter format doesn't match the original")

    orig
}

/**
 * Writes a Map to filename in YAML format
 */
static def writeMap(m, filename) {
    DumperOptions style = new DumperOptions();
    style.setPrettyFlow(true);
    style.setDefaultFlowStyle(DumperOptions.FlowStyle.BLOCK);
    new File(filename).withWriter{ out -> 
        new Yaml(style).dump(m, out) 
    }
}

/**
 * Recursively identifies all named terminal leafs in a Map
 */
static def collectNames(m) {
    // Recurse on Maps and lists
    if(m instanceof Map) {
        if(m.containsKey('name')) return m.name
        return m.collect{key, val -> collectNames(val)}.flatten()
    }
    else if(m instanceof List)
        return m.collect(it -> collectNames(it)).flatten()
    
    else return null
}

/**
 * Cleans up a list of parameters by removing
 *   camelCase versions and predefined keywords, and by sorting the remaining
 *   parameters into workflow: and options: buckets
 *
 * @param pars a Map of parameters
 * @param mspecs a Map of module specifications
 */
static def cleanParams(pars, mspecs) {
    Map workflow = [:]
    Map options = [:]

    // Identify all module names
    def names = collectNames(mspecs)

    // Clean up the parameter list
    // Separate workflow parameters from module options
    pars.findAll{ key, val ->
        Opts.camel2snake(key) == key &&
        !['in', 'cont-pfx', 'roadie', 'modules', 'params'].contains(key)
    }.each{ key, val ->
        String keyc = key.replaceAll( /-opts$/, '' )
        if(names.contains(keyc))
            options[keyc] = val
        else
            workflow[key] = val
    }

    ['workflow':workflow, 'options':options]
}

/** 
 * Validates workflow parameters against a schema
 *
 * @param wfp workflow parameters
 * @param fns filename of the schema
 */
static def validateWFParams(wfp, fns) {
    // Parse the schema
    Map schema = new Yaml().load(new File(fns))

    // Validate workflow parameters against the schema
    wfp.each{ key, val ->
        // Check for deprecated parameters
        if(schema.deprecated.containsKey(key)) {
            String msg = "Parameter " + key + " is deprecated; " +
                "please use " + schema.deprecated[key]
            throw new Exception(msg)
        }

        // Check for unrecognized parameters
        if(!schema.workflow.contains(key)) {
            throw new Exception("Unrecognized parameter " + key)
        }
    }

    // Additional custom validation(s)
    if(wfp['segmentation-recyze'] && 
      !wfp.containsKey('segmentation-channel')) {
        String msg = "Segmentation-recyze requested but no " +
            "segmentation-channel provided"
        throw new Exception(msg)
    }
}

/**
 * Parses MCMICRO parameters
 *
 * @param gp global parameters (usually params in NF space)
 * @param fns filename of the schema
 * @param fnw filename of the default workflow parameters
 */
static def parseParams(gp, fns, fnw) {

    // Load default MCMICRO parameters (mcp)
    Map mcp = new Yaml().load(new File(fnw))

    // Check for the presence of a parameter file in the project directory
    File pproj = new File("${gp.in}/params.yml")
    if(pproj.exists()) {
        Map mproj = new Yaml().load(pproj)
        updateMap(mcp, mproj)
    }

    // Overwrite the parameters from a user-provided file
    if(gp.containsKey('params')) {
        Map mp = new Yaml().load(new File(gp.params))
        updateMap(mcp, mp)
    }

    // Override the module specs, if specified
    if(gp.containsKey('modules')) {
        Map mm = new Yaml().load(new File(gp.modules))
        updateMap(mcp.modules, mm)
    }

    // Override workflow parameters and module options with
    //   command-line arguments (cla), as appropriate
    Map cla = cleanParams(gp, mcp.modules)
    updateMap(mcp, cla)
    validateWFParams(mcp.workflow, fns)

    // Filter segmentation modules based on --segmentation
    mcp.modules['segmentation'] = mcp.modules['segmentation'].findAll{
        mcp.workflow.segmentation.contains(it.name)
    }

    // Filter downstream modules based on --downstream
    mcp.modules['downstream'] = mcp.modules['downstream'].findAll{
        mcp.workflow.downstream.contains(it.name)
    }

    mcp
}

/**
 * Determines modules options
 *
 * @param module module spec, as parsed by parseModuleSpecs()
 * @param mcp MCMICRO parameters, as returned by parseParams()
 */
static def moduleOpts(module, mcp) {

    // Identify workflow parameters (wfp)
    def wfp = mcp.workflow

    // Check for pipeline-level segmentation channel(s)
    String copts = ''
    if(wfp.containsKey('segmentation-channel') &&
        module.containsKey('channel')) {

        // Module spec must specify whether indexing is 0-based or 1-based
        if(!module.containsKey('idxbase'))
            error module.name + " spec in modules.yml is missing idxbase key"

        // Identify the list of indices
        List idx = wfp['segmentation-channel'].toString().tokenize()

        // Account for recyze, if appropriate
        if(wfp['segmentation-recyze'])
            idx = (1..idx.size()).collect{it}

        // Account for 0-based indexing
        if(module.idxbase == 0)
            idx = idx.collect{"${(it as int)-1}"}

        // S3segmenter will work with the first index only
        if(module.name == 's3seg')
            idx = idx[0..0]

        copts = module.channel + ' ' + idx.join(' ')
      }

    // Identify all remaining module options
    String mopts = ''
    if(mcp.options.containsKey(module.name))
        mopts = mcp.options[module.name]

    copts + ' ' + mopts
}

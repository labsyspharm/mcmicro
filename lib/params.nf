import org.yaml.snakeyaml.Yaml

// Parses module specifications
def parseModuleSpecs(filename) {
    new Yaml().load(file(filename))
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

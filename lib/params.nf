import org.yaml.snakeyaml.Yaml

// Parses module specifications
def parseModuleSpecs(filename) {
    new Yaml().load(file(filename))
}
package mcmicro

/**
 * Constructs a path to QC directory from the project path
 *
 * @param pathIn - path to the project directory
 * @param modName - name of the module producing QC (can be '')
 */
static def QC(pathIn, modName) {
    pathIn + "/qc/" + modName
}

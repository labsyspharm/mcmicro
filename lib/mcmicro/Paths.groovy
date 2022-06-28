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

/**
 * Determines which precomputed intermediates are relevant and
 *   returns paths to where to find them
 *
 * @param mcp - MCMICRO parameters, as returned by Opts.parseParams()
 */
static def precomputed() {

    // Valid start/stop steps in the mcmicro pipeline
    mcmsteps = ["raw",      // Step 0
        "illumination",     // Step 1
        "registration",     // Step 2
        "dearray",          // Step 3
        "segmentation",     // Step 4
        "watershed",        // Step 5
        "quantification",   // Step 6
        "downstream"]       // Step 7    
}

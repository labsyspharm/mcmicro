package mcmicro

/**
 * Constructs a path to QC directory from the project path
 *
 * @param pathIn path to the project directory
 * @param modName name of the module producing QC (can be '')
 */
static def QC(pathIn, modName) {
    pathIn + "/qc/" + modName
}

/**
 * Determines which precomputed intermediates are relevant
 *
 * @param mcp MCMICRO parameters, as returned by Opts.parseParams()
 */
static def precomputed(mcp) {

    // Locate workflow parameters (wfp)
    Map wfp = mcp.workflow

    // Deprecation checks
    if(wfp['start-at'] == 'probability-maps' ||
        wfp['stop-at'] == 'probability-maps') {
        String msg = "probability-maps is deprecated; please use " +
            "--start-at segmentation and --stop-at segmentation"
        throw new Exception(msg)
    }

    // Valid start/stop steps in the mcmicro pipeline
    List mcsteps = ["raw",       // Step 0
        "illumination",     // Step 1
        "registration",     // Step 2
        "dearray",          // Step 3
        "segmentation",     // Step 4
        "watershed",        // Step 5
        "quantification",   // Step 6
        "downstream"]       // Step 7

    // Identify starting and stopping indices
    int idxStart = mcsteps.indexOf( wfp['start-at'] )
    int idxStop  = mcsteps.indexOf( wfp['stop-at'] )
    if( idxStart < 0 )
        throw new Exception("Unknown starting step ${wfp['start-at']}")
    if( idxStop < 0 )
        throw new Exception("Unknown stopping step ${wfp['stop-at']}")

    // Advance segmentation -> watershed to ensure no dangling probability maps
    if( idxStop == 4 ) idxStop = 5

    // Define whether a precomputed intermediate is relevant
    [
        raw:                idxStart <= 2,
        illumination:       idxStart == 2, 
        registration:       idxStart == 3 || (idxStart > 3 && !wfp.tma),
        dearray:            idxStart > 3 && wfp.tma,
        'probability-maps': idxStart == 5,
        segmentation:       idxStart == 6,
        quantification:     idxStart == 7
    ]
}

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
 * Determines indices of the start and stop steps in the pipeline
 *
 * @param wfp workflow parameters
 */
static def flowSegment(wfp) {
    // Deprecation checks
    if(wfp['start-at'] == 'probability-maps' ||
        wfp['stop-at'] == 'probability-maps') {
        String msg = "probability-maps is deprecated; please use " +
            "--start-at segmentation and --stop-at segmentation"
        throw new Exception(msg)
    }

    // Valid start/stop steps in the mcmicro pipeline
    List mcsteps = [
        "staging",          // Step 0
        "raw",              // Step 1
        "illumination",     // Step 2
        "registration",     // Step 3
        "background",       // Step 4
        "dearray",          // Step 5
        "segmentation",     // Step 6
        "watershed",        // Step 7
        "quantification",   // Step 8
        "downstream"        // Step 9
        ]

    // Identify starting and stopping indices
    int idxStart = mcsteps.indexOf( wfp['start-at'] )
    int idxStop  = mcsteps.indexOf( wfp['stop-at'] )
    if( idxStart < 0 )
        throw new Exception("Unknown starting step ${wfp['start-at']}")
    if( idxStop < 0 )
        throw new Exception("Unknown stopping step ${wfp['stop-at']}")

    // Advance segmentation -> watershed to ensure no dangling probability maps
    if( idxStop == 6 ) idxStop = 7

    return [idxStart, idxStop]
}

/**
 * Determines which precomputed intermediates are relevant
 *
 * @param wfp workflow parameters
 */
static def precomputed(wfp) {
    // Identify what segment of the pipeline to run
    def (idxStart, idxStop) = flowSegment(wfp)

    // Define whether a precomputed intermediate is relevant
    [
        staging:            idxStart == 0,
        raw:                idxStart <= 3 && idxStart > 0,
        illumination:       idxStart == 3, 
        registration:       idxStart == 4 || (idxStart == 5 && !wfp.background) || (idxStart > 5 && !wfp.tma && !wfp.background), // needed for background (3), tma if no background (4), everything else if both tma and background aren't specified
        background:         idxStart > 3 && wfp.background, // if background specified, required
        dearray:            idxStart > 5 && wfp.tma, // if tma specified, required
        'probability-maps': idxStart == 7,
        segmentation:       idxStart == 8,
        quantification:     idxStart == 9
    ]
}

/**
 * Determines whether to run a given step
 *
 * @param step name of the step in the pipeline
 * @param wfp workflow parameters
 */
static def doirun(step, wfp) {
    // Identify what segment of the pipeline to run
    def (idxStart, idxStop) = flowSegment(wfp)

    switch(step) {
        case 'staging':
            return(idxStart == 0 && idxStop >= 0)
        case 'illumination': 
            return(idxStart <= 2 && idxStop >= 2)
        case 'registration':
            return(idxStart <= 3 && idxStop >= 3)
        case 'background':
            return(idxStart <= 4 && idxStop >= 4 && wfp.background)
        case 'dearray':
            return(idxStart <= 5 && idxStop >= 5 && wfp.tma)
        case 'segmentation':
            return(idxStart <= 6 && idxStop >= 6)
        case 'watershed':
            return(idxStart <= 7 && idxStop >= 7)
        case 'quantification':
            return(idxStart <= 8 && idxStop >= 8)
        case 'downstream':
            return(idxStart <= 9 && idxStop >= 9)
        case 'viz':
            return(wfp.viz)
        default:
            throw new Exception("Unknown step name ${step}")
    }
}
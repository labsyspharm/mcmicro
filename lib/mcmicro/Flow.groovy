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
    List mcsteps = ["raw",  // Step 0
        "illumination",     // Step 1
        "registration",     // Step 2
        "processing",       // Step 3
        "dearray",          // Step 4
        "segmentation",     // Step 5
        "watershed",        // Step 6
        "quantification",   // Step 7
        "downstream"]       // Step 8

    // Identify starting and stopping indices
    int idxStart = mcsteps.indexOf( wfp['start-at'] )
    int idxStop  = mcsteps.indexOf( wfp['stop-at'] )
    if( idxStart < 0 )
        throw new Exception("Unknown starting step ${wfp['start-at']}")
    if( idxStop < 0 )
        throw new Exception("Unknown stopping step ${wfp['stop-at']}")

    // Advance segmentation -> watershed to ensure no dangling probability maps
    if( idxStop == 4 ) idxStop = 5

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
        raw:                idxStart <= 2,
        illumination:       idxStart == 2, 
        processing:         idxStart == 3,
        registration:       idxStart == 4 || (idxStart > 4 && !wfp.tma),
        dearray:            idxStart > 4 && wfp.tma,
        'probability-maps': idxStart == 6,
        segmentation:       idxStart == 7,
        quantification:     idxStart == 8
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
        case 'illumination': 
            return(idxStart <= 1 && idxStop >= 1)
        case 'registration':
            return(idxStart <= 2 && idxStop >= 2)
        case 'processing':
            return(idxStart <= 3 && idxStop >= 3)
        case 'dearray':
            return(idxStart <= 4 && idxStop >= 4 && wfp.tma)
        case 'segmentation':
            return(idxStart <= 5 && idxStop >= 5)
        case 'watershed':
            return(idxStart <= 6 && idxStop >= 6)
        case 'quantification':
            return(idxStart <= 7 && idxStop >= 7)
        case 'downstream':
            return(idxStart <= 8 && idxStop >= 8)
        case 'viz':
            return(wfp.viz)
        default:
            throw new Exception("Unknown step name ${step}")
    }
}

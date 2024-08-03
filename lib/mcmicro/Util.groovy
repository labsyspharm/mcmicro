package mcmicro

static def getSampleName(f, rawdir) {
    // Resolve paths relative to the input project directory
    String rel = rawdir.relativize(f).toString()
    rel.contains('/') ? rel.split('/').head() : 
        rawdir.parent.getName()
}
static def getSampleNameFromDir(f, rawdir) {
    // Resolve paths relative to the input project directory
    String rel = rawdir.relativize(f).toString()
    rel.split('/').head()
}

/**
 * Extracts a file ID as the first token before delim in the filename
 *
 * @param f a file object
 * @param delim a string delimiter
 */
static def getFileID(f, delim) {
    f.getName().toString().split(delim).head()
}

/**
 * Extracts an image ID from a filename by dropping extension
 *
 * @param f a file object
 */
static def getImageID(f) {
    f.getBaseName().toString().replaceFirst(/\.ome$/, "")
}

/**
 * Apply escaping to make an arbitrary string usable as a shell argument.
 */
static def escapeForShell(p) {

    // Escape embedded single-quotes and wrap in single-quotes.
    "'" + p.toString().replace("'", "'\\''") + "'"
}

/**
 * Cleans a filename (string) by replacing spaces and punctuation with _
 */
static def cleanFilename(s) {
    s.toString().replaceAll("[:() ]", "_")
}

/**
 * Extracts marker names from markers.csv
 */
static def getMarkerNames(mcsv) {
    List raw = mcsv.readLines()
    if(raw.size() < 2)
        throw new Exception(mcsv.getName() + " is not in correct format")

    // Find the marker_name column
    List cols = raw[0].split(',')
    int j = cols.indexOf('marker_name')
    if(j < 0)
        throw new Exception(mcsv.getName() + " missing marker_name column")

    // Extract the markers
    raw[1..-1].collect{line -> line.split(',')[j]}
}

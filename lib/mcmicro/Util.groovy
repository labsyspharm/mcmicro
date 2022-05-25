package mcmicro

// Extracts a file ID as the first token before delim in the filename.
static def getFileID(f, delim) {
    f.getName().toString().split(delim).head()
}

// Extracts an image ID from a filename by dropping extension
static def getImageID(f) {
    f.getBaseName().toString().replaceFirst(/\.ome$/, "")
}

static def escapeForShell(p) {
    /**
     * Apply escaping to make an arbitrary string usable as a shell argument.
     */

    // Escape embedded single-quotes and wrap in single-quotes.
    "'" + p.toString().replace("'", "'\\''") + "'"
}

// Extracts marker names from markers.csv
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

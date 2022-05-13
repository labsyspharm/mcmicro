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

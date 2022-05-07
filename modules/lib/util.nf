// Extracts a file ID as the first token before delim in the filename.
def getFileID(f, delim) {
    f.getName().toString().split(delim).head()
}

// Extracts an image ID from a filename by dropping extension
def getImageID(f) {
    tokens = f.getBaseName().toString().replaceFirst(/\.ome$/, "")
}

def escapeForShell(p) {
    /**
     * Apply escaping to make an arbitrary string usable as a shell argument.
     */

    // Escape embedded single-quotes and wrap in single-quotes.
    "'" + p.toString().replace("'", "'\\''") + "'"
}

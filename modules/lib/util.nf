// Extracts a file ID as the first token before delim in the filename.
// Returns a tuple (ID, file)
def getFileID(f, delim) {
    tuple( f.getBaseName().toString().split(delim).head(), f )
}

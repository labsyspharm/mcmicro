// Extracts a file ID as the first token before delim in the filename.
def getFileID(f, delim) {
    f.getBaseName().toString().split(delim).head()
}

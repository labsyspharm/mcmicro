package mcmicro

def static escapeForShell(p) {
    /**
     * Apply escaping to make an arbitrary string usable as a shell argument.
     */

    // Escape embedded single-quotes and wrap in single-quotes.
    "'" + p.toString().replace("'", "'\\''") + "'"
}

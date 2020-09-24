# For developers

## Updating modules with new versions

The versions of individual modules are pinned for standard pipeline runs. When a new version of a particular module becomes available:

1. Increment the corresponding version in `nextflow.config`.
1. Submit a pull request (PR) and resolve any issues raised in the automated Travis-CI tests.

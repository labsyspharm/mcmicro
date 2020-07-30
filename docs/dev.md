# For developers

## Updating modules with new versions

The versions of individual modules are pinned for standard pipeline runs. When a new version of a particular module becomes available:

1. Increment the corresponding version in `nextflow.config`.
1. In the same file, change the pipeline "version" to today's date (this is used exclusively for maintaining multiple versions of the pipeline on O2).
1. Submit a pull request (PR) and resolve any issues raised in the automated Travis-CI tests.
1. Once the PR is merged, update the O2 install by doing

```
nextflow pull labsyspharm/mcmicro
nextflow run labsyspharm/mcmicro/setup.nf -profile O2
```

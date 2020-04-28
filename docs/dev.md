# For developers

## Updating modules with new versions

The versions of individual modules are pinned for standard pipeline runs. When a new version of a particular module becomes available:

1. Increment the corresponding version in `nextflow.config`.
2. In the same file, change the pipeline "version" to today's date (this is used exclusively for maintaining multiple versions of the pipeline on O2).
3. Run the pipeline on the exemplar(s) to ensure that the new version works as expected.
4. If everything works, submit a pull request (PR).
5. Once the PR is merged, update the O2 install by doing

```
nextflow pull labsyspharm/mcmicro-nf
nextflow run labsyspharm/mcmicro-nf/setup.nf -profile O2
```

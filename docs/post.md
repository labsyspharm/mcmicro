# Nextflow tips and tricks

## Handling intermediate files

The intermediate files in the `work/` directory allow you to restart a pipeline partway, without re-running everything from scratch. For example, consider the following scenario on O2:

``` bash
module load java conda2      # <--- OOPS, forgot matlab

# This run will fail with "matlab: command not found"
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-002 --tma -profile O2

# N E X T F L O W  ~  version 20.01.0
# Launching `labsyspharm/mcmicro-nf` [backstabbing_fermi] - revision: e5ff35c351 [master]
# executor >  slurm (2)
# [-        ] process > illumination   -
# [57/1c3712] process > ashlar         [100%] 1 of 1 ✔
# [cf/7b42eb] process > dearray        [100%] 1 of 1, failed: 1 ✘
# [-        ] process > unmicst        -
# [-        ] process > s3seg          -
# [-        ] process > quantification -

# Address the issue by loading the appropriate module
module load matlab

# Restart the pipeline from the dearray step using `-resume`
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-002 --tma -profile O2 -resume

# N E X T F L O W  ~  version 20.01.0
# Launching `labsyspharm/mcmicro-nf` [condescending_wing] - revision: e5ff35c351 [master]
# executor >  slurm (13)
# [-        ] process > illumination   -
# [57/1c3712] process > ashlar         [100%] 1 of 1, cached: 1 ✔      <- NOTE: cached
# [dd/1928b1] process > dearray        [100%] 1 of 1 ✔
# [1c/82bcd4] process > unmicst        [100%] 4 of 4 ✔
# [f7/02146c] process > s3seg          [100%] 4 of 4 ✔
# [14/25a33c] process > quantification [100%] 4 of 4 ✔
```

As you run the pipeline on your datasets, the size of the `work/` directory can grow substantially. Use [nextflow clean](https://github.com/nextflow-io/nextflow/blob/cli-docs/docs/cli.rst#clean) to selectively remove portions of the work directory. Use `-n` flag to list which files will be removed, inspect the list to ensure that you don't lose anything important, and repeat the command with `-f` to actually remove the files:

``` bash
# Remove work files associated with most-recent run
nextflow clean -n last           # Show what will be removed
nextflow clean -f last           # Proceed with the removal

# Remove all work files except those associated with the most-recent run
nextflow clean -n -but last
nextflow clean -f -but last
```

## Accessing post-run information with nextflow log

TODO

# Nextflow tips and tricks

## Handling intermediate files

The intermediate files in the `work/` directory allow you to restart a pipeline partway, without re-running everything from scratch. For example, consider the following scenario on O2:

``` bash
# This run will fail because --some-invalid-arg is not a valid argument for UnMicst
nextflow run labsyspharm/mcmicro --in ~/data/exemplar-001 --unmicst-opts '--some-invalid-arg'

# N E X T F L O W  ~  version 20.01.0
# Launching `labsyspharm/mcmicro` [jolly_hodgkin] - revision: eeaa364408 [master]
# executor >  local (2)
# [-        ] process > illumination   -
# [7e/bf811b] process > ashlar         [100%] 1 of 1 ✔
# [-        ] process > dearray        -
# [29/dfdfac] process > unmicst        [100%] 1 of 1, failed: 1 ✘
# [-        ] process > ilastik        -
# [-        ] process > s3seg          -
# [-        ] process > quantification -
# [-        ] process > naivestates    -

# Address the issue by removing the invalid argument and restart the pipeline with -resume
nextflow run labsyspharm/mcmicro --in ~/data/exemplar-001 -resume

N E X T F L O W  ~  version 20.01.0
Launching `labsyspharm/mcmicro` [backstabbing_goodall] - revision: eeaa364408 [master]
executor >  local (1)
[-        ] process > illumination   -
[7e/bf811b] process > ashlar         [100%] 1 of 1, cached: 1 ✔      <- NOTE: cached
[-        ] process > dearray        -
[9e/08ab35] process > unmicst        [100%] 1 of 1 ✔
[-        ] process > ilastik        -
[84/918c38] process > s3seg          [100%] 1 of 1 ✔
[0a/7f71f7] process > quantification [100%] 1 of 1 ✔
[ff/be5a97] process > naivestates    [100%] 1 of 1 ✔
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

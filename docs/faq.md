---
layout: default
title: FAQ
nav_order: 80
---

# Frequently Asked Questions

{:toc}

## Pipeline execution

### Q: How do I resume a pipeline run that halted partway?

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

# N E X T F L O W  ~  version 20.01.0
# Launching `labsyspharm/mcmicro` [backstabbing_goodall] - revision: eeaa364408 [master]
# executor >  local (1)
# [-        ] process > illumination   -
# [7e/bf811b] process > ashlar         [100%] 1 of 1, cached: 1 ✔      <- NOTE: cached
# [-        ] process > dearray        -
# [9e/08ab35] process > unmicst        [100%] 1 of 1 ✔
# [-        ] process > ilastik        -
# [84/918c38] process > s3seg          [100%] 1 of 1 ✔
# [0a/7f71f7] process > quantification [100%] 1 of 1 ✔
# [ff/be5a97] process > naivestates    [100%] 1 of 1 ✔
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

## Pre-processing

### Q: How does mcmicro handle multi-file formats such as `.xdce`?

A: Registration and illumination correction modules in mcmicro are [Bio-Formats compatible](https://docs.openmicroscopy.org/bio-formats/6.0.1/supported-formats.html). Place all files into the `raw/` subdirectory, as described in [Directory Structure](directory-structure.html), and mcmicro modules will correctly identify and use the relevant ones.

## Segmentation

### Q: How do I run mcmicro with my own ilastik model?

A: Use the `--ilastik-model` parameter. Note that the parameter must be specified *outside** `--ilastik-opts`. For example,

```
nextflow run labsyspharm/mcmicro --in /my/data --probability-maps ilastik --ilastik-model mymodel.ilp
```

### Q: How do I check the quality of segmentation?

A: After a successful mcmicro run, two-channel tif files containing DAPI and nuclei/cell/cytoplasm outlines will reside in `qc/s3seg`. Segmentation quality can be assessed through visual inspection of these files in, e.g., [napari](https://napari.org/).

### Q: How do I handle images acquired without pixel binning?

![](images/FAQ-binning.png)

A: There are two adjustments to make:

1. Adjust `--scalingFactor` for UnMicst, which controls the ratio of the current pixel width (W2) to exemplar pixel width (W1) and is not related to area (See schematic).
1. In S3Segmenter, `--cytoDilation` controls the number of pixels from the edge of the nucleus to expand in creating the cytoplasm mask. Take the value optimized for 2x binned images and multiply it by 2 (i.e., if `--cytoDilation 3` is optimal for 2x binning, then the new value will `--cytoDilation 6`).

Use `--unmicst-opts` and `--s3seg-opts` to pass the new values to UnMicst and S3Segmenter, respectively:

```
nextflow run labsyspharm/mcmicro --in /path/to/unbinned/data --unmicst-opts '--scalingFactor 0.5' --s3seg-opts '--cytoDilation 6'
```


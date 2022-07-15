---
layout: default
title: Parameters
nav_order: 5
---

## General pipeline usage

The basic pipeline execution consists of:
1. Ensuring you have the latest version of the pipeline  
2. Creating a parameters file
2. Using `--in` and `--params` to point the pipeline at the data and the parameter file, respectively

``` bash
# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro

# To run the pipeline with default parameter values, omit --params
nextflow run labsyspharm/mcmicro --in path/to/my/data
```
>(Where `path/to/my/data` is replaced with your specific path.)

{: .fs-3}

## Specifying path for intermediate files
By default Nextflow writes intermediate files to a `work/` directory inside whatever location you initiate a pipeline run from. Use `-w` flag to provide a different location. 

``` bash
nextflow run labsyspharm/mcmicro --in /path/to/my-data -w /path/to/work/
```

## Parameter file

The parameter file must be specified in standard YAML format using the following three namespaces:

* `workflow` - pipeline-level parameters controlling overall behavior of MCMICRO
* `options` - module-level parameters that will be forwarded to individual tools; the entries are matched against `name` fields in `modules`
* `modules` - module specifications, such as container name and version, whether the module uses 0-based or 1-based indexing, etc.

An example `params.yml` may look as follows:

``` yaml
workflow:
  start-at: registration
  stop-at: quantification
  viz: true
  segmentation-channel: 1 5
options:
  ashlar: -m 15
  s3seg: --maxima-footprint-size 5
modules:
  watershed:
    version: 1.4.0-large
```

and can be supplied to the pipeline with

```
nextflow run labsyspharm/mcmicro --in path/to/my/data --params myparams.yml
```

### Workflow parameters

* `start-at` 
  * **Description:** Name of the first to be exeucted by the pipeline
  * **Valid values:** `illumination`, `registration`, `dearray` (TMA only), `segmentation`, `watershed`, `quantification`, `downstream`
  * **Default:** `registration`
  * **Example:** `start-at: segmentation`
* `stop-at`
  * **Description:** Name of the final step to be executed by the pipeline
  * **Valid values:** `illumination`, `registration`, `dearray` (TMA only), `segmentation`, `quantification`, `downstream`
  * **Default:** `quantification`
  * **Example:** `stop-at: downstream`
* `tma` 
  * **Description:** If `true`, MCMICRO treats input data as a TMA. If `false`, the input is assumed to be a whole-slide image
  * **Valid values:** `true`, `false`
  * **Default:** `false`
  * **Example:** `tma: true`
* `segmentation-channel` 
  * **Description:** One or more channels to use for segmentation, specified using 1-based indexing; values will be forwarded to all segmentation modules
  * **Valid values:** one or more positive integers, each separated with a space
  * **Default:** `1`
  * **Example:** `segmentation-channel: 1 5`
* `ilastik-model` 
  * **Description:** A custom `.ilp` file to be used as the classifier model for ilastik
  * **Valid values:** A full path to any file
  * **Default:** None
  * **Example:** `ilastik-model: /home/users/me/mymodel.ilp`
* `segmentation`
  * **Description:** A list of segmentation modules to run
  * **Valid values:** One or more of `unmicst`, `ilastik`, `mesmer`, `cypository`, specified as a YAML list
  * **Default:** `unmicst`
  * **Example:** `segmentation: [unmicst, ilastik]`
* `downstream`
  * **Descriont:** A list of downstream modules to run
  * **Valid values:** One or more of `naivestates`, `scimap`, `fastpg`, `scanpy`, `flowsom`
  * **Default:** `scimap`
  * **Example:** `downstream: [scanpy, flowsom]`
* `viz` 
  * **Description:** Whether to generate a vizualization with Auto-Minerva
  * **Valid values:** `true`, `false`
  * **Default:** `false`
  * **Example:** `viz: true`
* `qc-files`
  * **Description:** Wheter QC files should be copied, moved or symbolically linked from work directories to the project directory
  * **Valid values:** `copy`, `move`, `symlink`
  * **Default:** `copy`
  * **Example:** `qc-files: move`

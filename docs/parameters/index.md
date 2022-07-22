---
layout: default
title: Parameters
nav_order: 5
---

## General pipeline usage

The basic pipeline execution consists of:
1. Ensuring you have the latest version of the pipeline  
1. Creating a [parameter file](./#parameter-file)
1. Using --in to point the pipeline at the data

``` bash
# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro

# Run the pipeline on data (starting from the registration step through quantification, by default)
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


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

---

<br>

### Specifying start and stop modules
By default, the pipeline starts from the registration step ([ASHLAR]({{site.baseurl}}/modules/#ashlar)), proceeds through [UnMICST]({{site.baseurl}}/modules/#unmicst), [S3segmenter]({{site.baseurl}}/modules/#s3segmenter), and stops after executing the quantification [MCQuant]({{site.baseurl}}/modules/#mcquant) step. 

Use `--start-at` and `--stop-at` flags to execute any contiguous section of the pipeline instead. Any subdirectory name listed in the [directory structure](./#directory-structure) is a valid starting and stopping point.  


``` bash
# If you already have a pre-stitched TMA image, start at the dearray step
nextflow run labsyspharm/mcmicro --in path/to/exemplar-002 --tma --start-at dearray

# If you want to run the illumination profile computation and registration only
nextflow run labsyspharm/mcmicro --in path/to/exemplar-001 --start-at illumination --stop-at registration
```
**Note:** Starting at any step beyond registration requires pre-computed output of the previous steps placed at the correct location in the project directory.
{: .fs-3}

<br>

### Specifying module-specific parameters
The pipeline provides a sensible set of [default parameters for individual modules]({{site.baseurl}}/modules/). To change these use <br> `--ashlar-opts`, `--unmicst-opts`, `--s3seg-opts` and `--quant-opts`. 

For example: ```nextflow run labsyspharm/mcmicro --in /path/to/my-data --ashlar-opts '-m 35 --pyramid' ``` will provide `-m 35 --pyramid` as additional command line arguments to ASHLAR.

*Go to [modules]({{site.baseurl}}/modules/) for a list of options available for each module.*

<br>

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


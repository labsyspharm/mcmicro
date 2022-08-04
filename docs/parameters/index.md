---
layout: default
title: Parameters
nav_order: 5
---

# Supplying parameters to MCMICRO

Parameters can be supplied in three ways,

1. by [providing `params.yml` as a file](./#parameter-files) in the project [directory]({{site.baseurl}}/io.html#input),
2. by [pointing to a `params.yml` file in another directory](./#specifying-an-external-parameter-file), or
3. by [overwriting individual parameters](./#overwriting-individual-parameters) on the command line. If no parameters are supplied, MCMICRO will run with a set of [default parameter values](https://github.com/labsyspharm/mcmicro/blob/master/config/defaults.yml). MCMICRO will resolve conflicting parameter values with a [priority list](./#parameter-value-prioritization).

On this page, you will find more information about how to supply parameters to the pipeline for each of these methods, how to [change where intermediate files are stored](./#specifying-path-for-intermediate-files) and [how to specify start and stop modules](./#specifying-start-and-stop-modules).

## Parameter files

Parameter files must be specified in standard YAML format using the following three namespaces:

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

MCMICRO will fall back on [default values](https://github.com/labsyspharm/mcmicro/blob/master/config/defaults.yml){:target="_blank"} for any setting not specified in a parameter file.

Please see the subpages for more information about [workflow](./workflow.html), [options](./core.html), and [modules](./specs.html) namespaces.

## Specifying an external parameter file

By default, MCMICRO will look for `params.yml` in the [project directory]({{site.baseurl}}/io.html#input). If you want to use the same parameter values for multiple projects, you can instead create a single `myparams.yml` file (elsewhere) and supply the path to this file to the pipeline with `--params`:

``` bash
## External parameter files can be supplied with --params
nextflow run labsyspharm/mcmicro --in /path/to/project1 --params /path/to/myparams.yml

## The same parameter file can then be used in multiple projects
nextflow run labsyspharm/mcmicro --in /path/to/project2 --params /path/to/myparams.yml
```

Values specified in the external `myparams.yml` will overwrite any values found in `params.yml` files of individual project directories.

## Overwriting individual parameters

Individual parameters can be overwritten directly on the command line. This provides an opportunity for "one-off" runs without the need to modify existing parameter files.

``` bash
## Most workflow parameters can be specified as is
nextflow run labsyspharm/mcmicro --in /path/to/project --start-at segmentation

## There is no need to explicitly specify "true" for binary parameters
nextflow run labsyspharm/mcmicro --in /path/to/project --tma --viz

## Enclose multiple values inside single quotes
nextflow run labsyspharm/mcmicro --in /path/to/project --segmentation-channel '1 5'

## Add -opts suffix for module specific options
nextflow run labsyspharm/mcmicro --in /path/to/project --ashlar-opts '-m 50'
```

## Parameter value prioritization

Given the many ways to specify parameters, conflicting values will be resolved according to the following prioritization:

* (Lowest) Parameter values in [config/defaults.yml](https://github.com/labsyspharm/mcmicro/blob/master/config/defaults.yml).
* Parameter values in `params.yml`, if one found in the directory supplied via `--in`. **(This is recommended.)**
* Parameter values in a YAML file provided via `--params`.
* (Highest) Values for individual parameters provided as double-dashed command-line arguments (e.g., `--start-at`)

## Specifying path for intermediate files
By default, Nextflow writes intermediate files to a `work/` directory inside whatever location you initiate a pipeline run from. Use `-w` flag to provide a different location. 

``` bash
nextflow run labsyspharm/mcmicro --in /path/to/my-data -w /path/to/work/
```

## Specifying start and stop modules
By default, the pipeline starts from the registration step ([ASHLAR]({{site.baseurl}}/parameters/core.html#ashlar)), proceeds through [UnMICST]({{site.baseurl}}/parameters/core.html#unmicst), [S3segmenter]({{site.baseurl}}/parameters/core.html#s3segmenter), and stops after executing the quantification [MCQuant]({{site.baseurl}}/parameters/core.html#mcquant) step.

Use `start-at` and `stop-at` workflow parameters to execute any contiguous section of the pipeline instead.

**Example 1: Running illumination correction and registration only**

``` yaml
workflow:
  start-at: illumination
  stop-at: registration
```

**Example 2: Start by dearraying an already-registered TMA image**

``` yaml
workflow:
  tma: true
  start-at: dearray
```

**Note:** Starting at any step beyond registration requires pre-computed output of the previous steps placed at the correct location in the project directory.
{: .fs-3}

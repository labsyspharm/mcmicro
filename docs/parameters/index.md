---
layout: default
title: Parameters
nav_order: 5
---

# Supplying parameters to MCMICRO

MCMICRO uses [default values](https://github.com/labsyspharm/mcmicro/blob/master/config/defaults.yml){:target="_blank"} for any settings not specified in a parameter file. MCMICRO will resolve conflicting parameter values with a [priority list](./#parameter-value-prioritization).
{: .fs-5}
{: .fw-400}

---

Parameters can be supplied in two ways,
{: .fs-5}
{: .fw-300}

1. by [providing `params.yml` as a file](./#option-1-parameter-files-recommended) (**RECOMMENDED**)
	1. in the project [directory]({{site.baseurl}}/io.html#input){:target="_blank"} 
	2. or by [pointing to a `params.yml` file in another directory](./#specifying-an-external-parameter-file)
3. by [overwriting individual parameters](./#overwriting-individual-parameters) on the command line.

On this page, you will find more information about how to supply parameters to the pipeline for each of these methods, how to [change where intermediate files are stored](./#specifying-path-for-intermediate-files).

---

## Option 1: Parameter files (RECOMMENDED)

Parameters must be specified in standard YAML format using the following three namespaces:
{: .fs-5}
{: .fw-300}

* [`workflow`](./workflow) - pipeline-level parameters controlling overall behavior of MCMICRO  
<br>
* [`options`](./core) - module-level parameters that will be forwarded to individual tools
	* the entries are matched against `name` fields in `modules`   
<br>
* [`modules`](./specs) - module specifications, such as container name and version, whether the module uses 0-based or 1-based indexing, etc.  (**For advanced users!**)

<br>
_Please see the subpages for more information about the parameters for the [workflow](./workflow.html), [options](./core.html), and [modules](./specs.html) namespaces._
{: .text-center }

<br>
An example `params.yml` may look as follows:
{: .fs-5}
{: .fw-300}

``` yaml
workflow:
  start-at: registration
  stop-at: quantification
  viz: true
  segmentation-channel: 1 5
options:
  ashlar: --flip-y -c 5
  s3seg: --maxima-footprint-size 5
modules:
  watershed:
    version: 1.4.0-large
```

Note: When supplying multiple `option` parameters for the same module, only use the module name ONCE. See the line for `ashlar` in the example above.
{: .fs-5}
{: .fw-300}
<br>

### Specifying an external parameter file

**By default, MCMICRO will look for `params.yml` in the [project directory]({{site.baseurl}}/io.html#input).** If you want to use the same parameter values for multiple projects, you can instead create a single `myparams.yml` file (elsewhere) and supply the path to this file to the pipeline with `--params`:

``` bash
## External parameter files can be supplied with --params
nextflow run labsyspharm/mcmicro --in /path/to/project1 --params /path/to/externalparams.yml

## The same parameter file can then be used in multiple projects
nextflow run labsyspharm/mcmicro --in /path/to/project2 --params /path/to/externalparams.yml
```

Values specified in the external `externalparams.yml` will overwrite any values found in `params.yml` files of individual project directories. *See [parameter prioritization](./#parameter-value-prioritization) below.*

<br>

## Option 2: Overwriting individual parameters

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

<br>

## Parameter value prioritization

If the pipeline is supplied with conflicting parameters, the conflicting values will be resolved according to the following prioritization:

* **(Lowest)** Default parameter values in [config/defaults.yml](https://github.com/labsyspharm/mcmicro/blob/master/config/defaults.yml).
* Parameter values in `params.yml` of the project [directory]({{site.baseurl}}/io.html#input)
	* _(We recommend supplying parameters within your project directory)_
* Parameter values in a YAML file provided via `--params`.
* **(Highest)** Individual parameters provided as double-dashed command-line arguments (e.g., `--start-at`)

<br>

## Specifying path for intermediate files
By default, Nextflow writes intermediate files to a `work/` directory inside whatever location you initiate a pipeline run from. Use `-w` flag to provide a different location. 

``` bash
nextflow run labsyspharm/mcmicro --in /path/to/my-data -w /path/to/work/
```



---
layout: default
title: Running mcmicro
nav_order: 20
---

# Running mcmicro

The basic pipeline execution consists of 1) ensuring you have the latest version of the pipeline, followed by 2) using `--in` to point the pipeline at the data.

``` bash
# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro

# Run the pipeline on exemplar data (starting from the registration step, by default)
nextflow run labsyspharm/mcmicro --in path/to/exemplar-001

# Use --tma to dearray a tissue microarray and process each core in parallel
nextflow run labsyspharm/mcmicro --in path/to/exemplar-002 --tma
```

By default, the pipeline starts from the registration step and stops after executing the quantification step. Use `--start-at` and `--stop-at` flags to execute any contiguous section of the pipeline instead. Any subdirectory name listed in [Directory Structure](steps.html) is a valid starting and stopping point. **Note that starting at any step beyond registration requires pre-computed output of the previous steps placed at the correct location in the project directory.**

``` bash
# If you already have a pre-stitched TMA image, start at the dearray step
nextflow run labsyspharm/mcmicro --in path/to/exemplar-002 --tma --start-at dearray

# If you want to run the illumination profile computation and registration only
nextflow run labsyspharm/mcmicro --in path/to/exemplar-001 --start-at illumination --stop-at registration
```

By default Nextflow writes intermediate files to a `work/` directory inside whatever location you initiate a pipeline run from. Use `-w` flag to provide a different location. (See below for more information about these files.)

``` bash
nextflow run labsyspharm/mcmicro --in /path/to/exemplar-001 -w /path/to/work/
```

### Specifying module-specific parameters

The pipeline provides a sensible set of [default parameters for individual modules](parameter-reference.html). To change these use <br> `--ashlar-opts`, `--unmicst-opts`, `--s3seg-opts` and `--quant-opts`. For example,
``` bash
nextflow run labsyspharm/mcmicro --in /path/to/exemplar-001 --ashlar-opts '-m 35 --pyramid'
```
will provide `-m 35 --pyramid` as additional command line arguments to ASHLAR.

### Using YAML parameter files

As the number of custom flags grows, providing them all on the command line can become unwieldy. Instead, parameter values can be stored in a YAML file, which is then provided to nextflow using <br> `-params-file`. The general rules of thumb for composing YAML files:
1. Anything that would appear as `--param value` on the command line should be `param: value` in the YAML file.
1. Anything that would appear as `--flag` on the command line should be `flag: true` in the YAML file.
1. The above only applies to double-dashed arguments (which are passed to the pipeline). The single-dash arguments (like `-profile`) cannot be moved to YAML, because they are given to nextflow; the pipeline never sees them.

For example, consider the following command:
``` bash
nextflow run labsyspharm/mcmicro --in /data/exemplar-002 --tma --start-at dearray --ashlar-opts '-m 35 --pyramid'
```

All double-dashed arguments can be moved to a YAML file (e.g., **myexperiment.yml**) using the rules above:
``` yaml
in: /data/exemplar-002
tma: true
start-at: dearray
ashlar-opts: -m 35 --pyramid
```

The YAML file can then be fed to the pipeline via
``` bash
nextflow run labsyspharm/mcmicro -params-file myexperiment.yml
```


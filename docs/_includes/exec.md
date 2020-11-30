# Pipeline execution

The basic pipeline execution consists of 1) ensuring you have the latest version of the pipeline, followed by 2) using `--in` to point the pipeline at the data.

``` bash
# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro

# Run the pipeline on exemplar data (starting from the registration step, by default)
nextflow run labsyspharm/mcmicro --in path/to/exemplar-001

# Use --tma to dearray a tissue microarray and process each core in parallel
nextflow run labsyspharm/mcmicro --in path/to/exemplar-002 --tma
```

By default, the pipeline starts from the registration step. Use `--start-at` and `--stop-at` flags to execute any contiguous section of the pipeline instead. Any subdirectory name listed in [Directory Structure](#directory-structure) is a valid starting and stopping point. **Note that starting at any step beyond registration requires pre-computed output of the previous steps placed at the correct location in the project directory.**

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

The pipeline provides a sensible set of default parameters for individual modules. To change these use `--ashlar-opts`, `--unmicst-opts`, `--s3seg-opts` and `--quant-opts`. For example,
``` bash
nextflow run labsyspharm/mcmicro --in /path/to/exemplar-001 --ashlar-opts '-m 35 --pyramid'
```
will provide `-m 35 --pyramid` as additional command line arguments to ASHLAR.

### Using YAML parameter files

As the number of custom flags grows, providing them all on the command line can become unwieldy. Instead, parameter values can be stored in a YAML file, which is then provided to nextflow using `-params-file`. The general rules of thumb for composing YAML files:
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

## O2 execution

To run the pipeline on O2, four additional steps are required:
1. You must load the necessary O2 modules.
1. All pipeline calls need to have the flag `-profile O2`. Use `-profile O2large` or `-profile O2massive` for large or very large whole-slide images, respectively. Use `-profile O2TMA` for TMAs. The profiles differ in the amount of resources requested for each module.
1. To avoid running over on your disk quota, it is also recommended to use `/n/scratch3` for holding the `work/` directory. Furthermore, `n/scratch3` is faster than `/home` or `/n/groups`, so jobs will complete faster. 
1. Instruct Nextflow to generate an execution report in a central location by adding `-with-report "/n/groups/lsp/mcmicro/reports/$USER-$EPOCHREALTIME.html"` to your Nextflow command. This will help the staff evaluate resource usage and success/failure rates  .

Compose an `sbatch` script that encapsulates resource requests, module loading and the `nextflow` command into a single entity. Create a `submit_mcmicro.sh` file based on the following template:

```
#!/bin/sh
#SBATCH -p short
#SBATCH -J nextflow_O2              
#SBATCH -o run.o
#SBATCH -e run.e
#SBATCH -t 0-12:00
#SBATCH --mem=8G
#SBATCH --mail-type=END         # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=user@university.edu   # Email to which notifications will be sent

module purge
module load java
/home/$USER/bin/nextflow run labsyspharm/mcmicro --in /n/scratch3/users/${USER:0:1}/$USER/exemplar-001 -profile O2 -w /n/scratch3/users/${USER:0:1}/$USER/work -with-report "/n/groups/lsp/mcmicro/reports/$USER-$EPOCHREALTIME.html"
```
replacing relevant fields (e.g., `user@university.edu`) with your own values.

The pipeline run can then be kicked off with `sbatch submit_mcmicro.sh`.

### Requesting O2 resources

The default profiles `O2`, `O2large` and `O2massive` establish reasonable defaults for O2 resource requests. These will work for most scenarios, but individual projects may also have custom time and memory requirements. To overwrite the defaults, compose a new config file (e.g., `myproject.config`) specifying the desired custom requirements using [process selectors](https://www.nextflow.io/docs/latest/config.html#process-selectors). For example, to request 128GB of memory and 96 hours in the `medium` queue for ASHLAR, one would specify
```
process{
  withName:ashlar {
    queue  = 'medium'
    time   = '96h'
    memory = '128G'
  }
}
```
Use [existing profiles](https://github.com/labsyspharm/mcmicro/blob/master/config/large.config) as examples. Once `myproject.config` is composed, it can be provided to a `nextflow run` command using the `-c` flag:

```
nextflow run labsyspharm/mcmicro --in /path/to/exemplar-001 -profile O2 -c myproject.config
```

Note that `-profile` is still needed because it defines additional configurations, such as where to find the container modules. `myproject.config` simply overrides a portion of the fields in the overall profile.

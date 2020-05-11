# Pipeline execution

The basic pipeline execution consists of 1) ensuring you have the latest version of the pipeline, followed by 2) using `--in` to point the pipeline at the data.

``` bash
# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro-nf

# Run the pipeline on exemplar data
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-001

# Use --tma to dearray a tissue microarray and process each core in parallel
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-002 --tma
```

By default, the pipeline starts from the registration step. Use `--start-at` and `--stop-at` flags to execute any contiguous section of the pipeline instead. Any subdirectory name listed in [Directory Structure](dir.html) is a valid starting and stopping point. **Note that starting at any step beyond registration requires pre-computed output of the previous steps placed at the correct location in the project directory.**

``` bash
# If you already have a pre-stitched TMA image, start at the dearray step
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-002 --tma --start-at dearray

# If you want to run the illumination profile computation and registration only
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-001 --start-at illumination --stop-at registration
```

By default Nextflow writes intermediate files to a `work/` directory inside whatever location you initiate a pipeline run from. Use `-w` flag to provide a different location. (See below for more information about these files.)

``` bash
nextflow run labsyspharm/mcmicro-nf --in /path/to/exemplar-001 -w /path/to/work/
```

### Specifying module-specific parameters

The pipeline provides a sensible set of default parameters for individual modules. To change these use `--ashlar-opts`, `--unmicst-opts`, `--s3seg-opts` and `--quant-opts`. For example,
``` bash
nextflow run labsyspharm/mcmicro-nf --in /path/to/exemplar-001 --ashlar-opts '-m 35 --pyramid'
```
will provide `-m 35 --pyramid` as additional command line arguments to ASHLAR.

### Using YAML parameter files

As the number of custom flags grows, providing them all on the command line can become unwieldy. Instead, parameter values can be stored in a YAML file, which is then provided to nextflow using `-params-file`. The general rules of thumb for composing YAML files:
1. Anything that would appear as `--param value` on the command line should be `param: value` in the YAML file.
1. Anything that would appear as --flag on the command line should be `flag: true` in the YAML file.
1. The above only applies to double-dashed arguments (which are passed to the pipeline). The single-dash arguments (like `-profile`) cannot be moved to YAML, because they are given to nextflow; the pipeline never sees them.

For example, consider the following command:
``` bash
nextflow run labsyspharm/mcmicro-nf --in /data/exemplar-002 --tma --skip-ashlar --ashlar-opts '-m 35 --pyramid'
```

All double-dashed arguments can be moved to a YAML file (e.g., **myexperiment.yml**) using the rules above:
``` yaml
in: /data/exemplar-002
tma: true
skip-ashlar: true
ashlar-opts: -m 35 --pyramid
```

The YAML file can then be fed to the pipeline via
``` bash
nextflow run labsyspharm/mcmicro-nf -params-file myexperiment.yml
```

## O2 execution

To run the pipeline on O2, three additional steps are required:
1. You must load the necessary O2 modules;
2. All pipeline calls need to have the flag `-profile O2`;
3. The pipeline execution must be initiated on a compute node (the process is too resource-intensive for a login node and will be automatically terminated).

``` bash
# Load necessary modules (matlab is optional, if not working with TMA)
module load java matlab conda2

# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro-nf

# All previous commands require an additional `-profile O2` flag and must be run from a compute node
srun -p priority -t 0-12 --mem 8G nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-001 -profile O2
srun -p priority -t 0-12 --mem 8G nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-002 --tma -profile O2
```

In the above, `-t 0-12 --mem 8G` requests 12 hours of compute time and 8GB of memory from the O2 cluster. To avoid running over on your disk quota, it is also recommended to use `/n/scratch2` for holding the `work/` directory. Furthermore, `n/scratch2` is faster than `/home` or `/n/groups`, so jobs will complete faster:

```
srun -p priority -t 0-12 --mem 8G \
  nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-001 -profile O2 -w /n/scratch2/$USER/work
```

An alternative to the above `srun` command is to compose an `sbatch` script that encapsulates resource requests, module loading and the `nextflow` command into a single entity. Create a `submit_mcmicro.sh` file based on the following template:

```
#!/bin/sh
#SBATCH -p medium
#SBATCH -J nextflow_O2              
#SBATCH -o run.o
#SBATCH -e run.e
#SBATCH -t 0-12:00
#SBATCH --mem=8G
#SBATCH --mail-type=END         # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=user@university.edu   # Email to which notifications will be sent

module purge
module load java matlab conda2
/home/$USER/bin/nextflow labsyspharm/mcmicro-nf --in /n/scratch2/$USER/exemplar-001 -profile O2 -w /n/scratch2/$USER/work
```
replacing relevant fields (e.g., `user@university.edu`) with your own values.

The pipeline run can then be kicked off with `sbatch submit_mcmicro.sh`.


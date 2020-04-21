# mcmicro-nf: Multiple-choice microscopy pipeline

## Installation

Install [Nextflow](https://www.nextflow.io/): `curl -s https://get.nextflow.io | bash`

This command will create a `nextflow` executable in the current directory. To simplify usage, consider moving this executable to a directory that is available on `$PATH`. One common place for this is a `bin/` directory in your home folder:

``` bash
mkdir -p ~/bin                                      # Creates a bin directory in the home folder
mv nextflow ~/bin                                   # Moves nextflow to that directory
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc   # Make the directory accessible on $PATH
source ~/.bashrc                                    # Reload the shell configuration
```

Verify that Nextflow is accessible by going to your home directory (`cd ~`) and typing `nextflow` on the command line.

### Additional steps for local installation
* Install [Docker](https://docs.docker.com/install/). Ensure that the Docker engine is running by typing `docker images`. If the engine is running, it should return a (possibly empty) list of container images currently downloaded to your system.
* (Optional) If working with TMAs, you will need MATLAB 2018a or later. MATLAB has to be available on `$PATH`, so it can be executed by typing `matlab` on the command line. Additionally, you will need to install Coreograph locally by running `nextflow run labsyspharm/mcmicro-nf/setup.nf`.

## Exemplar data

Two exemplars are currently available for demonstration purposes:

* `exemplar-001` is meant to serve as a minimal reproducible example for running all modules of the pipeline, except the dearray step. The exemplar consists of a small lung adenocarcinoma specimen taken from a larger TMA (tissue microarray), imaged using CyCIF with three cycles. Each cycle consists of six four-channel image tiles, for a total of 12 channels. Because the exemplar is small, illumination profiles were precomputed from the entire TMA and included with the raw images.

* `exemplar-002` is a two-by-two cut-out from a TMA. The four cores are two meningioma tumors, one GI stroma tumor, and one normal colon specimen. The exemplar is meant to test the dearray step, followed by processing of all four cores in parallel.

Both exemplars can be downloaded using the following commands:
``` bash
nextflow run labsyspharm/mcmicro-nf/exemplar.nf --name exemplar-001 --path /local/path/
nextflow run labsyspharm/mcmicro-nf/exemplar.nf --name exemplar-002 --path /local/path/
```
with `/local/path/` pointing to a local directory where the exemplars should be downloaded to.

### O2 notes

When working with exemplars on O2, please download your own copy to `/n/scratch2/$USER/` (where `$USER` is your eCommons ID). A fully processed version is available in `/n/groups/lsp/cycif/exemplars`, but this version is meant to serve as a reference only. The directory permissions are set to read-only, preventing your pipeline run from writing its output there.

### Directory structure

The exemplars demonstrate the directory structure assumed by the pipeline:
```
exemplar-001
├── illumination_profiles
│   ├── exemplar-001-cycle-01-dfp.tif
│   ├── exemplar-001-cycle-01-ffp.tif
│   ├── exemplar-001-cycle-02-dfp.tif
│   ├── exemplar-001-cycle-02-ffp.tif
│   ├── exemplar-001-cycle-03-dfp.tif
│   └── exemplar-001-cycle-03-ffp.tif
├── markers.csv
└── raw_images
    ├── exemplar-001-cycle-01.ome.tiff
    ├── exemplar-001-cycle-02.ome.tiff
    └── exemplar-001-cycle-03.ome.tiff
```

An important set of assumptions to keep in mind:

* The name of the parent directory (e.g., `exemplar-001`) is taken to be the sample name.
* The pipeline can work with either raw images that still need to be stitched, or a pre-stitched image.
  * Raw images must be placed inside `raw_images/` subdirectory.
  * A prestitched image must be placed inside `registration/` subdirectory.
* (Optional) Any precomputed illumination profiles must be placed in `illumination_profiles/`
* The order of markers in `markers.csv` must follow the channel order.

## Pipeline execution

The basic pipeline execution consists of 1) ensuring you have the latest version of the pipeline, followed by 2) using `--in` to point the pipeline at the data.

``` bash
# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro-nf

# Run the pipeline on exemplar data
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-001

# Use --tma to dearray a tissue microarray and process each core in parallel
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-002 --tma
```

Additional flags can be used to control inclusion and exclusion of individual modules in the pipeline.

``` bash
# Use --skip-ashlar if you have a prestitched image in registration/ subfolder
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-001 --skip-ashlar

# Use --illum to run illumination profile computation, if you dont's have one precomputed
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-001 --illum
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

### O2 execution

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

module load java matlab conda2
/home/$USER/bin/nextflow labsyspharm/mcmicro-nf --in /n/scratch2/$USER/exemplar-001 -profile O2 -w /n/scratch2/$USER/work
```
replacing relevant fields (e.g., `user@university.edu`) with your own values.

The pipeline run can then be kicked off with `sbatch submit_mcmicro.sh`.

## Handling intermediate files

The intermediate files in the `work/` directory allow you to restart a pipeline partway, without re-running everything from scratch. For example, consider the following scenario on O2:

``` bash
module load java conda2      # <--- OOPS, forgot matlab

# This run will fail with "matlab: command not found"
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-002 --tma -profile O2

# N E X T F L O W  ~  version 20.01.0
# Launching `labsyspharm/mcmicro-nf` [backstabbing_fermi] - revision: e5ff35c351 [master]
# executor >  slurm (2)
# [-        ] process > illumination   -
# [57/1c3712] process > ashlar         [100%] 1 of 1 ✔
# [cf/7b42eb] process > dearray        [100%] 1 of 1, failed: 1 ✘
# [-        ] process > unmicst        -
# [-        ] process > s3seg          -
# [-        ] process > quantification -

# Address the issue by loading the appropriate module
module load matlab

# Restart the pipeline from the dearray step using `-resume`
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-002 --tma -profile O2 -resume

# N E X T F L O W  ~  version 20.01.0
# Launching `labsyspharm/mcmicro-nf` [condescending_wing] - revision: e5ff35c351 [master]
# executor >  slurm (13)
# [-        ] process > illumination   -
# [57/1c3712] process > ashlar         [100%] 1 of 1, cached: 1 ✔      <- NOTE: cached
# [dd/1928b1] process > dearray        [100%] 1 of 1 ✔
# [1c/82bcd4] process > unmicst        [100%] 4 of 4 ✔
# [f7/02146c] process > s3seg          [100%] 4 of 4 ✔
# [14/25a33c] process > quantification [100%] 4 of 4 ✔
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

## For developers: testing new module versions

The versions of individual modules are pinned for standard pipeline runs. When a new version of a particular module becomes available:

1. Increment the corresponding version in `nextflow.config`.
2. In the same file, change the pipeline "version" to today's date (this is used exclusively for maintaining multiple versions of the pipeline on O2).
3. Run the pipeline on the exemplar(s) to ensure that the new version works as expected.
4. If everything works, submit a pull request.
5. Once the PR is merged, update the O2 install by doing

```
nextflow pull labsyspharm/mcmicro-nf
nextflow run labsyspharm/mcmicro-nf/setup.nf -profile O2
```

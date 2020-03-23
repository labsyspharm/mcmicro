# mcmicro-nf: Multiple-choice microscopy pipeline

## Installation

Install [Nextflow](https://www.nextflow.io/): `curl -s https://get.nextflow.io | bash`

### Additional steps for local installation
* Install [Docker](https://docs.docker.com/install/). Ensure that the Docker engine is running by typing `docker images`. If the engine is running, it should return a (possibly empty) list of container images currently downloaded to your system.
* (Optional) If working with TMAs, you will need MATLAB 2018a or later. Additionally, you will need to install Coreograph locally by running `nextflow run labsyspharm/mcmicro-nf/setup.nf`.

## Exemplar data

Two exemplars are currently available for demonstration purposes. These are

* `exemplar-001` is meant to serve as a minimal reproducbile example for running all modules of the pipeline, except the dearray step. The exemplar consists of six tile images, collected on a Lung Adenocarcinoma specimen in three cycles, for a total of 12 channels. Because the exemplar is small, illumination profiles were precomputed from the larger context and included with the raw images.

* `exemplar-002` is a two-by-two cut-out from a tissue microarray (TMA). The four cores are two meningioma, one GI stroma tumor, and one normal colon specimens. The exemplar is meant to test the dearray step, followed by processing of all four cores in parallel.

Both exemplars can be downloaded using the following commands:
``` bash
nextflow run labsyspharm/mcmicro-nf/exemplar.nf --name exemplar-001 --path /local/path/
nextflow run labsyspharm/mcmicro-nf/exemplar.nf --name exemplar-002 --path /local/path/
```
with `/local/path/` pointing to a local directory where the exemplars should be downloaded to.

### O2 notes

When working with exemplars on O2, please download your own copy to `/n/scratch2/eCommonsID/`. A fully processed version is available in `/n/groups/lsp/cycif/exemplars`, but this version is meant to serve as a reference only. The directory permissions are set to read-only, preventing your pipeline run from writing its output there.

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
* The order of markers in `markers.csv` must followed the channel order.

## Pipeline execution

The basic pipeline execution consists of 1) ensuring you have the latest version of the pipeline, followed by 2) using `--in` to point the pipeline at the data.

``` bash
# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro-nf

# Run the pipeline on exemplar data
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-001

# Use --TMA to dearray a tissue microarray and process each core in parallel
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-002 --TMA
```

Additional flags can be used to control inclusion and exclusion of individual modules in the pipeline.

``` bash
# Use --skip_ashlar if you have a prestitched image in registration/ subfolder
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-001 --skip_ashlar

# Use --illum to run illumination profile computation, if you have none precomputed
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-001 --illum
```

### O2 execution

To run the pipeline on O2, two additional steps are required: 1) you must load the necessary O2 modules, and 2) all pipeline calls need to have the flag `-profile O2`.

``` bash
# Load necessary modules (matlab is optional, if not working with TMA)
module load java matlab conda2

# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro-nf

# All previous commands require an additional `-profile O2` flag
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-001 -profile O2
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-002 --TMA -profile O2
```

## Handling intermediate files

By default Nextflow writes intermediate files to a `work/` directory inside whatever location you initiate a pipeline run from. The intermediate files allow you to restart a pipeline partway, without re-running everything from scratch. For example, consider the following scenario on O2:

``` bash
module load java conda2      # <--- OOPS, forgot matlab

# This run will fail with "matlab: command not found"
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-002 --TMA -profile O2

# Address the issue by loading the appropriate module
module load matlab

# Restart the pipeline from the dearray step using `-resume`
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-002 --TMA -profile O2 -resume
```

As you run the pipeline on your datasets, the size of the `work/` directory can grow substantially. Two Nextflow features can greatly assist with managing its content. First, you can control where the `work/` directory gets create. On O2, it is recommended to use `/n/scratch2`:

``` bash
nextflow run labsyspharm/mcmicro-nf --in /path/to/exemplar-001 -profile O2 -w /n/scratch2/eCommonsID/work/
```

Second, use [nextflow clean](https://github.com/nextflow-io/nextflow/blob/cli-docs/docs/cli.rst#clean) to selectively remove portions of the work directory. Use `-n` flag to list which files will be removed, inspect the list to ensure that you don't lose anything important, and repeat the command with `-f` to actually remove the files:

``` bash
# Remove work files associated with most-recent run
nextflow clean -n last           # Show what will be removed
nextflow clean -f last           # Proceed with the removal

# Remove all work files except those associated with the most-recent run
nextflow clean -n -but last
nextflow clean -f -but last
```

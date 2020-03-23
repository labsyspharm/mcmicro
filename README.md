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

## Local execution

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

## O2 execution

``` bash
# Load necessary modules
module load java matlab conda2

# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro-nf

# All of the above run commands require an additional -profile parameter
nextflow run ... -profile O2
```

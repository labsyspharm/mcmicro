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

## Local execution

``` bash
# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro-nf

# Install individual modules
nextflow run labsyspharm/mcmicro-nf/setup.nf

# Download exemplar data
nextflow run labsyspharm/mcmicro-nf/exemplar.nf --name exemplar-002 --path /local/path

# Run the pipeline on data
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-001

# Use --skip_ashlar if you have a prestitched image in registration/ subfolder
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-001 --skip_ashlar

# Use --TMA to dearray a tissue microarray and process each core in parallel
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar-002 --TMA
```

## O2 execution

``` bash
# Load necessary modules
module load java matlab conda2

# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro-nf

# Both exemplars are in /n/groups/lsp/cycif/exemplars
# Individual tools are already pre-installed to /n/groups/lsp/mcmicro

# All of the above run commands require an additional -profile parameter
nextflow run ... -profile O2
```

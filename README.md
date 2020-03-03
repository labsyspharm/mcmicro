## mcmicro-nf: Nextflow prototype for mcmicro

Install [Nextflow](https://www.nextflow.io/): `curl -s https://get.nextflow.io | bash`

### Local execution

**Prerequisites**: Java (v8 or later), MATLAB, Docker

``` bash
# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro-nf

# Install individual modules
nextflow run labsyspharm/mcmicro-nf/setup.nf

# Download exemplar data
nextflow run labsyspharm/mcmicro-nf/exemplar.nf --name exemplar-002 --path /local/path

# Run the pipeline on data
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar001

# Use --skip_ashlar if you have a prestitched image in registration/ subfolder
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar001 --skip_ashlar

# Use --TMA to dearray a tissue microarray and process each core in parallel
nextflow run labsyspharm/mcmicro-nf --in path/to/exemplar002 --TMA
```

### O2 execution

``` bash
# Load necessary modules
module load gcc ashlar matlab java conda2

# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro-nf

# Both exemplars are in /n/groups/lsp/cycif/exemplars
# Individual tools are already pre-installed to /n/groups/lsp/mcmicro

# All of the above run commands require an additional -profile parameter
nextflow run ... -profile O2
```

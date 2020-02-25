## mcmicro-nf: Nextflow prototype for mcmicro

Install [Nextflow](https://www.nextflow.io/): `curl -s https://get.nextflow.io | bash`

### Local execution

**Prerequisites**: Java (v8 or later), MATLAB, Docker

``` bash
# Install individual modules
nextflow run ArtemSokolov/mcmicro-nf/setup.nf

# Download exemplar data
nextflow run ArtemSokolov/mcmicro-nf/exemplar.nf --name exemplar-002 --path /local/path

# Get the latest version of the pipeline
nextflow pull ArtemSokolov/mcmicro-nf

# Run the pipeline on data
nextflow run ArtemSokolov/mcmicro-nf --in path/to/exemplar002
```

### O2 execution

``` bash
# Load necessary modules
module load gcc ashlar matlab java conda2

# Individual tools are already pre-installed to /n/groups/lsp/mcmicro
# Both exemplars are in /n/groups/lsp/cycif/exemplars

# Get the latest version of the pipeline
nextflow pull ArtemSokolov/mcmicro-nf

# Run the pipeline pointing to the existing tools location with the O2 profile
nextflow run ArtemSokolov/mcmicro-nf --in path/to/exemplar-002 \
  --tools /n/groups/lsp/mcmicro/ -profile O2
```

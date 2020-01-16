## mcmicro-nf: Nextflow prototype for mcmicro

**Prerequisites**: Java (v8 or later), MATLAB, Docker (if running locally)

### Setup

1. Install [Nextflow](https://www.nextflow.io/): `curl -s https://get.nextflow.io | bash`
2. Pull individual modules: `nextflow run ArtemSokolov/mcmicro-nf/setup.nf`
3. Get model files from Clarence

### Running the pipeline

Local: `nextflow run ArtemSokolov/mcmicro-nf --in path/to/exemplar002`

On O2:

- `module load {gcc, ashlar, matlab}`
- `nextflow run ArtemSokolov/mcmicro-nf -profile O2 --in path/to/exemplar002`

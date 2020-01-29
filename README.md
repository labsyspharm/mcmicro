## mcmicro-nf: Nextflow prototype for mcmicro

Install [Nextflow](https://www.nextflow.io/): `curl -s https://get.nextflow.io | bash`

### Local execution

**Prerequisites**: Java (v8 or later), MATLAB, Docker

Pull individual tools: `nextflow run ArtemSokolov/mcmicro-nf/setup.nf`

Run the pipeline: `nextflow run ArtemSokolov/mcmicro-nf --in path/to/exemplar002`

### O2 execution

Individual tools are already pre-installed to `/n/groups/lsp/mcmicro`.

Load necessary modules: `module load gcc ashlar matlab java conda2`

Run the pipeline pointing to the existing tools location with the O2 profile:
```
nextflow run ArtemSokolov/mcmicro-nf --in path/to/exemplar-002 --tools /n/groups/lsp/mcmicro/ -profile O2
```

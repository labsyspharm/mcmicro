## mcmicro-nf: Nextflow prototype for mcmicro

**Prerequisites**: Java (v8 or later), MATLAB, Docker (if running locally)

### Setup

1. Install [Nextflow](https://www.nextflow.io/): `curl -s https://get.nextflow.io | bash`
2. Pull individual modules: `nextflow run ArtemSokolov/mcmicro-nf/setup.nf`

Note that by default the individual modules will be installed to `$HOME/mcmicro` directory. An alternative destination can be specified via the `--tools` parameter:

```
nextflow run ArtemSokolov/mcmicro-nf/setup.nf --tools /path/to/tools
```

On O2, these have been pre-installed to `/n/groups/lsp/mcmicro`. When running the pipeline, the location of the tools can also be specified via the `--tools` argument. (See the O2 example below.)

### Running the pipeline

Local: `nextflow run ArtemSokolov/mcmicro-nf --in path/to/exemplar002`

On O2:

- `module load gcc, ashlar, matlab`
- `nextflow run ArtemSokolov/mcmicro-nf --in test/exemplar-002/ --tools /n/groups/lsp/mcmicro/ -profile O2`

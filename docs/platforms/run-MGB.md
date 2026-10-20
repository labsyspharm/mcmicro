---
layout: default
title: MGB ERIS Nucleus
nav_order: 3
parent: Platforms
---

# Running MCMICRO on MGB ERIS Nucleus

The `MGB` profile configures MCMICRO for the Mass General Brigham ERIS Nucleus Slurm cluster. It sets the Slurm executor, Singularity/Apptainer settings, Nucleus GPU partition, GPU resource request, output publishing mode, and adaptive resource requests.

This profile was prepared by the [Nirmal Lab](https://nirmallab.com/).

Submit MCMICRO through Slurm instead of running a full pipeline directly on a login node.

> **First-time run:** The first run may download and build Singularity images. If container builds fail because of memory, temporarily increase the launcher request from `--mem=4G` to `--mem=32G`; after the required containers are cached, `4G` is usually sufficient.

Create a submission script such as `mcmicro_template.sh`:

```
#!/bin/bash
#SBATCH -p normal
#SBATCH -J mcmicro
#SBATCH -o mcmicro-%j.log
#SBATCH -t 12:00:00
#SBATCH --mem=4G
#SBATCH -c 2
#SBATCH --mail-type=END

in="${1:-$(pwd)}"

if [ ! -e "$in/markers.csv" ]; then
  echo "ERROR: $0: Input directory '$in' does not look like an MCMICRO project directory; markers.csv was not found." >&2
  exit 1
fi

module purge
module load Nextflow/25.10.0
module load singularity/latest

export NXF_JVM_ARGS='-Xms256m -Xmx2g -XX:ActiveProcessorCount=2'
export NXF_WORK="$HOME/scratch/mcmicro-work"
export APPTAINER_TMPDIR=$HOME/scratch/apptainer-tmp
export APPTAINER_CACHEDIR=$HOME/scratch/apptainer-cache
export SINGULARITY_TMPDIR=$HOME/scratch/apptainer-tmp
export SINGULARITY_CACHEDIR=$HOME/scratch/apptainer-cache

mkdir -p "$NXF_WORK" "$APPTAINER_TMPDIR" "$APPTAINER_CACHEDIR" "$HOME/.mcmicro/singularity" "$in/pipeline_info"

echo "Launching MCMICRO in $in"
cd "$in"

nextflow run labsyspharm/mcmicro \
  -profile MGB \
  --in . \
  -w "$NXF_WORK" \
  -resume
```

Submit the job from an MCMICRO project directory:

```
sbatch mcmicro_template.sh .
```

The `MGB` profile uses `$HOME/scratch` for working files and `$HOME/.mcmicro/singularity` for cached container images. The Apptainer/Singularity temporary directories are also placed under `$HOME/scratch` because `/tmp` may not be suitable for container builds on Nucleus.

By default, the profile uses:

```
GPU partition: gpu-l40s
GPU GRES:      gpu:nvidia_l40s:1
```

The profile also includes retry-based resource scaling and a bundled TIFF/OME-TIFF size estimator for image-size-aware memory requests. Users normally do not need to call the estimator or pull containers manually.

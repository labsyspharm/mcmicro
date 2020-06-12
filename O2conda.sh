#!/usr/bin/env bash

# Usage: ./O2conda.sh /path/to/conda/destination

conda env create -f conda/ashlar.yml         -p "$1/ashlar"
conda env create -f conda/unmicst.yml        -p "$1/unmicst-2020-06-06"
conda env create -f conda/s3seg.yml          -p "$1/s3seg"
conda env create -f conda/quantification.yml -p "$1/quantification"
conda env create -f conda/mc_ilastik.yml     -p "$1/mc_ilastik"
conda env create -f conda/nstates.yml        -p "$1/naivestates"

## Additional dependencies
conda activate "$1/naivestates"
R -s -e "devtools::install_github('labsyspharm/naivestates')"
conda deactivate

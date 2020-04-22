#!/usr/bin/env bash

O2BASE="/n/groups/lsp/mcmicro"

conda env create -f conda/ashlar.yml -p $O2BASE/conda/ashlar
conda env create -f conda/unmicst.yml -p $O2BASE/conda/unmicst
conda env create -f conda/s3seg.yml -p $O2BASE/conda/s3seg
conda env create -f conda/quantification.yml -p $O2BASE/conda/quantification
conda env create -f conda/mc_ilastik.yml -p $O2BASE/conda/mc_ilastik

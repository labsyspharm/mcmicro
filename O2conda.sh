#!/usr/bin/env bash

O2BASE="/n/groups/lsp/mcmicro"

echo conda env create -f conda/ashlar.yml -p $O2BASE/conda/ashlar
echo conda env create -f conda/unmicst.yml -p $O2BASE/conda/unmicst
echo conda env create -f conda/s3seg.yml -p $O2BASE/conda/s3seg
echo conda env create -f conda/quantification.yml -p $O2BASE/conda/quantification

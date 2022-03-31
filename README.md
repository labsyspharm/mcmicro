[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) ![Build Status](https://github.com/labsyspharm/mcmicro/actions/workflows/ci.yml/badge.svg)

# MCMICRO: Multiple-choice microscopy pipeline

MCMICRO is an end-to-end processing pipeline for multiplexed whole slide imaging and tissue microarrays developed at the [HMS Laboratory of Systems Pharmacology](https://hits.harvard.edu/the-program/laboratory-of-systems-pharmacology/about/). It comprises stitching and registration, segmentation, and single-cell feature extraction. Each step of the pipeline is containerized to enable portable deployment across an array of compute environments.

The pipeline is described in [Nature Methods](https://www.nature.com/articles/s41592-021-01308-y). Please see [mcmicro.org](https://mcmicro.org/) for documentation, tutorials, benchmark datasets and more.

## Quick start

1. [Install](http://mcmicro.org/instructions/nextflow/installation.html) nextflow and Docker. Verify installation with `nextflow run hello` and `docker run hello-world`
1. [Download](http://mcmicro.org/datasets/) exemplar data: `nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-001 --path .`
1. [Run](https://mcmicro.org/instructions/nextflow/) mcmicro on the exemplar: `nextflow run labsyspharm/mcmicro --in exemplar-001`

## Funding

This work is supported by the following:

* NCI grants U54-CA22508U2C-CA233262 and U2C-CA233280
* *NIH grant 1U54CA225088: Systems Pharmacology of Therapeutic and Adverse Responses to Immune Checkpoint and Small Molecule Drugs* 
* Ludwig Center at Harvard Medical School and the Ludwig Cancer Research Foundation
* Denis Schapiro was supported by the University of Zurich BioEntrepreneur-Fellowship (BIOEF-17-001) and a Swiss National Science Foundation Early Postdoc Mobility fellowship (P2ZHP3_181475). He is currently a [Damon Runyon Quantitative Biology Fellow](https://www.damonrunyon.org/news/entries/5551/Damon%20Runyon%20Cancer%20Research%20Foundation%20awards%20new%20Quantitative%20Biology%20Fellowships)

[Contributors](https://mcmicro.org/community/)

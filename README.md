[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) ![Build Status](https://github.com/labsyspharm/mcmicro/actions/workflows/ci.yml/badge.svg)

# mcmicro: Multiple-choice microscopy pipeline

mcmicro is an end-to-end processing pipeline for multiplexed whole slide imaging and tissue microarrays. It comprises stitching and registration, segmentation, and single-cell feature extraction. Each step of the pipeline is containerized to enable portable deployment across an array of compute environments.

The pipeline is described in a [bioRxiv preprint](https://www.biorxiv.org/content/10.1101/2021.03.15.435473v1) and accompanied by the following resources:

| Resource | URL |
| --- | --- |
| Code repository | **YOU ARE HERE** |
| Instruction manual | [http://mcmicro.org/](http://mcmicro.org/) |
| EMIT dataset | [https://www.synapse.org/EMIT](https://www.synapse.org/EMIT) |
| Tonsil images | [https://www.synapse.org/MCMICRO_images](https://www.synapse.org/MCMICRO_images) |

## Quick start

1. [Install](http://mcmicro.org/installation.html) nextflow and Docker. Check with `nextflow run hello` and `docker images` to make sure both are functional.
3. [Download](http://mcmicro.org/installation.html#exemplar-data) exemplar data. E.g., `nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-001 --path .` to download to current directory.
4. [Run](http://mcmicro.org/running-mcmicro.html) mcmicro on the exemplars. E.g., `nextflow pull labsyspharm/mcmicro` followed by `nextflow run labsyspharm/mcmicro --in exemplar-001` to execute in current directory. 

## Funding

This work is supported by the following:

* *NIH grant 1U54CA225088: Systems Pharmacology of Therapeutic and Adverse Responses to Immune Checkpoint and Small Molecule Drugs* 
* Ludwig Center at Harvard Medical School and the Ludwig Cancer Research Foundation
* Denis Schapiro was supported by the University of Zurich BioEntrepreneur-Fellowship (BIOEF-17-001) and a Swiss National Science Foundation Early Postdoc Mobility fellowship (P2ZHP3_181475). He is currently a [Damon Runyon Quantitative Biology Fellow](https://www.damonrunyon.org/news/entries/5551/Damon%20Runyon%20Cancer%20Research%20Foundation%20awards%20new%20Quantitative%20Biology%20Fellowships)

[Contributors](http://mcmicro.org/contributors.html)

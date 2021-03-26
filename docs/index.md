---
layout: default
title: Overview
nav_order: 1
description: ""
permalink: /
last_modified_date: 2020-09-01
---

# mcmicro

Multiple-choice microscopy pipeline
{: .fs-6 .fw-300 }

mcmicro is the end-to-end processing pipeline for multiplexed whole tissue imaging and tissue microarrays. It comprises stitching and registration, segmentation, and single-cell feature extraction. Each step of the pipeline is containerized to enable portable deployment across an array of compute environments, including local machines, job-scheduling clusters and cloud environments like AWS. The pipeline execution is implemented in [Nextflow](https://www.nextflow.io/), a workflow language that facilitates caching of partial results, dynamic restarts, extensive logging and resource usage reports.

Development of mcmicro is led by [Artem Sokolov](https://github.com/ArtemSokolov) and [Denis Schapiro](https://github.com/DenisSch) at [Laboratory of Systems Pharmacology](https://hits.harvard.edu/the-program/laboratory-of-systems-pharmacology/about/), Harvard Medical School. The pipeline is described in a [bioRxiv preprint](https://www.biorxiv.org/content/10.1101/2021.03.15.435473v1) and accompanied by the following resources:

| Resource | URL |
| --- | --- |
| Code repository | [https://github.com/labsyspharm/mcmicro](https://github.com/labsyspharm/mcmicro) |
| Instruction manual | **YOU ARE HERE** |
| EMIT dataset | [https://www.synapse.org/EMIT](https://www.synapse.org/EMIT) |
| Tonsil images | [https://www.synapse.org/MCMICRO_images](https://www.synapse.org/MCMICRO_images) |

## Quick start

1. [Install](installation.html) nextflow and Docker.
2. [Download](installation.html#exemplar-data) exemplar data.
3. [Run](running-mcmicro.html) mcmicro on the exemplars.

It takes approximately 20 minutes and 1 hour to process exemplar-001 and exemplar-002 from start to finish on an average workstation.

## Funding

This work is supported by:

* NIH grant 1U54CA225088: Systems Pharmacology of Therapeutic and Adverse Responses to Immune Checkpoint and Small Molecule Drugs
* Ludwig Center at Harvard Medical School and the Ludwig Cancer Research Foundation
* Denis Schapiro was supported by the University of Zurich BioEntrepreneur-Fellowship (BIOEF-17-001) and a Swiss National Science Foundation Early Postdoc Mobility fellowship (P2ZHP3_181475). He is currently a [Damon Runyon Quantitative Biology Fellow](https://www.damonrunyon.org/news/entries/5551/Damon%20Runyon%20Cancer%20Research%20Foundation%20awards%20new%20Quantitative%20Biology%20Fellowships)

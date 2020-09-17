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

Development of mcmicro is led be [Artem Sokolov](https://github.com/ArtemSokolov) and [Denis Schapiro](https://github.com/DenisSch) at [Laboratory of Systems Pharmacology](https://hits.harvard.edu/the-program/laboratory-of-systems-pharmacology/about/), Harvard Medical School.

## Funding

This work is supported by:

* NIH grant 1U54CA225088: Systems Pharmacology of Therapeutic and Adverse Responses to Immune Checkpoint and Small Molecule Drugs
* NCI grant 1U2CCA233262: Pre-cancer atlases of cutaneous and hematologic origin (PATCH Center)
* NCI grant 1U2CCA233280:  Omic and Multidimensional Spatial Atlas of Metastatic Breast and Prostate Cancers
* Ludwig Center at Harvard Medical School and the Ludwig Cancer Research Foundation

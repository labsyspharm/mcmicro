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

Development of mcmicro is led by [Artem Sokolov](https://github.com/ArtemSokolov) and [Denis Schapiro](https://github.com/DenisSch) at [Laboratory of Systems Pharmacology](https://hits.harvard.edu/the-program/laboratory-of-systems-pharmacology/about/), Harvard Medical School.

## Funding

This work is supported by:

* NIH grant 1U54CA225088: Systems Pharmacology of Therapeutic and Adverse Responses to Immune Checkpoint and Small Molecule Drugs
* Ludwig Center at Harvard Medical School and the Ludwig Cancer Research Foundation
* Denis Schapiro was supported by the University of Zurich BioEntrepreneur-Fellowship (BIOEF-17-001) and a Swiss National Science Foundation Early Postdoc Mobility fellowship (P2ZHP3_181475). He is currently a [Damon Runyon Quantitative Biology Fellow](https://www.damonrunyon.org/news/entries/5551/Damon%20Runyon%20Cancer%20Research%20Foundation%20awards%20new%20Quantitative%20Biology%20Fellowships)

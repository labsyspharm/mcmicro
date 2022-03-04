---
layout: default
title: Home
nav_order: 1
has_children: true
description: ""
hero_heading: "Multiple-choice microscopy pipeline"
hero_body: "An end-to-end processing pipeline that transforms multi-channel whole-slide images into single-cell data. This website is a consolidated source of information for when, why, and how to use MCMICRO."
hero_ctas:
  - label: "QUICK START"
    link: "instructions/"
  - label: "OVERVIEW"
    link: "overview/"
# last_modified_date: 2021-03-28
---
# Features
{% include youtube.html id="DY_F-eG9nm4" autoplay=true mute=true controls=false loop=true related=false %}

<div class="basic-grid with-dividers mb-6">

<div markdown="1">
## Images to Insights
Multiplexed tissue imaging provides deep insight into the composition, organization, and phenotype of normal and diseased tissues. MCMICRO converts these multiplexed images into single-cell data using state of the art algorithms. Single-cell resolution images provide spatial context of the cellular microenvironment and can be used alongside additional profiling methods like scRNA-Seq, to make robust biological conclusions.

</div>
<div markdown="1">
## Open source pipeline
MCMICRO is an open source, community supported software that uses Docker and workflow software to create pipelines for analyzing microscopy-based images of tissues. MCMICRO processes data sequentially using algorithms (modules) developed in different research groups.
</div>
<div markdown="1">
## Flexible tools for a new field
High-plex tissue imaging is a new interdisciplinary field involving a wide range of imaging technologies, and the best image analysis approach is not always clear. MCMICRO implements a “multiple choice” approach that allows users to select different modules for customized image processing.
</div>
<div markdown="1">
## Flexible Implementation
MCMICRO is implemented in the workflow languages [Nextflow](https://www.nextflow.io/) and [Galaxy](https://galaxyproject.org/). Both implementations can be run locally, on a compute cluster, or on the cloud.
</div>
<div markdown="1">
## A growing community 
Modules are being added to MCMICRO incrementally by a diverse developer community seeded by the NCI [Human Tissue Atlas Network](https://humantumoratlas.org/). See what modules we are currently [using](./modules/), view our growing [community](./community/), or [get help](./community/help.html) from the community.
</div>
<div markdown="1">
## Test Data
MCMICRO comes with a growing library of imaging data ([EMIT data](./datasets.html#exemplar-microscopy-images-of-tissues-emit)) for testing your test run or for developing new algorithms. There is a lot of unexplored biology in the test data as well!
</div>
<div markdown="1">
## Technology Agnostic
MCMICRO works with any image that meets the [BioFormats standard](https://www.openmicroscopy.org/bio-formats/), most commonly OME-TIFF. These images can be acquired using a wide range of technologies- CODEX, CyCIF, mIHC, mxIF, IMC or MIBI.
</div>
<div markdown="1">
## Evolving Best Practices
The MCMICRO team is collaborating with the NCI to run hackathons and challenges to identify the best modules and pipelines for specific types of data.
</div>

</div><!-- end grid -->


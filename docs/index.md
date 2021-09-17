---
layout: default
title: Home
nav_order: 1
description: ""
hero_heading: "Multiple-choice microscopy pipeline"
hero_body: "An end-to-end processing pipeline to transform large, multi-channel whole slide images into single-cell data. This site is a consolidated source of information on [MCMICRO](https://github.com/labsyspharm/mcmicro), documentation, roadmap, community and test data."
hero_ctas:
  - label: "QUICK START"
    link: "documentation/"
  - label: "TUTORIALS"
    link: "tutorials/index.html"
# last_modified_date: 2021-03-28
---

# Features

{% assign cardList = "" | split: "" %}

{% capture card %}
## Images to Insights
Highly multiplexed tissue imaging provides deep insight into the composition, organization and states of normal and diseased tissues. When converted into single cell data, tissue images are a natural complement to scRNA-Seq and similar profiling methods with the added advantage of spatial context. MCMICRO converts raw images into single cell data using state of the art algorithms for illumination correction, stitching, quality control, segmentation, and cell type calling.
{% endcapture %}
{% assign cardList = cardList | push: card %}

{% capture card %}
## MCMICRO Pipeline
MCMICRO is open source, community supported software that uses Docker and workflow software to create pipelines for analyzing microscopy-based images of tissues, with an emphasis on highly multiplexed methods and single-cell data. Data is processed sequentially using algorithms (modules) developed in different research groups.
{% endcapture %}
{% assign cardList = cardList | push: card %}

{% capture card %}
## Flexible tools for a new field
High-plex tissue imaging is a new field involving a wide range of imaging technologies and the best image analysis approach is not always clear. MCMICRO therefore implements a “multiple choice” approach in which users can select among different modules for critical processing steps.
{% endcapture %}
{% assign cardList = cardList | push: card %}

{% capture card %}
## Flexible Implementation
MCMICRO is implemented in the workflow languages [Nextflow](https://www.nextflow.io/) and [Galaxy](https://galaxyproject.org/). Both implementations can be run locally, on a compute cluster, or on the cloud.
{% endcapture %}
{% assign cardList = cardList | push: card %}

{% capture card %}
## Adding Modules
Modules are being added to MCMICRO incrementally by a diverse developer community seeded by the NCI [Human Tissue Atlas Network](https://humantumoratlas.org/). See what modules we are currently [using](roadmap/), check out [instructions](roadmap/adding.html) to add your own modules, or [get help](help.html) from the community.
{% endcapture %}
{% assign cardList = cardList | push: card %}

{% capture card %}
## Test Data
MCMICRO comes with a growing library of imaging data ([EMIT data](datasets.html#exemplar-microscopy-images-of-tissues-emit)) for testing your test run or for developing new algorithms. There is a lot of unexplored biology in the test data as well!
{% endcapture %}
{% assign cardList = cardList | push: card %}


{% capture card %}
## Technology Agnostic
MCMICRO works with any image that meets the [BioFormats standard](https://www.openmicroscopy.org/bio-formats/), most commonly OME-TIFF. These images can be acquired using a wide range of technologies- CODEX, CyCIF, mIHC, mxIF, IMC or MIBI.
{% endcapture %}
{% assign cardList = cardList | push: card %}


{% capture card %}
## Best Practices
Although it is nice to have many modules to try out, often you just want something that works. The MCMICRO team is collaborating with the NCI to run hackathons and challenges to identify the best modules and pipelines for specific types of data.
{% endcapture %}
{% assign cardList = cardList | push: card %}

{% include basic-cards.html cards=cardList %}


{% include youtube.html id="DY_F-eG9nm4" autoplay=true mute=true controls=false loop=true related=false %}

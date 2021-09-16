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

<!-- UIkit CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/uikit@3.6.22/dist/css/uikit.min.css" />


<h2 class="uk-heading-line uk-text-center uk-margin-medium-bottom uk-margin-large-top"><span>Features</span></h2>

<div class="uk-child-width-1-2@m uk-grid-small uk-grid-match uk-flex-center" uk-grid>
    <div>
        <div class="uk-card uk-card-default uk-card-body">
            <h2 class="uk-card-title">Images to Insights 💡</h2>
            <p>Highly multiplexed tissue imaging provides deep insight into the composition, organization and states of normal and diseased tissues. When converted into single cell data, tissue images are a natural complement to scRNA-Seq and similar profiling methods with the added advantage of spatial context. MCMICRO converts raw images into single cell data using state of the art algorithms for illumination correction, stitching, quality control, segmentation, and cell type calling.</p>
        </div>
    </div>
    <div>
        <div class="uk-card uk-card-default uk-card-body">
            <h2 class="uk-card-title">MCMICRO Pipeline 🎛️</h2>
            <p>MCMICRO is open source, community supported software that uses Docker and workflow software to create pipelines for analyzing microscopy-based images of tissues, with an emphasis on highly multiplexed methods and single-cell data. Data is processed sequentially using algorithms (modules) developed in different research groups.</p>
        </div>
    </div>
    <div>
        <div class="uk-card uk-card-default uk-card-body">
            <h2 class="uk-card-title">Flexible tools for a new field 🤝</h2>
            <p>High-plex tissue imaging is a new field involving a wide range of imaging technologies and the best image analysis approach is not always clear. MCMICRO therefore implements a “multiple choice” approach in which users can select among different modules for critical processing steps</p>
        </div>
    </div>
    <div>
        <div class="uk-card uk-card-default uk-card-body">
            <h2 class="uk-card-title">Flexible Implementation 🔛</h2>
            <p>MCMICRO is implemented in the workflow languages <a href="https://www.nextflow.io/">Nextflow</a> and <a href="https://galaxyproject.org/">Galaxy</a>. Both implementations can be run locally, on a compute cluster, or on the cloud</p>
        </div>
    </div>
    <div>
        <div class="uk-card uk-card-default uk-card-body">
            <h2 class="uk-card-title">Adding Modules ⚙️</h2>
            <p>Modules are being added to MCMICRO incrementally by a diverse developer
                community seeded by the NCI <a href="https://humantumoratlas.org/">Human Tissue Atlas Network</a>. See what modules we are
                currently <a href="roadmap/">using</a>, check out <a href="roadmap/adding.html">instructions</a> to add your own modules, or <a href="help.html">get help</a> from
the community.</p>
        </div>
    </div>
    <div>
        <div class="uk-card uk-card-default uk-card-body">
            <h2 class="uk-card-title">Test Data 📥</h2>
            <p>MCMICRO comes with a growing library of imaging data (<a href="datasets.html#exemplar-microscopy-images-of-tissues-emit">EMIT data</a>) for testing your test run or for developing new algorithms. There is a lot of unexplored biology in the test data as well!</p>
        </div>
    </div>
    <div>
        <div class="uk-card uk-card-default uk-card-body">
            <h2 class="uk-card-title">Technology Agnostic 🎩</h2>
            <p>MCMICRO works with any image that meets the <a href="https://www.openmicroscopy.org/bio-formats/">BioFormats standard</a>, most commonly OME-TIFF. These images can be acquired using a wide range of technologies- CODEX, CyCIF, mIHC, mxIF, IMC or MIBI.</p>
        </div>
    </div>
    <div>
        <div class="uk-card uk-card-default uk-card-body">
            <h2>Best Practices 🤓</h2>
            <p>Although it is nice to have many modules to try out, often you just want something that works. The MCMICRO team is collaborating with the NCI to run hackathons and challenges to identify the best modules and pipelines for specific types of data.</p>
        </div>
    </div>
</div>

<div class="uk-cover-container uk-margin-medium-bottom">
    <canvas width="1920" height="1080"></canvas>
    <iframe src="
    https://www.youtube.com/embed/DY_F-eG9nm4?fs=0&amp;iv_load_polocy=3&amp;modestbranding=1&amp;playsinline=1&amp;autoplay=1&amp;controls=0&amp;rel=0&amp;playlist=DY_F-eG9nm4&amp;loop=1" width="1920" height="1080" frameborder="0" uk-cover></iframe>
</div>
               

<!-- UIkit JS -->
<script src="https://cdn.jsdelivr.net/npm/uikit@3.6.22/dist/js/uikit.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/uikit@3.6.22/dist/js/uikit-icons.min.js"></script>

---
layout: default
title: Home
nav_order: 1
description: ""
last_modified_date: 2021-03-28
---

<!-- UIkit CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/uikit@3.6.22/dist/css/uikit.min.css" />


<div class="uk-grid-collapse uk-flex uk-flex-middle uk-margin-medium-bottom" uk-grid>
    <div class="uk-width-2-5@m">
        <div>
            <h1>MCMICRO</h1>
            <p>An end-to-end processing pipeline to transform large, multi-channel whole slide images into single-cell data.</p>
        </div>
    </div>
    <div class="uk-width-expand@m">
        <div>
            <img src="{{ site.baseurl }}/assets/images/bg-2.png" alt="">
        </div>
    </div>
</div>


<div class="uk-section" style="background-color: #f5f6fa">
    <div class="uk-container">
        <h2>💡 Images to Insights 💡</h2>
        <p>
            Multiplexed tissue imaging offers insights to disease diagnosis and therapy strategies. A suite of well-designed software modules for processing whole-slide images is cruicial for facilitating the utilities of multiplexed tissue images in a routine setting. 
        </p>
    </div>
</div>

<div class="uk-section">
    <div class="uk-container">
        <h2>🎛️ MCMICRO Pipeline 🎛️</h2>
        <p>MCMICRO is an open source, community supported software that uses Docker and workflow software to create pipelines for analyzing microscopy-based images of tissues, with an emphasis on highly multiplexed methods and single-cell data. Data is processed sequentially using algorithms (modules) developed in different research groups.</p>
    </div>
</div>

<div class="uk-section" style="background-color: #f5f6fa">
    <div class="uk-container">
        <h2>🤝 Tool for the growing community 🤝</h2>
        <p>High-plex tissue imaging is a new field and the best approach is not always clear - MCMICRO therefore implements a “multiple choice” approach in which users can select among different modules for key processing steps</p>
    </div>
</div>

<h2 class="uk-heading-line uk-text-center uk-margin-medium-bottom uk-margin-large-top"><span>Features</span></h2>

<div class="uk-child-width-1-2@m uk-grid-small uk-grid-match" uk-grid>
    <div>
        <div class="uk-card uk-card-default uk-card-body">
            <h2 class="uk-card-title">Flexible 🔛</h2>
            <p>MCMICRO is implemented in the workflow languages <a href="">Nextflow</a> and <a href="">Galaxy</a>. Both implementations can be run locally, on a compute cluster, or on the cloud</p>
        </div>
    </div>
    <div>
        <div class="uk-card uk-card-default uk-card-body">
            <h2 class="uk-card-title">Modular ⚙️</h2>
            <p>Modules are being added to MCMICRO all the time by the developer community. <a href="">Check out the instructions</a> or <a href="">get help from the community</a>.</p>
        </div>
    </div>
    <div>
        <div class="uk-card uk-card-default uk-card-body">
            <h2 class="uk-card-title">Goodies 🪅</h2>
            <p>MCMICRO comes with a growing library of imaging data (<a href="">EMIT data</a>) for testing your test run or for developing new algorithms. There is a lot of unexplored biology in the test data as well!</p>
        </div>
    </div>
    <div>
        <div class="uk-card uk-card-default uk-card-body">
            <h2 class="uk-card-title">Agnostic 🪄</h2>
            <p>MCMICRO works with images from a spectrum of technologys - CODEX, CyCIF, mIHC, mxIF, IMC, MIBI</p>
        </div>
    </div>
</div>


<!-- UIkit JS -->
<script src="https://cdn.jsdelivr.net/npm/uikit@3.6.22/dist/js/uikit.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/uikit@3.6.22/dist/js/uikit-icons.min.js"></script>

---
layout: default
title: Datasets
nav_order: 5
---

# Exemplar data

<div class="basic-grid mt-6">

{% assign imageUrl = site.baseurl | append: "/images/mcmicro-exemplar-001.jpg" %}
{% include image-card.html 
    image=imageUrl
    label="exemplar-001"
%}

{% assign imageUrl = site.baseurl | append: "/images/mcmicro-exemplar-002.jpg" %}
{% include image-card.html 
    image=imageUrl
    label="exemplar-002"
%}

</div><!-- end grid -->


Two exemplars are currently available for demonstration purposes:

* `exemplar-001` is meant to serve as a minimal reproducible example for running all modules of the pipeline, except the dearray step. The exemplar consists of a small lung adenocarcinoma specimen taken from a larger TMA (tissue microarray), imaged using CyCIF with three cycles. Each cycle consists of six four-channel image tiles, for a total of 12 channels. Because this exemplar is too small for automated illumination correction, illumination profiles were precomputed from the entire TMA and included with the raw images.

* `exemplar-002` is a two-by-two cut-out from a TMA. The four cores are two meningioma tumors, one GI stroma tumor, and one normal colon specimen. The exemplar is meant to test the dearray step, followed by processing of all four cores in parallel. This dataset has ten cycles with 40 total channels and also includes precomputed illumination profiles.

Note that the representative images above only depict a subset of the full list of image channels present in each dataset.

After [installing Nextflow]({{ site.baseurl }}/documentation/installation.html), both exemplars can be downloaded using the following commands:
``` bash
nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-001 --path /local/path/
nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-002 --path /local/path/
```
with `/local/path/` pointing to a local directory where the exemplars should be downloaded to.

# Exemplar Microscopy Images of Tissues (EMIT)

MCMICRO is accompanied by EMIT (Exemplar Microscopy Images of Tissues), which is a reference dataset containing images of different types for development and benchmarking of computational methods for image processing. The data are also expected to be useful for biological studies. However, the data are complex and annotation for the purposes of biological interpretation is an ongoing activity. Users of these data should expect to see updates and additions; these will be versioned and made backwards compatible whenever possible.

Presently, EMIT comprises one tissue microarray (TMA) dataset and one whole-slide image (WSI) dataset. Users of these resources should cite [Schapiro et al 2021](https://www.nature.com/articles/s41592-021-01308-y).


## Tissue microarrays (TMAs)

<img src="{{ site.baseurl }}/images/EMIT_TMA22.png" alt="EMIT-TMA22">

The TMA contains cores from 34 cancer, non-neoplastic diseases, and normal tissues collected from clinical discards under an IRB-supervised protocol. The TMA was imaged using the [cyclic immunofluorescence (CyCIF) method](https://www.cycif.org/) described in [Lin et al 2018](https://elifesciences.org/articles/31657). Data were collected with a 20X magnification, 0.75 NA objective with 2x2-pixel binning using two multiplex antibody panels (on section 11 “TMA11” and section 22 “TMA22").

* [Primary Data](https://www.synapse.org/#!Synapse:syn22345748/wiki/609239)

## Whole-slide images (WSIs)

Data was collected from a tonsil specimen (4 year-old female, caucasian). The specimen was serially sectioned with each section processed using a different imaging techonology. The resulting images comprise a 100+GB dataset, which has been processed by MCMICRO with primary data and all intermediates available on [Synapse](https://www.synapse.org/#!Synapse:syn24849819/wiki/608441).

* [Primary Data](https://www.synapse.org/#!Synapse:syn24849819/wiki/608441)
* [Additional information](https://labsyspharm.github.io/mcmicro-images/)
* Preview:

<div class="basic-grid four-column">

{% include image-card.html 
    image="https://labsyspharm.github.io/mcmicro-images/images/thumbnail-WD-75684-01.jpg"
    link="https://labsyspharm.github.io/mcmicro-images/stories/WD-75684-01.html"
    label="H&E"
%}
{% include image-card.html 
    image="https://labsyspharm.github.io/mcmicro-images/images/thumbnail-WD-75684-02.jpg"
    link="https://labsyspharm.github.io/mcmicro-images/stories/WD-75684-02.html"
    label="CyCIF"
%}
{% include image-card.html 
    image="https://labsyspharm.github.io/mcmicro-images/images/thumbnail-WD-75684-12.jpg"
    link="https://labsyspharm.github.io/mcmicro-images/stories/WD-75684-12.html"
    label="mIHC"
%}
{% include image-card.html 
    image="https://labsyspharm.github.io/mcmicro-images/images/thumbnail-WD-75684-05.jpg"
    link="https://labsyspharm.github.io/mcmicro-images/stories/WD-75684-05.html"
    label="CODEX"
%}

</div><!-- end grid -->

---
layout: default
title: Example data sets
nav_order: 6
has_children: false
---
# Example data sets
{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

## Exemplar data for testing MCMICRO

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
*Note that the representative images above depict only a subset of the image channels present in each data set.*
{: .fs-3}

<br>

**Two exemplars are currently available for demonstration purposes:**
* `exemplar-001` is a minimal reproducible example for running all modules of the pipeline, except the dearray step. 
>* The exemplar consists of a small lung adenocarcinoma specimen taken from a larger tissue microarray (TMA), imaged using CyCIF with three cycles. 
>* Each cycle consists of six four-channel image tiles, for a total of 12 channels. 
>* Because this exemplar is too small for automated illumination correction, illumination profiles were precomputed from the entire TMA and included with the raw images.

* `exemplar-002` is a two-by-two segment of a TMA that is meant to test the dearray step, followed by processing of all four cores in parallel. . 
>* The four cores are two meningioma tumors, one GI stroma tumor, and one normal colon specimen. 
>* This data set has ten cycles with 40 total channels and also includes precomputed illumination profiles.

**After [installing Nextflow]({{ site.baseurl }}/instructions/nextflow/installation.html), both exemplars can be downloaded using the following commands:**
``` bash
nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-001 --path /local/path/
nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-002 --path /local/path/
```

>(Content download to the directory indicated by `/local/path/`.)
{: .fs-3}

<br>

**Or, the examples can be downloaded as .zip files.**

{: .fs-3}
> **Note:** When downloading the example files from this link, your system will need enough space for both the .zip file and for the expanded contents (indicated above). Downloading via these links is slower than the command line download, but may be preferred by users that are not using Nextflow.

* **Exemplar-001:** [https://mcmicro.s3.amazonaws.com/exemplars/exemplar-001.zip](https://mcmicro.s3.amazonaws.com/exemplars/exemplar-001.zip) - 240 MB (320 MB unzipped)
* **Exemplar-002:** [https://mcmicro.s3.amazonaws.com/exemplars/exemplar-002.zip](https://mcmicro.s3.amazonaws.com/exemplars/exemplar-002.zip) - 2.5 GB (3.5 GB unzipped)

<br>

### Visual Guide: Processing Exemplar-002 with MCMICRO 
This detailed [visual guide]({{ site.baseurl }}/tutorial/pipeline-visual-guide.html){:target="_blank"}  walks you through the MCMICRO pipeline steps as it processes `exemplar-002`. This guide was generated using the [Minerva]({{base.siteurl}}/modules/#minerva) software package.

[View the visual guide]({{ site.baseurl }}/tutorial/pipeline-visual-guide.html){: .btn .btn-green .btn-outline .btn-arrow }

<br>

{: .text-center}
**Want to give it a try??** Process Exemplar-001 and -002 using our [tutorial]({{ site.baseurl }}/tutorial/tutorial.html)!

<br>

## Exemplar Microscopy Images of Tissues (EMIT)

The EMIT (Exemplar Microscopy Images of Tissues) data set is reference data containing a variety of images that can be used to develop and benchmark computational methods for image processing. These data are expected to be useful for biological studies; however, annotation of this data set for biological interpretation ongoing. Users of these data should expect to see updates and additions - these will be versioned and made backwards compatible whenever possible.

Presently, EMIT comprises one tissue microarray (TMA) data set and one whole-slide image (WSI) data set. Users of these resources should cite [Schapiro et al 2021](https://doi.org/10.1038/s41592-021-01308-y){:target="_blank"}.


### Tissue microarrays (TMAs)

<img src="{{ site.baseurl }}/images/EMIT_TMA22.png" alt="EMIT-TMA22">

The TMA contains cores from 34 cancer, non-neoplastic diseases, and normal tissues collected from clinical discards under an IRB-supervised protocol. The TMA was imaged using the [cyclic immunofluorescence (CyCIF) method](https://www.cycif.org/){:target="_blank"} described in [Lin et al 2018](https://elifesciences.org/articles/31657){:target="_blank"}. Data were collected with a 20X magnification, 0.75 NA objective with 2x2-pixel binning using two multiplex antibody panels (on section 11 “TMA11” and section 22 “TMA22").

* [Primary Data](https://www.synapse.org/#!Synapse:syn22345748/wiki/609239){:target="_blank"}

### Whole-slide images (WSIs)

Data was collected from a tonsil specimen (4 year-old female, caucasian). The specimen was serially sectioned with each section processed using a different imaging techonology. The resulting images comprise a 100+GB dataset, which has been processed by MCMICRO with primary data and all intermediates available on [Synapse](https://www.synapse.org/#!Synapse:syn24849819/wiki/608441){:target="_blank"}.

* [Primary Data](https://www.synapse.org/#!Synapse:syn24849819/wiki/608441){:target="_blank"}
* [Additional information](https://labsyspharm.github.io/mcmicro-images/){:target="_blank"}
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

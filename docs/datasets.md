---
layout: default
title: Datasets
nav_order: 40
---

# Exemplar Microscopy Images of Tissues (EMIT)

MCMICRO is accompanied by EMIT (Exemplar Microscopy Images of Tissues), which is a reference dataset containing images of different types for development and benchmarking of computational methods for image processing. The data are also expected to be useful for biological studies. However, the data are complex and annotation for the purposes of biological interpretation is an ongoing activity. Users of these data should expect to see updates and additions; these will be versioned and made backwards compatible whenever possible.

Presently, EMIT comprises one tissue microarray (TMA) dataset and one whole-slide image (WSI) dataset. Users of these resources should cite [Schapiro et al 2021](https://www.biorxiv.org/content/10.1101/2021.03.15.435473v1).


## Tissue microarrays (TMAs)

<img src="{{ site.baseurl }}/images/EMIT_TMA22.png" alt="EMIT-TMA22">

The TMA contains cores from 34 cancer, non-neoplastic diseases, and normal tissues collected from clinical discards under an IRB-supervised protocol. The TMA was imaged using the [cyclic immunofluorescence (CyCIF) method](https://www.cycif.org/) described in [Lin et al 2018](https://elifesciences.org/articles/31657). Data were collected with a 20X magnification, 0.75 NA objective with 2x2-pixel binning using two multiplex antibody panels (on section 11 “TMA11” and section 22 “TMA22").

* [Primary Data](https://www.synapse.org/#!Synapse:syn22345748/wiki/609239)

## Whole-slide images (WSIs)

Data was collected from a tonsil specimen (4 year-old female, caucasian). The specimen was serially sectioned with each section processed using a different imaging techonology. The resulting images comprise a 100+GB dataset, which has been processed by MCMICRO with primary data and all intermediates available on [Synapse](https://www.synapse.org/#!Synapse:syn24849819/wiki/608441).

* [Primary Data](https://www.synapse.org/#!Synapse:syn24849819/wiki/608441)
* [Additional information](https://labsyspharm.github.io/mcmicro-images/)
* Preview:

| H&E | CyCIF |	mIHC | CODEX |
| :-: | :-: | :-: | :-: |
<a href="https://labsyspharm.github.io/mcmicro-images/stories/WD-75684-01.html"><img src="{{ site.baseurl }}/images/EMIT-WSI/thumbnail-WD-75684-01.jpg"></a> | <a href="https://labsyspharm.github.io/mcmicro-images/stories/WD-75684-02.html"><img src="{{ site.baseurl }}/images/EMIT-WSI/thumbnail-WD-75684-02.jpg"></a> | <a href="https://labsyspharm.github.io/mcmicro-images/stories/WD-75684-12.html"><img src="{{ site.baseurl }}/images/EMIT-WSI/thumbnail-WD-75684-12.jpg"></a> | <a href="https://labsyspharm.github.io/mcmicro-images/stories/WD-75684-05.html"><img src="{{ site.baseurl }}/images/EMIT-WSI/thumbnail-WD-75684-05.jpg"></a> |

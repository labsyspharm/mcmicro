---
layout: default
title: MCMICRO Methods
nav_order: 2
parent: Overview
has_children: true
---
{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

# Phase 3: Processing and analyzing images with the MCMICRO
Multiplexed imaging results in a potentially unwieldy volume of data. Whole-slide sample areas are generally quite large, so whole slides are imaged by dividing a large specimen into a grid of tiles – often 100-1,000 tiles are needed per slide.  Together, this results in highly multiplexed, biologically rich, image sets that encompass many sample positions and many proteins. Each tile is a multi-dimensional TIFF that encompasses the multiple channels of data. After multiple imaging cycles the full data set is massive –up to 50,000 x 50,000 pixels x 100 channels per tile or ~500 GB of data per slide – too large to be processed by conventional image processing methods.

That’s where MCMICRO comes in. MCMICRO provides a modular, customizable pipeline that allows users to process images into cohesive images that can be easily visualized and quantified as single cell data.

Walk through the process of turning image tiles into single-cell segmented mosaic image with our [pipeline visual guide](link).

![Visual overview of the MC MICRO pipeline components: Basic for illumination correction, Ashlar for alignment and stitching, Coreograph for TMA Core detection, UnMicst or S3 segmenter for segmentation, MC Quant for image quantification.]({{ site.baseurl }}/images/mcmicro-pipeline-two-rows-v2.png)

## Image tiles to whole-slide mosaic images
Before performing analysis, the many image tiles must be combined into a single mosaic image where all tiles and channels can be viewed simultaneously. We do this with: i) illumination correction through BaSIC, ii) alignment and stitching by ASHLAR, and iii) image quality control using human-in-the-loop methods.

**BaSiC<sup>12</sup>**
Collecting multiplexed images is time consuming – imaging multiple whole slide samples can sometimes span several days. Microscope illumination is rarely perfectly stable over these long periods of time, so individual tile illumination is generally not perfectly uniform. We correct for these issues with a process known as _flat fielding_ using the BaSiC<sup>26</sup> software package (developed elsewhere). We are currently working to more tightly link BaSIC to the next module, ASHLAR, to further improve illumination evenness.

**ASHLAR<sup>26</sup>**
The tiles must then be combined into a seamlessly aligned mosaic image in a process known as _stitching._ We developed the [ASHLAR](https://github.com/labsyspharm/ashlar) (Mulich et al., 2021) software package to generate highly accurate mosaic images for whole-slide imaging. Visit the [ASHLAR website](https://labsyspharm.github.io/ashlar) to learn more about how ASHLAR works, and how to implement ASHLAR.

**Coreograph**
{Add}

## Mosaic images to single-cell data
Extracting single-cell level data from highly multiplexed image data allows for clinically useful biological data at a depth that was not previously possible. To do this, images must first be segmented into single cells, then interesting features can be extracted into a descriptive cell features table. 

### Segmentation
Image processing is necessary to extract quantitative data from images. Although machine learning directly on images shows promise, most high-plex tissue imaging studies require the image to be 'segmented' into single cells before extracting single-cell data on a per-cell or per organelle basis. There are a number of solutions for segmentation that can be used with MCMICRO. We describe two, UnMICST<sup>27</sup>, a method based on pixel probability maps, and S3segmenter<sup>28</sup>, a watershed method.

**UnMicst**<sup>27</sup>
{Add}


**S3Segmenter**<sup>28</sup>
{Add}


### Quantification and analysis

**MCQuant**
{Add}

**Cell feature tables**
The conversion of images into single cell data generates a _Cell Feature Table_ – analogous to a count table in RNA sequencing – that records the positions of individual cells and the associated features such as marker intensity, morphology, and quality control attributes. The Cell Feature Table is used for all subsequent analysis.

MCMICRO also includes a variety of specialized tools for analyzing spatial data using methods derived from physics, geographic information systems and ecology, but Cell Feature Tables can also be visualized using many tools developed for visualization of single cell sequencing data, like cellxgene<sup>23</sup>. It is important to note that a single marker in an image can be processed to generate a large number of distinct descriptive features beyond marker intensity (e.g. shape, granularity, localization within the cell, etc.).

**SCIMAP**<sup>29</sup>

**Image quality control**
In practice, all tissue images contain technical artifacts that can disrupt image analysis. Artifacts can include sectioning artifacts (areas where the knife compresses or tears the specimen), embedded foreign objects (dust, hair), regions of fat or necrotic tissue that cannot easily be analyzed. Foreign objects are often the brightest pixels in an image and become outliers when high-dimensional data are clustered. Humans are remarkably good at looking past these artifacts to identify biologically meaningful patterns in biological data, but artifacts complicate computational methods of single-cell data analysis. 

We and others are working on human-in-the loop and automated methods to identify and suppress these artifacts, but until then, MCMICRO users must examine the underlying image data, segmentation mask, and quantified features (per-cell marker intensities) to minimize the impact of noise.

### Visualization

**MINERVA**<sup>24</sup>

## Training data
Quality machine learning algorithms can only be generated from quality training data. Currently the field lacks sufficient freely-available data with ground truth labeling (such as pathologist-annotated images). Past experience in the machine learning community with natural scene images<sup>20</sup> proved that acquiring sufficient data with accurate labels remains time consuming and rate limiting<sup>22</sup>. The [Exemplar Microscopy Images of Tissues data set (EMIT)]({{ site.baseurl }}/datasets.html#exemplar-microscopy-images-of-tissues-emit) will help address this limitation. 

We expect the [EMIT]({{ site.baseurl }}/datasets.html#exemplar-microscopy-images-of-tissues-emit) data set to grow steadily; users of MCMICRO should stay abreast of updates in segmentation methods and models.

## The open microscopy environment (OME) 
MCMICRO is designed to solve the problem of processing high volumes of tissue image data and yield reliable image mosaics and single cell data. It does not, however, solve all problems associated in the analysis and publication of images. We strongly recommend that laboratories also adopt the database and visualization tools provided by the OME community. The [OME community](https://www.openmicroscopy.org/events/ome-community-meeting-2021/) is welcoming and it has many on-line resources that discuss the topics described above; OME sponsors multiple workshops and conferences of interest to new and experienced microscopists.

In our laboratories, we use MCMICRO, OME/OMERO and [MINERVA](https://github.com/labsyspharm/minerva-story/wiki) (an interactive viewing and data sharing platform) in parallel<sup>24</sup>.
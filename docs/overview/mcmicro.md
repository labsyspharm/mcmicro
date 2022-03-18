---
layout: default
title: MCMICRO intro
nav_order: 2
parent: Overview
has_children: true
---

# Processing and analyzing images with MCMICRO

Multiplexed imaging results in a potentially unwieldy volume of data. Whole-slide sample areas are large, so slides are imaged by dividing the specimen into a grid of tiles – between 10<sup>2</sup> to 10<sup>3</sup> tiles per slide - where each tile is a multidimensional TIFF. When combined with multiplexed imaging methods, this results in biologically rich image sets that encompass many sample positions and many proteins. The resulting data set is massive – up to 50,000 x 50,000 pixels x 100 channels per tile or ~500 GB of data per slide – too large to be handled with conventional image processing methods. 

{: .text-center }
{: .fs-5}
_**This is where MCMICRO comes in.**_ 

{: .text-center }
MCMICRO provides a modular pipeline that processes whole slide microscopy data into cohesive images that can be easily visualized and quantified as single cell data.

<br>

{: .text-center}
{: .fw-200}
*Click on the modules below to learn more.*


<svg xmlns="http://www.w3.org/2000/svg" xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" viewBox="0 0 466 250" inkscape:version="0.92.4 (5da689c313, 2019-01-14)" sodipodi:docname="imgmap_overview.svg" style="background-image: url(../images/pipeline-two-rows-v3.png)">

<defs>
<style>
svg {
          background-size: 100% 100%;
          background-repeat: no-repeat;
          max-width: 1500px;
          width: 100%
        }
        path {
            fill: transparent;
        }
</style>
</defs>

<a xlink:href="../overview/mcmicro.html#image-tiles-to-whole-slide-mosaic-images">
<title>BaSiC</title>
<path d="M10 160h63v53H9Z" inkscape:connector-curvature="0" transform="translate(0 -47)"/>
</a>

<a xlink:href="../overview/mcmicro.html#image-tiles-to-whole-slide-mosaic-images">
<title>Coreograph</title>
<path d="M116 244v53l65-1-2-54z" inkscape:connector-curvature="0" transform="translate(0 -47)"/>
</a>

<a xlink:href="../overview/mcmicro.html#mosaic-images-to-single-cell-data">
<title>UnMICST</title>
<path d="m208 159 64 1-1 44h-64z" inkscape:connector-curvature="0" transform="translate(0 -47)"/>
</a>

<a xlink:href="../overview/mcmicro.html#segmentation">
<title>S3Segmenter</title>
<path d="m208 205 63 1v31l-64 1z" inkscape:connector-curvature="0" transform="translate(0 -47)"/>
</a>

<a xlink:href="../overview/mcmicro.html#image-tiles-to-whole-slide-mosaic-images">
<title>ASHLAR</title>
<path d="m82 160 63 1v47H82Z" inkscape:connector-curvature="0" transform="translate(0 -47)"/>
</a>

<a xlink:href="../overview/mcmicro.html#quantification">
<title>MCQuant</title>
<path d="m282 160 61 1v49l-62-1z" inkscape:connector-curvature="0" transform="translate(0 -47)"/>
</a>

<a xlink:href="../overview/mcmicro.html#quality-control">
<title>CyLinter</title>
<path d="M281 244h62v52h-61z" inkscape:connector-curvature="0" transform="translate(0 -47)"/>
</a>

<a xlink:href="../overview/mcmicro.html#analysis">
<title>SCIMAP</title>
<path d="m354 159 41 1v54h-41z" inkscape:connector-curvature="0" transform="translate(0 -47)"/>
</a>

<a xlink:href="../overview/mcmicro.html#visualization">
<title>MINERVA</title>
<path d="M405 160h42l-1 56-41-1z" inkscape:connector-curvature="0" transform="translate(0 -47)"/>
</a>

<a xlink:href="../overview/mcmicro.html#visualization">
<title>Other Modules</title>
<path d="m401 234 46 1-1 48-2 7-42-1z"  inkscape:connector-curvature="0" transform="translate(0 -47)"/>
</a>

</svg>

<br>

{: .text-center }
{: .fw-500}
Walk through the process of turning image tiles into single-cell segmented mosaic image: <br>[MCMICRO Pipeline Visual Guide]({{ site.baseurl }}/tutorial/pipeline-visual-guide.html){: .btn .btn-green .btn-outline .btn-arrow }

<br>

{: .fs-9 }
{: .fw-500}
{: .text-grey-dk-100}
## The MCMICRO modules:

{: .text-purple-300}
{: .fw-500}
## Image tiles to whole-slide mosaic images
Before performing analysis, the image tiles must be combined into a single mosaic image where all tiles and channels can be viewed simultaneously. We do this with i) illumination correction through BaSIC, ii) alignment and stitching by ASHLAR, and iii) image quality control using human-in-the-loop methods.

{: .text-center }
{: .fs-3 }
{: .fw-300 }
![Visualization of illumination correction and stitching into a mosaic image]({{ site.baseurl }}/images/stitching-art.png)
From raw image (left) to illumination corrected tiles using BaSiC (center left) to a stitched mosaic image with ASHLAR (right). <sub>Credit: C. Yapp</sub>

{: .fs-6}
{: .text-purple-300}
### Illumination Correction  

**BaSiC**  
Collecting multiplexed images is time consuming – imaging multiple whole slide samples can sometimes span several days. Microscope illumination is rarely perfectly stable over these long periods of time, so individual tile illumination is not entirely uniform. We correct for these issues with a process known as _flat fielding_ using the BaSiC [(Peng et al., 2017)](https://doi.org/10.1038/ncomms14836){:target="_blank"} software package (developed elsewhere).

{: .fs-6}
{: .text-purple-300}
### Stitching and registration  

**ASHLAR**  
The tiles must then be combined into a seamlessly aligned mosaic image in a process known as _stitching._ We developed the [ASHLAR](https://github.com/labsyspharm/ashlar){:target="_blank"} software package to generate highly accurate mosaic images for whole-slide imaging [(Muhlich et al., 2021)](https://doi.org/10.1101/2021.04.20.440625){:target="_blank"}. Visit the [ASHLAR website](https://labsyspharm.github.io/ashlar){:target="_blank"} to learn more about how ASHLAR works and how to implement ASHLAR.

{: .fs-6}
{: .text-purple-300}
### TMA core detection (optional) 

**Coreograph**  
[Coreograph]({{ site.baseurl }}/modules/coreograph.html) identifies complete/incomplete tissue cores on a tissue microarray and exports these individual tissue core images for faster downstream image processing [(Schapiro et al., 2021)](https://doi.org/10.1038/s41592-021-01308-y){:target="_blank"}. Coreograph uses a deep learning model, UNet [(Ronneberger et al., 2015)](https://arxiv.org/abs/1505.04597){:target="_blank"}.

{: .text-center }
{: .fs-3 }
{: .fw-300 }
![TMA array showing TMA cores and their corresponding masks]({{ site.baseurl }}/images/coreograph-crop.png)
A TMA array showing tissue cores (center) that have been processed with Coreograph to generate individual core masks (green outlines, left and right). <sub>Credit: C. Yapp</sub>

---

{: .fw-500 }
{: .text-green-200}
## Mosaic images to single-cell data
Extracting single-cell level data from highly multiplexed image data allows for clinically useful biological data at a depth that was not previously possible. To do this, images must first be segmented into single cells, then interesting features can be extracted into a descriptive cell features table. 

{: .fs-6}
{: .text-green-200}
### Segmentation  

Image processing is necessary to extract quantitative data from images. Although machine learning directly on images shows promise, most high-plex tissue imaging studies require the image to be 'segmented' into single cells before extracting single-cell data on a per-cell or per organelle basis. There are many solutions for segmentation that can be used with MCMICRO. We describe two, UnMICST [(Yapp et al., 2021)](https://doi.org/10.1101/2021.04.02.438285){:target="_blank"}, a method that generates pixel probability maps, and S3segmenter [(Saka et al., 2019)](https://doi.org/10.1038/s41587-019-0207-y){:target="_blank"}, a watershed method for generating segmentation masks.

{: .text-center }
{: .fs-3 }
{: .fw-300 }
![Visualization of raw image of cells being segmented into single cells from left to right]({{ site.baseurl }}/images/Segmentation_crop2.png)
Segmentation - from raw image (left) to preprocessing using UnMICST (center) to single cells (right). <sub>Credit: C. Yapp</sub>

**UnMICST**  
UnMICST is one example of a semantic segmentation method that  generates pixel-level probability maps. These probability maps use pixel intensity to indicate how confidently that pixel has been classified as either the nucleus or background of the image [(Yapp et al., 2021)](https://doi.org/10.1101/2021.04.02.438285){:target="_blank"}. Visit the [UnMICST website](https://labsyspharm.github.io/UnMICST-info/){:target="_blank"} to learn more!

**S3segmenter**  
[S3segmenter](https://github.com/HMS-IDAC/S3segmenter){:target="_blank"} provides one example of a marker-controlled watershed approach to segmentation. S3segmenter takes in segmentation probability maps and uses them to generate single-cell (nuclei and cytoplasm) masks. S3segmenter is quite versatile - it is compatible with both semantic and instance based segmentation methods and can also be applied for robust spot detection (i.e. RNAscope or FISH) within samples.

{: .fs-6}
{: .text-green-200}
### Quantification  
   
**MCQuant**   
[MCQuant](https://github.com/labsyspharm/quantification){:target="_blank"} takes in a multichannel image and segmentation mask and extracts single-cell data. This generates a _Cell Feature Table_ that records the positions of individual cells and the associated features such as marker intensity, morphology, and quality control attributes. The Cell Feature Table is used for all subsequent analysis and is compatible with many tools developed for visualization of single cell sequencing data, like cellxgene [(Megill et al., 2021)](https://doi.org/10.1101/2021.04.05.438318){:target="_blank"}. 

{: .fs-3}
**Note:** A single marker can be processed to generate a large number of distinct descriptive features beyond marker intensity (e.g. shape, granularity, localization within the cell, etc.).

{: .fs-6}
{: .text-green-200}
### Quality control  

All tissue images contain technical artifacts that can disrupt image analysis. These can include sectioning artifacts (areas where the knife compresses or tears the specimen), embedded foreign objects (dust, hair), or regions of fat or necrotic tissue that cannot easily be analyzed. Humans are remarkably good at looking past these artifacts to identify biologically meaningful patterns in biological data, but artifacts complicate computational methods of single-cell data analysis. 

**CyLinter**  
[CyLinter](https://labsyspharm.github.io/cylinter/){:target="_blank"} is a human-in-the-loop interactive quality control [software](https://github.com/labsyspharm/cylinter){:target="_blank"} for identifying and removing cells corrupted by microscopy artifacts in multiplexed tissue images. The program takes single-cell feature tables generated by the MCMICRO image processing pipeline as input and returns a set of de-noised feature tables for use in downstream analyses. 

{: .fs-6}
{: .text-green-200}
### Analysis  

**SCIMAP**  
Scimap is a scalable toolkit for analyzing spatial molecular data. SCIMAP takes in spatial data mapped to X-Y coordinates and supports preprocessing, phenotyping, visualization, clustering, spatial analysis and differential spatial testing [(Nirmal et al., 2022)](https://doi.org/10.1101/2021.05.23.445310){:target="_blank"}. Visit the [SCIMAP website](https://scimap.xyz/){:target="_blank"} for more detailed information.

{: .fs-6}
{: .text-green-200}
### Visualization  

**Minerva**  
Minerva is a suite of software tools that enables interactive viewing and sharing of large image data ([Rashid et al., 2021](https://doi.org/10.1038/s41551-021-00789-8){:target="_blank"}; [Hoffer et al., 2020](https://doi.org/10.21105/joss.02579){:target="_blank"}). Currently, we have released **Minerva Author**, a tool that lets you easily create and annotate images, and **Minerva Story**, a narrative image viewer for web hosting. Additional tools are in active development - go to the [Minerva wiki](https://github.com/labsyspharm/minerva-story/wiki){:target="_blank"} for the most up-to-date information about the Minerva suite. 

{: .text-center }
{: .fs-3 }
{: .fw-300 }
![Screenshot from Minerva story on lung cancer]({{ site.baseurl }}/images/minerva-examp.png)
A screenshot from a Minerva story on primary lung cancer - view the story [here](https://www.cycif.org/data/du-lin-rashid-nat-protoc-2019/osd-LUNG_3#s=1#w=3#g=0#m=0_3_2_1#a=-100_-100#v=0.5_0.5_0.5#o=-100_-100_1_1#p=Q){:target="_blank"} .

{: .text-center }
{: .fs-6}
\*\*Missing something?? --  [Suggest a module]({{site.baseurl}}/modules/#suggest-a-module) for us to develop in the future!\*\*

{: .fs-9 }
{: .fw-500}
{: .text-grey-dk-100}
## Training data
Quality machine learning algorithms can only be generated from quality training data. Currently the field lacks sufficient freely-available data with ground truth labeling (such as pathologist-annotated images). Past experience in the machine learning community with natural scene images [(Ronnenberger et al., 2015)](https://doi.org/10.48550/arXiv.1505.04597){:target="_blank"} proved that acquiring sufficient data with accurate labels remains time consuming and rate limiting [(Gurari et al., 2015)](https://doi.org/10.1109/WACV.2015.160){:target="_blank"}. The Exemplar Microscopy Images of Tissues data set [(EMIT)]({{ site.baseurl }}/datasets.html#exemplar-microscopy-images-of-tissues-emit) will help address this limitation. 

We expect the [EMIT]({{ site.baseurl }}/datasets.html#exemplar-microscopy-images-of-tissues-emit) data set to grow steadily; users of MCMICRO should stay abreast of updates in segmentation methods and models.

{: .fs-9 }
{: .fw-500}
{: .text-grey-dk-100}
## The open microscopy environment (OME) 
MCMICRO is designed to solve the problem of processing high volumes of tissue image data and yield reliable image mosaics and single cell data. It does not, however, solve all problems associated with the analysis and publication of images. We strongly recommend that laboratories also adopt the database and visualization tools provided by the OME community. The [OME community](https://www.openmicroscopy.org/events/ome-community-meeting-2021/){:target="_blank"} is welcoming and has many online resources that discuss the topics described above; OME sponsors multiple workshops and conferences of interest to new and experienced microscopists.

{: .text-center }
{: .fs-5 }
In our laboratories, we use MCMICRO, OME/OMERO and MINERVA in parallel.

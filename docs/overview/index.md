---
layout: default
title: Overview
nav_order: 2
has_children: true
---

# Overview Video

{% include youtube.html id="fnxBvgJQmtY" autoplay=false mute=false controls=true loop=false related=false %}

A general introduction [video](https://www.youtube.com/watch?v=fnxBvgJQmtY) that provides a high-level overview of the pipeline.

---
# Overview of multiplexed tissue imaging collection, processing, and analysis

Here we introduce some key background information relevant to highly multiplexed tissue imaging that provide context on tissue imaging and highlight the need for MCMICRO.

<div class="basic-grid three-column row center-xs">

<div markdown="1">
{% assign imageUrl = site.baseurl | append: "/images/main-menu-1.png" %} {% include image-card.html 
	image=imageUrl
	link="./#1-staining-proteins-or-molecules-in-biological-samples"
	label="Go to section 1"
%} 
</div>
<div markdown="1">
{% assign imageUrl = site.baseurl | append: "/images/main-menu-2.png" %} {% include image-card.html
	image=imageUrl 
	link="./#2-immunofluorescence-imaging-for-biological-samples"
	label="Go to section 2"
%} 
</div>
<div markdown="1">
{% assign imageUrl = site.baseurl | append: "/images/main-menu-3.png" %} {% include image-card.html
	image=imageUrl 
	link="./#3-processing-and-analyzing-images-with-the-mcmicro"
	label="Go to section 3"
%} 
</div>
</div><!-- end grid -->

## 1. Staining proteins or molecules in biological samples

To diagnose disease, doctors often will often biopsy a patient, removing a small, 2-4 mm cylindrical tissue sample that can be studied in greater detail under a microscope. These biopsies are treated with chemicals that preserve the sample, sliced into 1-10 μm sections, and adhered to microscope slides. These samples can then be stained with a variety of molecules to more clearly visualize various aspects of the tissue. There are several methods for staining tissues – here we describe two. First, we describe colorimetric stains that have historically been the ‘gold standard’ for pathology diagnoses, and second, immunofluorescence that has been instrumental for visualizing specific proteins or molecules within samples (Boyle, 2008).

### Hematoxylin and eosin (H&E) and colorimetric stains
<img src="{{ site.baseurl }}/images/hande.png" align="right" style="margin-right:10px" alt="H&E staining of pancreatic ductal adenocarcinoma (PDAC) resection specimen that includes portions of cancer and non-malignant pancreatic tissue and small intestine. (From Lin. et al., 2018, eLife.)" width="300"/>
Pathologists stain tissue components with colorimetric dyes to better visualize subtle differences within tissue samples<sup>16,17</sup>. Hematoxylin and Eosin stains (H&E) are one of the most common dyes used to stain biological tissues for pathological analysis. Hematoxylin stains nuclei purple and eosin stains extracellular matrix and cytoplasm pink, while other cell structures display colors in-between. The use of H&E stained samples to diagnose or treat disease, known as histopathology, remains the primary way that diseases such as cancer are staged and managed<sup>18</sup>. Histopathology, therefore, is a critical component of disease diagnosis and treatment, but provides a limited view of the specific molecular interactions that are happening within a tissue.

*The image above shows and example H&E stained pancreatic ductal adenocarcinoma (PDAC) specimen that includes portions of cancerous and non-malignant pancreatic tissue and small intestine. From [(Lin et al., 2018, eLife)](https://doi.org/10.7554/eLife.31657).*

### Immuno-labeling

<img src="{{ site.baseurl }}/images/if.png" align="right" style="margin-right:10px" alt="Identical sample as H&E stained image above, this section was stained with antibodies & imaged with fluorescent imaging (from Lin et al., 2018, eLife.)" width="300"/>
Text about immunofluorescence. Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Stained proteins colloquially called “markers”

*The image above shows an immunofluorescent pancreatic ductal adenocarcinoma (PDAC) specimen. From [(Lin et al., 2018, eLife)](https://doi.org/10.7554/eLife.31657).*

## 2. Immunofluorescence imaging for biological samples

Once samples have been stained with fluorescently-labeled antibodies, immunofluorescence microscopy can be used to image these specific proteins within the sample. Under a microscope, the samples are pulsed briefly with light of a specific wavelength, causing the fluorophore to emit light of a longer wavelength that can be detected by the microscope to reveal the location of the fluorescent antibody within the sample. The specific excitation and emission wavelengths are fluorophore-dependent, so it is possible to carefully select 4-6 fluorophores that can be imaged simultaneously (and many [references]( http://www.geomcnamara.com/data) exist to help with this selection).

Classical immunofluorescence allows for precise visualization of 4-6 proteins or molecules within a sample and is generally performed only once per sample. Several new techniques, however, enable multiple rounds of immunofluorescence to be performed on a single sample. These multiplexed imaging techniques include cyclic immunofluorescence (CyCIF)<sup>1</sup>, Multiplexed Immunofluorescence (MxIF)<sup>2</sup>, CO-Detection by indEXing (CODEX)<sup>3</sup>, and Signal Amplification by Exchange Reaction (immuno-SABER)<sup>4</sup>. The precise methods vary per techniques, but as an example, CyCIF deactivates prior fluorophores between rounds of staining and imaging to allow for 8-20 cycles of imaging per sample <sup>1</sup>.

![Schematic depicting the stages of CyCIF imaging. 
1: Pre-staining to reduce auto-fluorescence. 2: Antibody incubation. 3: Nuclear staining. 4: 4-channel imaging. 5. Bleaching (flourophore oxidation). 6. Repeat for 8-20 cycles.
Note: H&E is done in parallel on seperate, serial sections. 
Image from Lin et al., 2018.]({{ site.baseurl }}/images/cycifoverview1.png)
*CyCIF schematic from [(Lin et al., 2018, eLife)](https://doi.org/10.7554/eLife.31657).<sup>1</sup>*

All these imaging methods generate data that can be represented as a series of intensity values on a two-dimensional raster, or grid. Imaging multiple fluorophores simply adds a dimension to the raster that is referred to as a separate channel. MCMICRO can process the 2D data from all methods mentioned above – extension to 3D is an area of active development, described [here]().

More information about how to compare multiplexed imaging technologies is provided [here](link to below section as a subpage).

### Data and metadata formats
The TIFF (Tagged Image File Format) is ideal for storing microscopy data at native resolution because it can combine multiple images in a single file (with each image occupying a separate layer in the file). 

TIFF files also contain metadata in the header that describes the organization and key properties of the images. For biomedical data, the [Open Microscopy Environment](https://www.openmicroscopy.org/ome-files/) (OME) TIFF format has become the most widely used standard for XML-based metadata and raster images. Because different vendors also have their own internal data standards, [Bio-Formats](https://www.openmicroscopy.org/bio-formats/) software was developed by the OME community to convert proprietary formats into a standardized, open format, most recently [OME-TIFF 6.0](https://docs.openmicroscopy.org/ome-model/6.0.1/ome-tiff/). This is a pyramid-encoded TIFF in which multiple resolutions of the same image are found in a single file to enable rapid pan and zoom, particularly using web tools (e.g. Google Maps). Many microscope vendors support Bio-Formats and it is the standard supported by MCMICRO and other image processing software developed by the Laboratory of Systems Pharmacology.

Metadata standards for high-plex image data are rapidly developing: a wide variety of laboratories have come together to create the Minimum Information about Tissue Imaging Standard [(MITI)](https://arxiv.org/abs/2108.09499)<sup>25</sup>. 

## 3. Processing and analyzing images with the MCMICRO
Multiplexed imaging results in a potentially unwieldy volume of data. Whole-slide sample areas are generally quite large, so whole slides are imaged by dividing a large specimen into a grid of tiles – often 100-1,000 tiles are needed per slide.  Together, this results in highly multiplexed, biologically rich, image sets that encompass many sample positions and many proteins. Each tile is a multi-dimensional TIFF that encompasses the multiple channels of data. After multiple imaging cycles the full dataset is massive –up to 50,000 x 50,000 pixels x 100 channels per tile or ~500 GB of data per slide – too large to be processed by conventional image processing methods.

That’s where MCMICRO comes in. MCMICRO provides a modular, customizable pipeline that allows users to process images into cohesive images that can be easily visualized and quantified as single cell data.

Walk through the process of turning image tiles into single-cell segmented mosaic image with our [pipeline visual guide](link).

![Visual overview of the MC MICRO pipeline components: Basic for illumination correction, Ashlar for alignment and stitching, Coreograph for TMA Core detection, UnMicst or S3 segmenter for segmentation, MC Quant for image quantification.]({{ site.baseurl }}/images/mcmicro-pipeline-two-rows-v2.png)

### Image tiles to whole-slide mosaic images
Before performing analysis, the many image tiles must be combined into a single mosaic image where all tiles and channels can be viewed simultaneously. We do this with: i) illumination correction through BaSIC, ii) alignment and stitching by ASHLAR, and iii) image quality control using human-in-the-loop methods.

**BaSiC**
Collecting multiplexed images is time consuming – imaging multiple whole slide samples can sometimes span several days. Microscope illumination is rarely perfectly stable over these long periods of time, so individual tile illumination is generally not perfectly uniform. We correct for these issues with a process known as _flat fielding_ using the BaSiC12 software package (developed elsewhere). We are currently working to more tightly link BaSIC to the next module, ASHLAR, to further improve illumination evenness.

**ASHLAR<sup>26</sup>**
The tiles must then be combined into a seamlessly aligned mosaic image in a process known as _stitching._ We developed the [ASHLAR](https://github.com/labsyspharm/ashlar) (Mulich et al., 2021) software package to generate highly accurate mosaic images for whole-slide imaging. Visit the [ASHLAR website](github.io/ashlar) to learn more about how ASHLAR works, and how to implement ASHLAR.

**Coreograph**
{Add}

**Image quality control**
In practice, all tissue images contain technical artifacts that can disrupt image analysis. Artifacts can include sectioning artifacts (areas where the knife compresses or tears the specimen), embedded foreign objects (dust, hair), regions of fat or necrotic tissue that cannot easily be analyzed, or across cyclic imaging, cell loss can occur across imaging cycles. Humans are remarkably good at looking past these artifacts to identify biologically meaningful patterns in biological data. However, artifacts substantially complicate computational methods of single-cell data analysis. For example, foreign objects are often the brightest pixels in an image and become outliers when high-dimensional data are clustered.

We and others are working on human-in-the loop and automated methods to identify and suppress these artifacts, but until then, MCMICRO users must iteratively examine the underlying image data, segmentation mask, and quantified features (per-cell marker intensities) to minimize the impact of noise.

### Mosaic images to single-cell data
Extracting single-cell level data from highly multiplexed image data allows for clinically useful biological data at a depth that was not previously possible. To do this, images must first be segmented into single cells, then interesting features can be extracted into a descriptive cell features table. 

#### Segmentation
Image processing is necessary to extract quantitative data from images. Although machine learning directly on images shows promise, most high-plex tissue imaging studies require the image to be 'segmented' into single cells before extracting single-cell data on a per-cell or per organelle basis. There are a number of solutions for segmentation that can be used with MCMICRO. We describe two, UnMICST<sup>27</sup>, a method based on pixel probabilty maps, and S3segmenter<sup>28</sup>, a watershed method.

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

### Visualization

**MINERVA**<sup>24</sup>

## The open microscopy environment (OME) 
MCMICRO is designed to solve the problem of processing high volumes of tissue image data and yield reliable image mosaics and single cell data. It does not, however, solve all problems associated in the analysis and publication of images. We strongly recommend that laboratories also adopt the database and visualization tools provided by the OME community. The [OME community](https://www.openmicroscopy.org/events/ome-community-meeting-2021/) is welcoming and it has many on-line resources that discuss the topics described above; OME sponsors multiple workshops and conferences of interest to new and experienced microscopists.

In our laboratories, we use MCMICRO, OME/OMERO and [MINERVA](https://github.com/labsyspharm/minerva-story/wiki) (an interactive viewing and data sharing platform) in parallel<sup>24</sup>.
---
layout: default
title: Experimental Methods
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

# Phase 1: Staining proteins or molecules in biological samples

To diagnose disease, doctors often biopsy patients, removing a small, 2-4 mm cylindrical tissue sample of tissue that can be studied in greater detail under a microscope. A pathologist takes this biopsy, treats it with preservative chemicals, slices it into 1-10 μm sections, and adheres these slices to microscope slides. The pathologist can then stain the slides with molecules that allow them to visualize various aspects of the tissue. There are several methods to staining these tissues – here we describe two classical methods. First, we describe the colorimetric stains - the gold standard for pathology diagnoses. Second, we discuss immunoflourescence - a technique that allows multiple proteins or molecules within a sample to be visualized simultaneously(Boyle, 2008).

### Hematoxylin and eosin (H&E) and colorimetric stains
<img src="{{ site.baseurl }}/images/hande.png" align="right" style="margin-right:10px" alt="H&E staining of pancreatic ductal adenocarcinoma (PDAC) resection specimen that includes portions of cancer and non-malignant pancreatic tissue and small intestine. (From Lin. et al., 2018, eLife.)" width="300"/>
Pathologists stain tissue components with colorimetric dyes to visualize subtle differences within tissue samples<sup>16,17</sup>. Hematoxylin and Eosin stains (H&E) are one of the most common dyes used to stain biological tissues for pathological analysis. Hematoxylin stains nuclei purple and eosin stains extracellular matrix and cytoplasm pink, while other cell structures display colors in-between. The use of H&E stained samples to diagnose or treat disease, known as histopathology, remains the primary way that diseases such as cancer are staged and managed<sup>18</sup>. Histopathology, therefore, is a critical component of disease diagnosis and treatment but provides a limited view of the specific molecular interactions that are happening within a tissue.

*The image above shows and example H&E stained pancreatic ductal adenocarcinoma (PDAC) specimen that includes portions of cancerous and non-malignant pancreatic tissue and small intestine. From [(Lin et al., 2018)](https://doi.org/10.7554/eLife.31657).*

### Immuno-labeling

<img src="{{ site.baseurl }}/images/if.png" align="right" style="margin-right:10px" alt="Identical sample as H&E stained image above, this section was stained with antibodies & imaged with fluorescent imaging (from Lin et al., 2018, eLife.)" width="300"/>
Text about immunofluorescence. Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Text about immunofluorescence.Stained proteins colloquially called “markers”

*The image above shows an immunofluorescent pancreatic ductal adenocarcinoma (PDAC) specimen. From [(Lin et al., 2018, eLife)](https://doi.org/10.7554/eLife.31657).*

# Phase 2: Immunofluorescence imaging for biological samples

After staining the samples with fluorescently-labeled antibodies, immunofluorescence microscopy can be used to image these specific proteins within the sample. A microscope pulses the sample with a specific wavelength of light. The light excites the fluorophore - triggering the fluorophore to emit light. The microscope detects the light emitted by the fluorophore, thus capturing the location of the fluorescent antibody within the sample. The specific excitation and emission wavelengths are fluorophore-dependent, so it is possible to carefully select 4-6 fluorophores that can be imaged simultaneously (and many [references]( http://www.geomcnamara.com/data) exist to help with this selection).

Classical immunofluorescence is generally performed only once per sample. However, several new techniques enable multiple rounds of immunofluorescence to be performed on a single sample. These multiplexed imaging techniques include cyclic immunofluorescence (CyCIF)<sup>1</sup>, Multiplexed Immunofluorescence (MxIF)<sup>2</sup>, CO-Detection by indEXing (CODEX)<sup>3</sup>, and Signal Amplification by Exchange Reaction (immuno-SABER)<sup>4</sup>. The precise methods vary per technique, but as an example, CyCIF deactivates prior fluorophores between rounds of staining and imaging to allow for 8-20 cycles of imaging per sample <sup>1</sup>.

![Schematic depicting the stages of CyCIF imaging. 
1: Pre-staining to reduce auto-fluorescence. 2: Antibody incubation. 3: Nuclear staining. 4: 4-channel imaging. 5. Bleaching (flourophore oxidation). 6. Repeat for 8-20 cycles.
Note: H&E is done in parallel on seperate, serial sections. 
Image from Lin et al., 2018.]({{ site.baseurl }}/images/cycifoverview1.png)
*CyCIF schematic from [(Lin et al., 2018, eLife)](https://doi.org/10.7554/eLife.31657).<sup>1</sup>*

All these imaging methods generate data that can be represented as a series of intensity values on a two-dimensional raster, or grid. Imaging multiple fluorophores simply adds a dimension to the raster that's referred to as a separate channel. MCMICRO can process the 2D data from all methods mentioned above – extension to 3D is an area of active development, described [here]({{ site.baseurl }}/overview/future.html#3d-image-processing).

More information about how to compare multiplexed imaging technologies is provided [here]({{ site.baseurl }}/overview/overview/mpi-comparison.html).

### Data and metadata formats
The TIFF (Tagged Image File Format) is ideal for storing microscopy data at native resolution because it can combine multiple images in a single file (with each image occupying a separate layer in the file). 

TIFF files also contain metadata in the header that describes the organization and key properties of the images. For biomedical data, the [Open Microscopy Environment](https://www.openmicroscopy.org/ome-files/) (OME) TIFF format has become the most widely used standard for XML-based metadata and raster images. Because different vendors also have their own internal data standards, [Bio-Formats](https://www.openmicroscopy.org/bio-formats/) software was developed by the OME community to convert proprietary formats into a standardized, open format, most recently [OME-TIFF 6.0](https://docs.openmicroscopy.org/ome-model/6.0.1/ome-tiff/). This is a pyramid-encoded TIFF in which multiple resolutions of the same image are found in a single file to enable rapid pan and zoom, particularly using web tools (e.g. Google Maps). Many microscope vendors support Bio-Formats and it is the standard supported by MCMICRO and other image processing software developed by the Laboratory of Systems Pharmacology.

Metadata standards for high-plex image data are rapidly developing: a wide variety of laboratories have come together to create the Minimum Information about Tissue Imaging Standard [(MITI)](https://arxiv.org/abs/2108.09499)<sup>25</sup>. 

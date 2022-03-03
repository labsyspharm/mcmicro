---
layout: default
title: Learn more
nav_order: 2
parent: Overview

---

# Areas for future development
### 3D Image Processing
Currently, high-plex tissue imaging of 3D samples remains rare. Most published 3D studies use stacks of images spaced along the Z axis (parallel to the objective lens). In live-cells studies, time is also captured by a series of images to create a movie. MCMICRO can manage 3D image stacks, however, specialized viewers are required to look at the data. In preclinical settings, there has been much effort to develop more effective ways to sample 3D data. The most common methods acquire data directly in 3D data without the need for physical sectioning, methods such as optical deconvolution microscopy<sup>13</sup>, confocal microscopy, and fluorescent light sheet microscopy (LSFM)<sup>14</sup>. LSFM is particularly valuable for tissue imaging because samples can be up to several hundred microns thick. These 3D sample compatible high-resolution microscopes are not yet commonly used for high-plex tissue imaging, but we expect their rapid uptake over the next few years. For this reason, we are working to add true 3D capability to MCMICRO.

### Image segmentation
Image segmentation is currently one of the most challenging steps in single-cell analysis of tissue images. Computationally, image segmentation assigns class labels to an image in a pixel-wise manner to optimally subdivide it. Extensive efforts have helped master cell segmentation for *in vitro*, 2-D cultures of cells, but segmenting cells within dense tissue samples is substantially more complex: cell sizes and shapes are more diverse in tissues, and cells are often closely packed. Deep learning methods have become standard in image segmentation, object detection, and synthetic image generation19, based on architectures such as ResNet, UNet and Mask R-CNN<sup>20,21</sup>. UNet in particular has become popular due to its ease of deployment on Graphical Processing Units (GPUs) and its superior performance. MCMICRO provides access to all of these architectures as a standard feature. It is always necessary to examine an overlay of primary image data and segmentation mask to make sure that images are not over or under segmented.

### Training data
One limitation of machine learning for tissue imaging is a lack of sufficient freely-available data with ground truth labelling. The [EMIT dataset](https://mcmicro.org/datasets.html#exemplar-microscopy-images-of-tissues-emit) is intended to address this requirement, but experience with natural scene images<sup>20</sup> has proven that acquiring sufficient data with accurate labels remains time consuming and rate limiting<sup>22</sup>. We expect the EMIT dataset to grow steadily; users of MCMICRO should stay abreast of updates in segmentation methods and models.

## Comparison of Multiplex Imaging Technologies
To our knowledge, no systematic comparison of tissue imaging technologies has yet been published. There are four relevant performance metrics to compare: 
>1. the multiplicity or 'plex' of the assay  
>2. spatial resolution  
>3. spatial scale and statistical power, and   
>4. sensitivity or signal to noise ratio (SNR).

These parameters are not independent of each other - objective lenses with higher resolving power (higher numerical aperture) gather light more efficiently, therefore, are more sensitive, but with a smaller field of view.

**Multiplicity**
Most discussion of the tissue imaging focuses on the multiplicity – the number channels – with a maximum number of 60 to 100 channels being typical. The great majority of published high-plex tissue imaging methods; however, involve 20-40 marker proteins. Increasing multiplicity is important, but most existing methods are limited by the specificity of antibody-antigen detection.

**Spatial resolution**
Most microscopy advances over the past two decades focused on increasing spatial resolution (e.g. super resolution imaging by structure illumination<sup>7</sup> or stochastic reconstruction8), but resolution has not been thoroughly discussed in tissue imaging studies. Higher resolution improves signal-to-noise, makes segmentation more robust, and is essential for discerning small structures. Most slide-scanning microscopes use objectives the range of 0.4 to 1.0 NA, giving them lateral resolutions of ~600 to 250 nm at an illumination wavelength of 550 nm (see [MicroscopyU](https://www.microscopyu.com/microscopy-basics/resolution) for details). This resolution is good but could be rapidly improved if slide scanning microscopes adopted more state-of-the-art imaging methods.

**Spatial scale and statistical power**
The size of samples being imaged is also critical for generating robust conclusions from tissue imaging data. Images exhibit spatial correlation on length scales up to 500 micron, so imaging insufficient sample areas may not provide an accurate representation – for many purposes, specimens at least one square centimeter are essential<sup>9</sup>. Additionally, it is increasingly clear that tissue microarrays (TMAs) are generally inadequate, despite their widespread use for increasing sample numbers. Clinically, TMAs are not used for diagnosis, and the FDA requires that digital histology be based on whole-slide imaging (WSI)<sup>10</sup>.  
MCMICRO was developed with the demands of high-plex, whole-slide imaging in mind.
           
**Sensitivity**
The sensitivity of an imaging method depends on a range of factors including the selectivity of the reagents, the quality of the instrumentation, resolution, etc. As such, sensitivity must be evaluated with respect to objective criteria. As mentioned above, the field awaits a rigorous comparison of different tissue imaging platforms (and of identical imaging platforms across multiple laboratories) before we can make robust comparisons of platform sensitivity.
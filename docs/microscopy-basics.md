---
layout: default
title: Appendix: Microscopy Basics
nav_order: 10
---

# Microscopy Basics

Biomedical microscopy comprises an increasing diversity of imaging methods that differ in how a sample is
illuminated and data collected. Classical methods such as transmission light microscopy and epifluorescence
microscopy have been joined more recently by structured illumination<sup>1</sup> and light-sheet microscopy<sup>2</sup>, as well as by
non-optical methods that generate images using mass spectrometers<sup>3</sup>. What is common to all of these methods
is that they generate data that can be represented as a series of intensity values on a two-dimensional raster –
i.e. an image. Three-dimensional data is commonly represented as a stack of images along the Z axis (which is
parallel to the objective lens in most cases) and multi-spectral data is represented as a series of images of the
same plane at different excitation and emission wavelengths. Time is yet another data dimension that is
commonly represented as a series of images (a movie).

The TIFF (Tagged Image File Format) is ideal for storing microscopy data at native resolution because it can
combine multiple images in a single file (with each image occupying a separate layer in the file). Thus, a 3D
multi-wavelength movie potentially containing hundreds of image planes can be stored in one TIFF file. TIFF files
also contain metadata in the header that describes the organization and key properties of the images. For
biomedical data, the [Open Microscopy Environment](https://www.openmicroscopy.org/ome-files/) (OME) TIFF format has become the most widely used
standard for XML-based metadata and raster images. Because different vendors also have their own internal
data standards, [Bio-Formats](https://www.openmicroscopy.org/bio-formats/) software was developed by the OME community to convert proprietary formats
into a standardized, open format, most recently [OME-TIFF 6.0](https://docs.openmicroscopy.org/ome-model/6.0.1/ome-tiff/). This is a pyramid-encoded TIFF in which multiple
resolutions of the same image are found in a single file to enable rapid pan and zoom, particularly using web
tools (e.g. Google Maps). Many microscope vendors support Bio-Formats and this is therefore the standard
supported by MCMICRO and other image processing software developed by the LSP.

The key properties of any imaging system are resolution, speed/sensitivity, wavelength and field of view. In the
case of tissue imaging, it is usually desirable to work at a resolution sufficient for subcellular structures to be
resolved; this corresponds to ~0.4 µm, which can be achieved using an objective lens having a numerical
aperture of ~0.8 (see [MicroscopyU](https://www.microscopyu.com/microscopy-basics/resolution) for details).
Under these circumstances, even scientific grade megapixel
cameras cannot collect all of the data from a large tissue specimen (which may measure up to 2cm x 2cm). Thus,
data acquisition commonly involves dividing the image into tiles – up to 1,000 tiles, each a multi-dimensional
TIFF, in the case of large specimens - which are then recorded sequentially by moving the microscope stage in X
and Y (such a microscope is often called a “scanner”). A complete image is assembled by “stitching” together
images tiles from each X,Y coordinate, while also “registering” images from each tile for all available
wavelengths. The stitching and registration process is not straightforward and we have developed the [ASHLAR](https://github.com/labsyspharm/ashlar) tool for this purpose.

Microscope illumination is rarely stable over the time periods required to collect a large number of image tiles
(and the illumination of each tile is also not perfectly uniform). Thus, after images are stitched and registered
they are subjected to illumination correction and “flat fielding” to generate a homogenous complete image
measuring up to 50,000 x 50,000 pixels and multiple wavelengths. For some image processing steps it is
necessary to divide the image up into smaller pieces; this is done using the fully stitched and registered image so
that the primary data maintain the best possible alignment in space and wavelength.

The OME community is welcoming and it has many on-line resources that discuss the topics described above in
much greater detail. OME also sponsors multiple workshops and conferences of interest to new and
experienced microscopists.

---

1. Wu, Yicong, and Hari Shroff. "Faster, sharper, and deeper: structured illumination microscopy for biological imaging." Nature methods 15.12 (2018): 1011-1019.
1. Power, Rory M., and Jan Huisken. "A guide to light-sheet fluorescence microscopy for multiscale imaging." Nature methods 14.4 (2017): 360-373.
1. Angelo, Michael, et al. "Multiplexed ion beam imaging of human breast tumors." Nature medicine 20.4 (2014): 436-442.


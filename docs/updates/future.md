---
layout: default
title: Future development
nav_order: 2
parent: Updates

---

# Areas for future development
## 3D Image Processing
Currently, high-plex tissue imaging of 3D samples remains rare. Most published 3D studies use stacks of images spaced along the Z axis (parallel to the objective lens). In live-cells studies, time is also captured by a series of images to create a movie. MCMICRO can manage 3D image stacks, however, specialized viewers are required to look at the data. In preclinical settings, there has been much effort to develop more effective ways to sample 3D data. The most common methods acquire data directly in 3D data without the need for physical sectioning, methods such as optical deconvolution microscopy [(Sibarita et al., 2005)](https://doi.org/10.1007/b102215){:target="_blank"}, confocal microscopy, and fluorescent light sheet microscopy (LSFM) [(Power et al., 2017)](https://doi.org/10.1038/nmeth.4224){:target="_blank"}. LSFM is particularly valuable for tissue imaging because samples can be up to several hundred microns thick. These 3D sample compatible high-resolution microscopes are not yet commonly used for high-plex tissue imaging, but we expect their rapid uptake over the next few years. For this reason, we are working to add true 3D capability to MCMICRO.

## Image segmentation
Image segmentation is currently one of the most challenging steps in single-cell analysis of tissue images. Computationally, image segmentation assigns class labels to an image in a pixel-wise manner to optimally subdivide it. Extensive efforts have helped master cell segmentation for *in vitro*, 2-D cultures of cells, but segmenting cells within dense tissue samples is substantially more complex: cell sizes and shapes are more diverse in tissues, and cells are often closely packed. Deep learning methods have become standard in image segmentation, object detection, and synthetic image generation19, based on architectures such as ResNet [(He et al., 2015)](https://doi.org/10.48550/arXiv.1512.03385){:target="_blank"}, UNet [(Ronnenberger et al., 2015)](https://doi.org/10.48550/arXiv.1505.04597){:target="_blank"}, and Mask R-CNN [(He et al., 2018)](https://doi.org/10.48550/arXiv.1703.06870){:target="_blank"}. UNet in particular has become popular due to its ease of deployment on Graphical Processing Units (GPUs) and its superior performance. MCMICRO provides access to all of these architectures as a standard feature. It is always necessary to examine an overlay of primary image data and segmentation mask to make sure that images are not over or under segmented.



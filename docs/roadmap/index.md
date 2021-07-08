---
layout: default
title: Roadmap
nav_order: 30
has_children: true
---

# Current Modules

| Name | Purpose | Parameters | URLs |
| :-- | :-- | :-- | :-- |
| BaSiC | Illumination correction | [Reference](https://github.com/labsyspharm/basic-illumination#running-as-a-docker-container) | [Code](https://github.com/labsyspharm/basic-illumination) - [DOI](https://doi.org/10.1038/ncomms14836) |
| ASHLAR | Stitching and registration | [Reference](https://github.com/labsyspharm/ashlar#usage) | [Code](https://github.com/labsyspharm/ashlar) - [DOI](https://doi.org/10.1101/2021.04.20.440625) |
| Coreograph | TMA dearraying | [Reference](https://github.com/HMS-IDAC/UNetCoreograph/blob/master/README.md) - [Guide](../tuning/coreograph.html) | [Code](https://github.com/HMS-IDAC/Coreograph) - [DOI](https://www.biorxiv.org/content/10.1101/2021.03.15.435473) |
| UnMICST | Probability map generator | [Reference](../documentation/parameter-reference.html#arguments-to-unmicst--unmicst-opts) - [Guide](../tuning/unmicst.html) | [Code](https://github.com/HMS-IDAC/UnMicst) - [DOI](https://doi.org/10.1101/2021.04.02.438285) |
| Ilastik | Probability map generator | [Reference](../documentation/parameter-reference.html#arguments-to-ilastik--ilastik-opts) | [Code](https://github.com/labsyspharm/mcmicro-ilastik) - [DOI](https://doi.org/10.1038/s41592-019-0582-9) |
| Cypository | Probability map generator (cytoplasm only) | [Reference](https://github.com/HMS-IDAC/Cypository#cypository---pytorch-mask-rcnn-for-cell-segmentation) | [Code](https://github.com/HMS-IDAC/Cypository) |
| S3segmenter | Watershed segmentation | [Reference](../documentation/parameter-reference.html#arguments-to-s3segmenter--s3seg-opts) - [Guide](../tuning/s3seg.html) | [Code](https://github.com/HMS-IDAC/S3segmenter) - [DOI](https://www.biorxiv.org/content/10.1101/2021.03.15.435473) |
| mcquant | Single cell quantification | [Reference](https://github.com/labsyspharm/quantification#single-cell-quantification) | [Code](https://github.com/labsyspharm/quantification) - [DOI](https://www.biorxiv.org/content/10.1101/2021.03.15.435473) |
| naivestates | Cell type calling | [Reference](https://github.com/labsyspharm/naivestates#basic-usage) | [Code](https://github.com/labsyspharm/naivestates) |
| FastPG | Cell type calling | [Reference](https://github.com/labsyspharm/celluster#parameter-reference) | [Code](https://github.com/labsyspharm/celluster) - [DOI](https://www.biorxiv.org/content/10.1101/2020.06.19.159749v2) |
| SCIMAP | Cell type calling | [Reference](https://scimap.xyz) - [Guide](https://scimap.xyz/tutorials/1-scimap-tutorial-getting-started.html) | [Code](https://github.com/ajitjohnson/scimap/) |

# Coming soon

* Mesmer - [Reference](https://doi.org/10.1101/2021.03.01.431313)
* Cellpose - [Reference](https://www.nature.com/articles/s41592-020-01018-x)
* GPU-enabled Phenograph - [Reference](https://doi.org/10.1016/j.cell.2015.05.047)

Additional module development and evaluation will be enabled through future hackathons hosted by the Cancer Systems Biology Consortium (CSBC).

# Suggest a module

Module suggestions can be made by posting to [https://forum.image.sc/](https://forum.image.sc/) and tagging your post with the `mcmicro` tag.

# Add a module

MCMICRO allows for certain module types to be specified dynamically through a configuration file. If you already have a containerized method with a command-line interface, follow [our instructions](adding.html) to incorporate your module into the pipeline.

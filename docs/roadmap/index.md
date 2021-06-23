---
layout: default
title: Roadmap
nav_order: 30
has_children: true
---

# Current Modules

| Name | Purpose | URLs |
| :-- | :-- | :-- |
| BaSiC | Illumination correction | [Code](https://github.com/labsyspharm/basic-illumination) - [Reference](https://doi.org/10.1038/ncomms14836) |
| ASHLAR | Stitching and registration | [Code](https://github.com/labsyspharm/ashlar) - [Reference](https://doi.org/10.1101/2021.04.20.440625) |
| Coreograph | TMA dearraying | [User Guide](../documentation/coreograph.html) - [Code](https://github.com/HMS-IDAC/Coreograph) - [Reference](https://www.biorxiv.org/content/10.1101/2021.03.15.435473) |
| UnMICST | Probability map generator | [User Guide](../documentation/unmicst.html) - [Code](https://github.com/HMS-IDAC/UnMicst) - [Reference](https://doi.org/10.1101/2021.04.02.438285) |
| Ilastik | Probability map generator | [Code](https://github.com/labsyspharm/mcmicro-ilastik) - [Reference](https://doi.org/10.1038/s41592-019-0582-9) |
| Cypository | Probability map generator (cytoplasm only) | [Code](https://github.com/HMS-IDAC/Cypository) |
| S3segmenter | Watershed segmentation | [User Guide](../documentation/s3seg.html) - [Code](https://github.com/HMS-IDAC/S3segmenter) |
| mcquant | Single cell quantification | [Code](https://github.com/labsyspharm/quantification) |
| naivestates | Cell type calling | [Code](https://github.com/labsyspharm/naivestates) |
| SCIMAP | Cell type calling | [User Guide](https://scimap.xyz/) - [Code](https://github.com/ajitjohnson/scimap/) |

# Coming soon

* Mesmer - [Reference](https://doi.org/10.1101/2021.03.01.431313)
* Phenograph - [Reference](https://doi.org/10.1016/j.cell.2015.05.047)

Additional module development and evaluation will be enabled through future hackathons hosted by the Cancer Systems Biology Consortium (CSBC).

# Suggest a module

Module suggestions can be made by posting to [https://forum.image.sc/](https://forum.image.sc/) and tagging your post with the `mcmicro` tag.

# Add a module

MCMICRO allows for certain module types to be specified dynamically through a configuration file. If you already have a containerized method with a command-line interface, follow [our instructions](adding.html) to incorporate your module into the pipeline.

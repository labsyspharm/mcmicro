---
layout: default
title: TMA dearray
nav_order: 33
parent: Image Processing Steps
has_children: true
---

## (Optional) TMA dearray

When working with Tissue Microarrays (TMA), the `registration/` folder will contain an image of the entire TMA. Use the `--tma` flag during [pipeline execution](running-mcmicro.html) to have mcmicro identify and isolate individual core. Each core will be written out into a standalone file in the `dearray/` subdirectory along with its mask specifying where in the original image the core appeared:

```
exemplar-002
├── ...
├── registration/
│   └── exemplar-002.ome.tiff
└── dearray/
    ├── 1.tif
    ├── 2.tif
    ├── 3.tif
    ├── 4.tif
    └── masks/
        ├── 1_mask.tif
        ├── 2_mask.tif
        ├── 3_mask.tif
        └── 4_mask.tif
```

All cores will then be processed in parallel by all subsequent steps.
In MCMICRO, TMA dearraying is performed by Coreograph.

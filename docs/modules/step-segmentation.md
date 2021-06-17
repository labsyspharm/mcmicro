---
layout: default
title: Segmentation
nav_order: 34
parent: Modules
has_children: true
---

# Segmentation

Cell segmentation is carried out in two steps. First, the pipeline generates probability maps that annotate each pixel with the probability that it belongs to a given subcellular component (nucleus, cytoplasm, cell boundary). The second step applies standard watershed segmentation to produce the final cell/nucleus/cytoplasm/etc. masks. The two steps will appear in `probability-maps/` and `segmentation` directories, respectively. When there are multiple modules for a given pipeline step, their results will be subdivided into additional subdirectories:

```
exemplar-001
├── ...
├── probability-maps/
│   ├── ilastik/
│   │   └── exemplar-001_Probabilities.tif
│   └── unmicst/
│       └── exemplar-001_Probabilities_0.tif
└── segmentation/
    ├── ilastik-exemplar-001/
    │   ├── cellMask.tif
    │   └── nucleiMask.tif
    └── unmicst-exemplar-001/
        ├── cellMask.tif
        └── nucleiMask.tif
```


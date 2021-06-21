---
layout: default
title: Quantification
nav_order: 38
parent: Step by Step
---

# Quantification

The final step combines information in segmentation masks, the original stitched image and `markers.csv` to produce *Spatial Feature Tables* that summarize the expression of every marker on a per-cell basis, alongside additional morphological features (cell shape, size, etc.). Spatial Feature Tables will be published to the `quantification/` directory:

```
exemplar-001
├── ...
├── segmentation/
└── quantification/
    ├── ilastik-exemplar-001.csv
    └── unmicst-exemplar-001.csv
```

There is a direct correspondence between colunn name suffixes in the `.csv` files and the filenames of segmentation masks. For example, the column `CD357_cellMask` in `quantification/unmicst-exemplar-001.csv` quantifies the expression of `CD357` that was computed over `segmentation/unmicst-exemplar-001/cellMask.tif`. Similarly, `FDX1_nucleiMask` quantified the expression of `FDX1` computed over `segmentation/unmicst-exemplar-001/nucleiMask.tif`.


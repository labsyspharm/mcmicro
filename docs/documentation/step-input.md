---
layout: default
title: Input
nav_order: 31
parent: Step by Step
---

# Raw data
At the very minimum, the pipeline expects `markers.csv`, containing metadata about markers, in the parent directory and raw images in the `raw/` subdirectory.
The file `markers.csv` must be in a comma-delimited format and contain a column titled `marker_name` that defines marker names of every channel:

```
cycle,marker_name
1,DNA_1
1,AF488
1,AF555
1,AF647
2,DNA_2
2,A488_background
2,A555_background
2,A647_background
3,DNA_3
3,FDX1
3,CD357
3,CD1D
```

All other columns are optional but can be used to specify additional metadata (e.g., known mapping to cell types) to be used by individual modules.

The exemplar `raw/` files are in the open standard OME-TIFF format, but in practice your input files will be in whatever format your microscope produces. The pipeline supports all [Bio-Formats-compatible](https://docs.openmicroscopy.org/bio-formats/6.0.1/supported-formats.html) image formats.


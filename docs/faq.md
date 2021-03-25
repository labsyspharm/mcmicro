---
layout: default
title: FAQ
nav_order: 9
---

# Frequently Asked Questions

## Pre-processing

### Q: How does mcmicro handle multi-file formats such as `.xdce`?

A: Registration and illumination correction modules in mcmicro are [Bio-Formats compatible](https://docs.openmicroscopy.org/bio-formats/6.0.1/supported-formats.html). Place all files into the `raw/` subdirectory, as described in [Directory Structure](directory-structure.html), and mcmicro modules will correctly identify and use the relevant ones.

## Segmentation

### Q: How do I run mcmicro with own ilastik model

A: Use the `--ilastik-model` parameter. Note that the parameter must be specified *outside** `--ilastik-opts`. For example,

```
nextflow run labsyspharm/mcmicro --in /my/data --probability-maps ilastik --ilastik-model mymodel.ilp
```

### Q: How do I check the quality of segmentation?

A: After a successful mcmicro run, two-channel tif files containing DAPI and nuclei/cell/cytoplasm outlines will reside in `qc/s3seg`. Segmentation quality can be assessed through visual inspection of these files in, e.g., [napari](https://napari.org/).



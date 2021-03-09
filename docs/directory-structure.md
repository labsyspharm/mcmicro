---
layout: default
title: Directory Structure
nav_order: 4
---

# Directory structure

Exemplar datasets demonstrate the directory structure expected by mcmicro:

```
exemplar-001
├── markers.csv
├── raw
│   ├── exemplar-001-cycle-01.ome.tiff
│   ├── exemplar-001-cycle-02.ome.tiff
│   └── exemplar-001-cycle-03.ome.tiff
└── illumination
    ├── exemplar-001-cycle-01-dfp.tif
    ├── exemplar-001-cycle-01-ffp.tif
    ├── exemplar-001-cycle-02-dfp.tif
    ├── exemplar-001-cycle-02-ffp.tif
    ├── exemplar-001-cycle-03-dfp.tif
    └── exemplar-001-cycle-03-ffp.tif
```

The name of the parent directory (e.g., `exemplar-001`) is assumed by the pipeline to be the sample name.
At the very minimum, the pipeline expects `markers.csv`, containing metadata about markers, in the parent directory and raw images in the `raw/` subdirectory.
The file `markers.csv` must have at least three columns that define marker names for each channel in each cycle:

```
channel_number,cycle_number,marker_name
1,1,DNA_1
2,1,AF488
3,1,AF555
4,1,AF647
5,2,DNA_2
6,2,A488_background
7,2,A555_background
8,2,A647_background
9,3,DNA_3
10,3,FDX1
11,3,CD357
12,3,CD1D
```

Additional columns are optional but can be used to specify additional metadata (e.g., excitation and emissions wavelengths) to be used by individual modules.

The exemplar `raw/` files are in the open standard OME-TIFF format, but in practice your input files will be in whatever format your microscope produces. The pipeline supports all [Bio-Formats-compatible](https://docs.openmicroscopy.org/bio-formats/6.0.1/supported-formats.html) image formats.

## (Optional) Illumination correction

Precomputed flat-field and dark-field illumination profiles must be places in the `illumination/ directory`. If no precomputed profiles are available, mcmicro can compute these using [BaSiC](https://www.nature.com/articles/ncomms14836). This step is not executed by default, because proper illumination correction requires careful curation and visual inspection of the profiles produced by computational tools. After familiarizing yourself with the general concepts [ [1](https://emsis.eu/olh/HTML/topics_glossary_tem_shading_correction.html), [2](https://en.wikipedia.org/wiki/Flat-field_correction) ], the profiles can be computed by specifying `--start-at illumination` during [pipeline execution](running-mcmicro.html).

## Stitching and registration

The first step of the pipeline will aggregate individual image tiles in `raw/` along with the corresponding illumination profiles to produce a stitched and registered image, which will be published to the `registration/` subdirectory:

```
exemplar-001
├── markers.csv
├── raw
├── illumination
└── registration
    └── exemplar-001.ome.tif
```

The output filename will be generated based on the name of the project directory.

## (Optional) TMA dearray

When working with Tissue Microarrays (TMA), the `registration/` folder will contain an image of the entire TMA. Use the `--tma` flag during [pipeline execution](running-mcmicro.html) to have mcmicro identify and isolate individual core. Each core will be written out into a standalone file in the `dearray/` subdirectory along with its mask specifying where in the original image the core appeared:

```
exemplar-002
├── ...
├── registration
│   └── exemplar-002.ome.tiff
└── dearray
    ├── 1.tif
    ├── 2.tif
    ├── 3.tif
    ├── 4.tif
    └── masks
        ├── 1_mask.tif
        ├── 2_mask.tif
        ├── 3_mask.tif
        └── 4_mask.tif
```

All cores will then be processed in parallel by all subsequent steps.

## Segmentation

Cell segmentation is carried out in two steps. First, the pipeline generates probability maps that annotate each pixel with the probability that it belongs to a given subcellular component (nucleus, cytoplasm, cell boundary). The second step applies standard watershed segmentation to produce the final cell/nucleus/cytoplasm/etc. masks. The two steps will appear in `probability-maps/` and `segmentation` directories, respectively. When there are multiple modules for a given pipeline step, their results will be subdivided into additional subdirectories:

```
exemplar-001
├── ...
├── registration
│   └── exemplar-001.ome.tiff
├── probability-maps
│   ├── ilastik
│   │   └── exemplar-001_Probabilities.tif
│   └── unmicst
│       └── exemplar-001_Probabilities_0.tif
└── segmentation
    ├── ilastik-exemplar-001
    │   ├── cellMask.tif
    │   └── nucleiMask.tif
    └── unmicst-exemplar-001
        ├── cellMask.tif
        └── nucleiMask.tif
```

## Quantification

The final step combines information in segmentation masks, the original stitched image and `markers.csv` to produce *Spatial Feature Tables* that summarize the expression of every marker on a per-cell basis, alongside additional morphological features (cell shape, size, etc.). Spatial Feature Tables will be published to the `quantification/` directory:

```
exemplar-001
├── ...
├── segmentation
│   └── ...
└── quantification
    ├── ilastik-exemplar-001.csv
    └── unmicst-exemplar-001.csv
```

## Quality control

Additional information during pipeline execution will be written to the `qc/` directory, by both individual modules and the pipeline itself.

```
exemplar-002
├── ...
└── qc
    ├── params.yml
    ├── provenance
    │   ├── probmaps:ilastik (1).log
    │   ├── probmaps:ilastik (1).sh
    │   ├── probmaps:unmicst (1).log
    │   ├── probmaps:unmicst (1).sh
    │   ├── quantification (1).log
    │   ├── quantification (1).sh
    │   ├── quantification (2).log
    │   ├── quantification (2).sh
    │   ├── registration:ashlar.log
    │   ├── registration:ashlar.sh
    │   ├── segmentation:s3seg (1).log
    │   ├── segmentation:s3seg (1).sh
    │   ├── segmentation:s3seg (2).log
    │   └── segmentation:s3seg (2).sh
    ├── s3seg
    │   └── ...
    └── unmicst
        └── ...
```

While the exact content of the `qc/` directory will depend on which modules were executed, two sources of information can always be found there:

1. The file `params.yml` will contain the full record of module versions and all parameters used to run the pipeline. This allows for full reproducibility of future runs.
1. The `provenance/` subdirectory will contain exact commands (`.sh`) executed by individual modules, as well the output (`.log`) of these commands.

The remaining directories will contain QC files specific to individual modules:

1. When working with TMAs, `coreo/` will contain `TMA_MAP.tif`, a mask showing where in the original TMA image the segmented cores reside.
1. If UnMicst was used to generate probability maps, `unmicst/` will contain thumbnail previews, allowing for a quick assessment of their quality.
1. After segemntation, two-channel tif files containing DAPI and nuclei/cell/cytoplasm outlines will reside in `s3seg/`, allowing for a visual inspection of segmentation quality.

After sufficient quality of the outputs has been established and no more parameter tuning is expected, the QC files can be safely deleted. It is recommended to retain `params.yml` and `provenance/` because of their relatively small file size, given that these files enable full reproducibility of a pipeline run.

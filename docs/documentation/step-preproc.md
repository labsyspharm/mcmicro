---
layout: default
title: Pre-processing
nav_order: 32
parent: Step by Step
---

# (Optional) Illumination correction

```
exemplar-001
├── markers.csv
├── raw/
└── illumination/
    ├── exemplar-001-cycle-01-dfp.tif
    ├── exemplar-001-cycle-01-ffp.tif
    ├── exemplar-001-cycle-02-dfp.tif
    ├── exemplar-001-cycle-02-ffp.tif
    ├── exemplar-001-cycle-03-dfp.tif
    └── exemplar-001-cycle-03-ffp.tif
```

Precomputed flat-field and dark-field illumination profiles must be places in the `illumination/ directory`. If no precomputed profiles are available, mcmicro can compute these using [BaSiC](https://www.nature.com/articles/ncomms14836). This step is not executed by default, because proper illumination correction requires careful curation and visual inspection of the profiles produced by computational tools. After familiarizing yourself with the general concepts [ [1](https://emsis.eu/olh/HTML/topics_glossary_tem_shading_correction.html), [2](https://en.wikipedia.org/wiki/Flat-field_correction) ], the profiles can be computed by specifying `--start-at illumination` during [pipeline execution](running-mcmicro.html).

# Stitching and registration

The first step of the pipeline will aggregate individual image tiles in `raw/` along with the corresponding illumination profiles to produce a stitched and registered image, which will be published to the `registration/` subdirectory:

```
exemplar-001
├── markers.csv
├── raw/
├── illumination/
└── registration/
    └── exemplar-001.ome.tif
```

The output filename will be generated based on the name of the project directory.

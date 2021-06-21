---
layout: default
title: QC
nav_order: 39
parent: Step by Step
---

# Quality control

Additional information during pipeline execution will be written to the `qc/` directory, by both individual modules and the pipeline itself.

```
exemplar-002
├── ...
└── qc
    ├── params.yml
    ├── provenance/
    │   ├── probmaps:ilastik (1).log
    │   ├── probmaps:ilastik (1).sh
    │   ├── probmaps:unmicst (1).log
    │   ├── probmaps:unmicst (1).sh
    │   ├── quantification (1).log
    │   ├── quantification (1).sh
    │   └── ...
    ├── coreo/
    ├── s3seg/
    └── unmicst/
```

While the exact content of the `qc/` directory will depend on which modules were executed, two sources of information can always be found there:

1. The file `params.yml` will contain the full record of module versions and all parameters used to run the pipeline. This allows for full reproducibility of future runs.
1. The `provenance/` subdirectory will contain exact commands (`.sh`) executed by individual modules, as well the output (`.log`) of these commands.

The remaining directories will contain QC files specific to individual modules:

1. When working with TMAs, `coreo/` will contain `TMA_MAP.tif`, a mask showing where in the original TMA image the segmented cores reside.
1. If UnMicst was used to generate probability maps, `unmicst/` will contain thumbnail previews, allowing for a quick assessment of their quality.
1. After segmentation, two-channel tif files containing DAPI and nuclei/cell/cytoplasm outlines will reside in `s3seg/`, allowing for a visual inspection of segmentation quality.

After sufficient quality of the outputs has been established and no more parameter tuning is expected, the QC files can be safely deleted. It is recommended to retain `params.yml` and `provenance/` because of their relatively small file size, given that these files enable full reproducibility of a pipeline run.

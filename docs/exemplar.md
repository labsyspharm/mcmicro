# Exemplar data

Two exemplars are currently available for demonstration purposes:

* `exemplar-001` is meant to serve as a minimal reproducible example for running all modules of the pipeline, except the dearray step. The exemplar consists of a small lung adenocarcinoma specimen taken from a larger TMA (tissue microarray), imaged using CyCIF with three cycles. Each cycle consists of six four-channel image tiles, for a total of 12 channels. Because the exemplar is small, illumination profiles were precomputed from the entire TMA and included with the raw images.

* `exemplar-002` is a two-by-two cut-out from a TMA. The four cores are two meningioma tumors, one GI stroma tumor, and one normal colon specimen. The exemplar is meant to test the dearray step, followed by processing of all four cores in parallel.

Both exemplars can be downloaded using the following commands:
``` bash
nextflow run labsyspharm/mcmicro-nf/exemplar.nf --name exemplar-001 --path /local/path/
nextflow run labsyspharm/mcmicro-nf/exemplar.nf --name exemplar-002 --path /local/path/
```
with `/local/path/` pointing to a local directory where the exemplars should be downloaded to.

## O2 notes

When working with exemplars on O2, please download your own copy to `/n/scratch2/$USER/` (where `$USER` is your eCommons ID). A fully processed version is available in `/n/groups/lsp/cycif/exemplars`, but this version is meant to serve as a reference only. The directory permissions are set to read-only, preventing your pipeline run from writing its output there.

## Directory structure

The exemplars demonstrate the directory structure assumed by the pipeline:
```
exemplar-001
├── illumination
│   ├── exemplar-001-cycle-01-dfp.tif
│   ├── exemplar-001-cycle-01-ffp.tif
│   ├── exemplar-001-cycle-02-dfp.tif
│   ├── exemplar-001-cycle-02-ffp.tif
│   ├── exemplar-001-cycle-03-dfp.tif
│   └── exemplar-001-cycle-03-ffp.tif
├── markers.csv
└── raw
    ├── exemplar-001-cycle-01.ome.tiff
    ├── exemplar-001-cycle-02.ome.tiff
    └── exemplar-001-cycle-03.ome.tiff
```

An important set of assumptions to keep in mind:

* The name of the parent directory (e.g., `exemplar-001`) is taken to be the sample name.
* The pipeline can work with either raw images that still need to be stitched, or a pre-stitched image.
  * Raw images must be placed inside `raw/` subdirectory.
  * A prestitched image must be placed inside `registration/` subdirectory.
* (Optional) Any precomputed illumination profiles must be placed in `illumination/`
* The order of markers in `markers.csv` must follow the channel order.

---
layout: default
title: FAQ
nav_order: 1
parent: Troubleshooting
---

# Frequently Asked Questions

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

## Pipeline execution

### Q: How do I resume a pipeline run that halted partway?

The intermediate files in the `work/` directory allow you to restart a pipeline partway, without re-running everything from scratch. For example, consider the following scenario:

``` bash
# This run will fail because --some-invalid-arg is not a valid argument for UnMicst
nextflow run labsyspharm/mcmicro --in ~/data/exemplar-001 --unmicst-opts '--some-invalid-arg'

N E X T F L O W  ~  version 21.10.6
Launching `labsyspharm/mcmicro` [wise_pasteur] - revision: bdfd39da0e [master]
executor >  local (2)
[-        ] process > illumination                    -
[64/0cb43c] process > registration:ashlar             [100%] 1 of 1 ✔
[-        ] process > dearray:coreograph              -
[fe/f60c41] process > segmentation:worker (unmicst-1) [100%] 1 of 1, failed: 1 ✘
[-        ] process > segmentation:s3seg              -
[-        ] process > quantification:mcquant          -
[-        ] process > cellstates:worker               -


# Address the issue by removing the invalid argument and restart the pipeline with -resume
nextflow run labsyspharm/mcmicro --in ~/data/exemplar-001 -resume

N E X T F L O W  ~  version 21.10.6
Launching `labsyspharm/mcmicro` [reverent_cori] - revision: bdfd39da0e [master]
executor >  local (3)
[-        ] process > illumination                    -
[64/0cb43c] process > registration:ashlar             [100%] 1 of 1, cached: 1 ✔  # <-- NOTE: Cached
[-        ] process > dearray:coreograph              -
[61/d7614c] process > segmentation:worker (unmicst-1) [100%] 1 of 1 ✔
[6b/06cd6b] process > segmentation:s3seg (1)          [100%] 1 of 1 ✔
[5a/d17d36] process > quantification:mcquant (1)      [100%] 1 of 1 ✔
[-        ] process > cellstates:worker               -
```

As you run the pipeline on your datasets, the size of the `work/` directory can grow substantially. Use [nextflow clean](https://github.com/nextflow-io/nextflow/blob/cli-docs/docs/cli.rst#clean) to selectively remove portions of the work directory. Use `-n` flag to list which files will be removed, inspect the list to ensure that you don't lose anything important, and repeat the command with `-f` to actually remove the files:

``` bash
# Remove work files associated with most-recent run
nextflow clean -n last           # Show what will be removed
nextflow clean -f last           # Proceed with the removal

# Remove all work files except those associated with the most-recent run
nextflow clean -n -but last
nextflow clean -f -but last
```
### Q: My computer has an Apple M1 chip and the pipeline is failing at the Segmentation step. What can I do?

A: You can use ilastik for probability map generation instead. To do so, add `segmentation: ilastik` to the [workflow parameters]({{site.baseurl}}/parameters/) in your `params.yml`:

``` yaml
workflow:
  segmentation: ilastik
```

This is because UnMICST (`segmentation:worker (unmicst-1)`) currently does not work on the M1 architecture. Fortunately, ilastik is supported by M1. See [GitHub Issue #353](https://github.com/labsyspharm/mcmicro/issues/353) for more details.

*If you came here from Step 3 in Tutorials, head back to [Tutorials](../tutorial/tutorial.html) to finish the rest of the steps!*

### Q: MCMICRO doesn't seem to recognize my file format. How do I tell it what files to look for?

A: By default, MCMICRO looks for a small number of image formats that we have verified to work. In principle, MCMICRO can be applied to any [Bio-Formats compatible](https://docs.openmicroscopy.org/bio-formats/6.0.1/supported-formats.html) images. We make a distinction between images stored as single files (e.g., `.png`) and those stored as an index file that points to other files (e.g., `.xdce`, `.ndpis`, etc.). Place all image files into the `raw/` subdirectory and specify the file extension(s) to look for in [workflow parameters]({{site.baseurl}}/parameters/) of `params.yml`:

``` yaml
workflow:
  single-formats: png
```

for single-file image formats and

``` yaml
workflow:
  multi-formats: ndpis
```

for multi-file formats. Note that in the latter case, you need to specify the extension of the index file (`.ndpis` in this case) and not the individual files being indexed (`.ndpi` in this case).

### Q: My execution environment doesn't support Docker. Can I run MCMICRO using Singularity instead?

Yes, MCMICRO can be configured to use Singularity in place of Docker. Use the `-profile` flag to switch configurations:

```
nextflow run labsyspharm/mcmicro --in /my/project -profile singularity
```

## Segmentation

### Q: How do I run MCMICRO with my own Ilastik model?

A: Use the `--ilastik-model` [workflow parameter]({{site.baseurl}}/parameters/). An example `params.yml` may look as follows:

``` yaml
workflow:
  segmentation: ilastik
  ilastik-model: mymodel.ilp
```

### Q: How do I check the quality of segmentation?

A: After a successful MCMICRO run, two-channel tif files containing DAPI and nuclei/cell/cytoplasm outlines will reside in `qc/s3seg`. Segmentation quality can be assessed through visual inspection of these files in, e.g., [napari](https://napari.org/).

### Q: How do I handle images acquired without pixel binning?

![]({{ site.baseurl }}/images/FAQ-binning.png)

A: There are two adjustments to make:

1. Adjust `--scalingFactor` for UnMicst, which controls the ratio of the current pixel width (W2) to exemplar pixel width (W1) and is not related to area (See schematic).
1. In S3Segmenter, `--cytoDilation` controls the number of pixels from the edge of the nucleus to expand in creating the cytoplasm mask. Take the value optimized for 2x binned images and multiply it by 2 (i.e., if `--cytoDilation 3` is optimal for 2x binning, then the new value will `--cytoDilation 6`).

Use `unmicst` and `s3seg` [module options]({{site.baseurl}}/parameters/) to pass the new values to UnMicst and S3Segmenter, respectively. An example `params.yml` may look as follows:

``` yaml
options:
  unmicst: --scalingFactor 0.5
  s3seg: --cytoDilation 6
```

## Quantification

### Q: How do I quantify multiple masks?

A: Use `mcquant` [module options]({{site.baseurl}}/parameters/) to specify the `--masks` parameter for quantification. Any file found in the corresponding `segmentation/` folder can be provided here. For example,

``` yaml
options:
  mcquant: --masks cell.ome.tif nuclei.ome.tif
```

will quantify cell and nuclei masks. The corresponding spatial feature tables can then be found in `quantification/unmicst-exemplar-001_cell.csv` and `quantification/unmicst-exemplar-001_nuclei.csv`, respectively.

### Q: How do I compute the median expression of each channel?

A: Use `mcquant` [module options]({{site.baseurl}}/parameters/) to specify the corresponding `--intensity_props` parameter for quantification:

``` yaml
options:
  mcquant: --intensity_props median_intensity
```

### Q: What are the units of the MCMICRO `Area` outputs?

A: `Area` is in pixels.
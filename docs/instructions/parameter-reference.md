---
layout: default
title: Parameter reference
nav_order: 26
parent: How to Use
---

# Parameter reference

## Parameters controlling the pipeline behavior

The following parameters control the pipeline as a whole. The details below correspond to the Nextflow usage - Galaxy usage will be similar, but through the GUI interface. These can be specified on the command line using the double-dash format (e.g., `--in`), or inside a YAML file as key-value pairs. Parameters that don't require an explicit value because their presence controls the behavior (e.g., `--tma`) should instead be assigned to `true` in the YAML file. For example,

Example: `nextflow run labsyspharm/mcmicro --in /my/data --tma`

or equivalently: `nextflow run labsyspharm/mcmicro -params-file myparams.yml`, where `myparams.yml` contains
```
in: /my/data
tma: true
```

### Required parameters:

| Parameter | Description |
| --- | --- |
| `--in /local/path` | Location of the data |

### Optional parameters:

| Parameter | Default | Description |
| --- | --- | --- |
| `--sample-name <myname>` | Directory name supplied to `--in` | The name of the experiment/specimen |
| `--start-at <step>` | `registration` | Name of the first step to be executed by the pipeline. Must be one of `illumination`, `registration`, `dearray` (TMA only), `probability-maps`, `segmentation`, `quantification`, `cell-states` |
| `--stop-at <step>` | `quantification` | Name of the final step to be executed by the pipeline. Spans the same vocabulary as `--start-at`. |
| `--tma` | Omitted | If specified, mcmicro treats input data as a TMA. If omitted, the input is assumed to be a whole-slide image. |
| `--ilastik-model <model.ilp>` | None | A custom `.ilp` file to be used as the classifier model for ilastik. |
| `--probability-maps <choice>` | `unmicst` | Which module(s) to use for probability map computation. Must be one of `unmicst`, `ilastik`, `all` (`unmicst` AND `ilastik`), and `cypository` for cytoplasm segmentation |

## Parameters for individual modules

Module-specific parameters can be specified using the various `opts` arguments, followed by the parameters enclosed inside single quotes `'`:

Example 1: `nextflow run labsyspharm/mcmicro --in /my/data --ashlar-opts '-m 30 --pyramid'`

Example 2: `nextflow run labsyspharm/mcmicro --in /my/data --nstates-opts '--log no --plots pdf'`

Example 3: `nextflow run labsyspharm/mcmicro --in /my/data --quant-opts '--masks cytoMask.tif nucleiMask.tif'`

**Arguments to ASHLAR (`--ashlar-opts`)**

**Arguments to Coreograph(`--core-opts`)**

**Arguments to UnMicst(`--unmicst-opts`)**

**Arguments to S3Segmenter(`--s3seg-opts`)**

**Arguments to MCquant(`--quant-opts`)**

{: .text-center}
{: .fs-5}
{: .fw-600}
For more information about the parameters relevant to each MCMICRO module, see the [modules landing page]({{site.baseurl}}/modules/).





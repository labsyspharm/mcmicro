# Parameter reference

## Parameters controlling the pipeline behavior

The following parameters control the pipeline as a whole. These can be specified on the command line using the double-dash format (e.g., `--in`), or inside a YAML file as key-value pairs. Parameters that don't require an explicit value because their presence controls the behavior (e.g., `--tma`) should instead be assigned to `true` in the YAML file. For example,

Example: `nextflow run labsyspharm/mcmicro-nf --in /my/data --tma`

or equivalently: `nextflow run labsyspharm/mcmicro-nf -params-file myparams.yml`, where `myparams.yml` contains
```
in: /my/data
tma: true
```

**Mandatory parameters:**

* `--in /local/path` - specifies location of the data

**Optional parameters:**

* `--sample-name <myname>` - the name of the experiment/specimen. By default, mcmicro extracts this from the path supplied to `--in`.
* `--start-at <step>` - name of the first step to be executed by the pipeline. The value `<step>` must be one of `raw`, `illumination`, `registration`, `dearray` (TMA only), `probability-maps`, `segmentation`, `quantification`, `cell-states`. Default: `registration`.
* `--stop-at <step>` - name of the final step to be executed by the pipeline. Spans the same vocabulary as `--start-at`. Default: `cell-states`.
* `--tma` - if specified, mcmicro treats input data as a TMA. If omitted, the input is assumed to be a whole-slide image. Default: omitted.
* `--raw-formats <formats>` - one or more file formats that mcmicro should look for. Default: `{.ome.tiff,.ome.tif,.rcpnl,.xdce,.nd,.scan,.htd,.btf,.nd2,.tif,.czi}`
* `--probability-maps <unmicst|ilastik|all>` - which module(s) to use for probability map computation. Default: `unmicst`

## Parameters for individual modules

It is important to make a distinction between parameters that control behavior of individual modules, and parameters that specify which files the modules operate on. Because all file management is done at the level of the pipeline, special treatment is required for the latter set (e.g., specifying a different mask to use for quantification).

**Arguments to handle file-referencing parameters:**

* `--mask-spatial <filename>` - which segmentation mask should be used for extracting spatial features. Must be a filename produced by the s3segmenter. Default: `cellMask.tif`
* `--mask-add <filenames>` - one or more filenames referencing masks produced by the s3segmenter that should also be quantified. The filenames should be surrounded with single quotes (`'`). For example, `--mask-add 'cytoMask.tif nucleiMask.tif'`. Default: none.

**Plain arguments for individual modules:**

Parameters don't reference any files can be fed directly to each module through the `--*-opts` arguments in mcmicro:

| Module | mcmicro Argument |
| --- | --- |
| ASHLAR | `--ashlar-opts` |
| UnMicst | `--unmicst-opts` |
| S3Segmenter | `--s3seg-opts` |
| quantification | `--quant-opts` |
| naivestates | `--nstates-opts` |

Surround module parameters with single quotes `'`.
Example 1: `nextflow run labsyspharm/mcmicro-nf --in /my/data --ashlar-opts '-m 30 --pyramid'`
Example 2: `nextflow run labsyspharm/mcmicro-nf --in /my/data --nstates-opts '--log no --plots pdf'`

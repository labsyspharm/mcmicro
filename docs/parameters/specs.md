---
layout: default
title: Modifying modules (advanced)
nav_order: 50
parent: Parameters
---

# Module specifications

**Most users will not need to modify the default specifications.** 
Occasionally, a user may need to run a different version of an existing module or add another module. Both of those things can be done by specifying the corresponding fields in the `modules:` namespace of the [parameter file]({{site.baseurl}}/parameters/).

## Modifying a module version

If a module is specified as the only option for a given processing step (`illumination`, `registration`, `dearray`, `watershed`, `quantification` and `viz`), then the version should be specified directly under the corresponding step using the `version:` field. In this case, an example `params.yml` may look as follows:

``` yaml
modules:
  registration:
    version: 1.16.0
  watershed:
    version: 1.4.0-large
```

Alternatively, if a module is one of several options for a given processing step (currently only `segmentation` and `downstream`), then the version specification should also include a `name:` field to allow matching against existing modules. An example `params.yml` in this case may look as following:

``` yaml
modules:
  segmentation:
    -
      name: unmicst
      version: 2.7.3
    -
      name: mesmer
      version: 0.4.0
  downstream:
    -
      name: naivestates
      version: 1.6.2
```

When in doubt, follow the same structure as the one represented by the [default values](https://github.com/labsyspharm/mcmicro/blob/master/config/defaults.yml){:target="_blank"}.

## Adding a module

Adding a new module specification is currently only possible for `segmentation` and `downstream` processing steps.

### Input and output specs

Every module must have a command-line interface (CLI) that has been encapsulated inside a Docker container. 
MCMICRO assumes that CLI conforms to the following input-output specifications.

### Segmentation modules

**Input:**

* A file in `.ome.tif` format containing a fully stitched and registered multiplexed image.
* (Optional) A file containing a custom model for the algorithm. The file can be in any format, and it is up to the module developer to decide what formats they allow from users.

**Output:**

* An image file in `.tif` format, written to `.` (i.e., the "current working directory"). The file can be either a probability map or a segmentation mask. The image channels in probability maps annotate each pixel with probabilities that it belongs to the background or different parts of the cell such as the nucleus, cytoplasm, cell membrane or the intercellular region. Similarly, segmentation masks annotate each pixel with an integer index of the cell it belongs to, or 0 if none.
* (Optional) One or more files written to `./qc/` (i.e., `qc/` subdirectory within the "current working directory"). These will be copied by the pipeline to the corresponding location in the [project's `qc/` directory]({{ site.baseurl }}/io.html#quality-control).

### Downstream modules

**Input:**

* A file in `.csv` format containing a [spatial feature table]({{ site.baseurl }}/io.html#quantification). Each row in a table corresponds to a cell, while columns contain features characterizing marker expression or morphological properties.
* (Optional) A file containing a custom model for the algorithm. The file can be in any format, and it is up to the module developer to decide what formats they allow from users.

**Output:**

* One or more files in `.csv` or `.hdf5` format, written to `.` (i.e., the "current working directory"). Each file should annotate individual cells with the corresponding inferred cell state.
* (Optional) One or more files written to `./plots/` (i.e., `plots/` subdirectory within the "current working directory"). Each file can be in any format and contain any information that the module developer thinks will be useful to the user (e.g., UMAP plots showing how cells cluster together).
* (Optional) One or more files written to `./qc/` (i.e., `qc/` subdirectory within the "current working directory"). These will be copied by the pipeline to the corresponding location in the [project's `qc/` directory]({{ site.baseurl }}/io.html#quality-control).

# Configuration

Adding a new MCMICRO module involves specifying simple key-value pairs in the `modules:` section of `params.yml`. For example, consider the following configuration for ilastik:

``` yaml
modules:
  segmentation:
    -
      name: ilastik
      container: labsyspharm/mcmicro-ilastik
      version: 1.4.5
      cmd: python /app/mc-ilastik.py --output .
      input: --input
      model: --model
      channel: --channelIDs
      idxbase: 1
      watershed: 'yes'
```

## Name

The `name` of the module determines two things. First, it specifies the names of subdirectories for where the output files will be written to in the project directory. In the given example, the primary outputs will appear in `probability-maps/ilastik/`, while QC files will be written to `qc/ilastik/`. Second, the module name also tells MCMICRO what other parameters to look for. In our example, the pipeline will look for module specific parameters in `--ilastik-opts` and a custom model file in `--ilastik-model`.

## Container and version

The two fields must uniquely identify a Docker container image containing the tool. Mechanistically, the fields are combined using the [standard `REPOSITORY:TAG` convention](https://docs.docker.com/engine/reference/commandline/images/).

## Command

The `cmd` field must contain a command that, when executed inside the container, will produce the required set of outputs from the inputs provided to it by the pipeline.

**It is imperative that all primary outputs are written to `.` (i.e., the "current working directory"). MCMICRO will automatically sort outputs to their correct location in the project directory. Writing outputs to any other location may result in MCMICRO failing to locate them.**

## Input

The `input` field determines how the pipeline will supply inputs to the module. Some examples in the context of [exemplar-001]({{ site.baseurl }}/datasets/) may look as follows:

| Configuration | What MCMICRO will execute |
| :-- | :-- |
| <code>cmd   : 'python /app/tool.py -o .'<br>input : '-i' </code> | `python /app/tool.py -o . -i exemplar-001.ome.tif` |
| <code>cmd   : 'python /app/tool.py -o .'<br>input : '--input' </code> | `python /app/tool.py -o . --input exemplar-001.ome.tif` |
| <code>cmd   : 'python /app/tool.py -o .'<br>input : '' </code> | `python /app/tool.py -o . exemplar-001.ome.tif` |

## (Optional) Model

The `model` field functions similarly to `input` and specifies how the pipeline will supply a custom model to the tool. In this example, MCMICRO will check whether the user specified `--ilastik-model` in the calling arguments, and pass the corresponding value to ilastik via `--model`.

## (Optional) Channel and indexing base

The `channel` field indicates how MCMICRO should pass `--segmentation-channel` value(s) specified by the user to the module. The `idxbase` field specifies whether the module assumes 0-based or 1-based indexing. All channel indexing in MCMICRO starts with 1, and the pipeline will correctly account for 0-based indexing, if it used by the module.

## Watershed

The `watershed` field specifies whether the module requires a subsequent watershed step. Set it to `'yes'` for modules that produce probability maps and `'no'` for instance segmenters. Alternatively, you can specify `'bypass'` to have the output still go through S3Segmenter with the `--nucleiRegion bypass` flag. This will skip watershed but still allow you to filter nuclei by size with `--logSigma`.

## Putting it all together

Given the above configuration for ilastik, users of MCMICRO can begin using the module by including the following inside their `params.yml`:

``` yaml
workflow:
  segmentation: ilastik
  segmentation-channel: 1 5
  ilastik-model: myawesomemodel.ilp
options:
  ilastik: --num_channels 2
```

As exemplar-001 makes its way through the pipeline, it will eventually encounter the [segmentation step]({{ site.baseurl }}/io.html#segmentation). The pipeline will then identify ilastik as the module to be executed from the `--segmentation` flag. The actual command that MCMICRO runs will then be composed using all the above fields together:

```
python /app/mc-ilastik.py --output . --input exemplar-001.ome.tif --model myawesomemodel.ilp --channelIDs 1 5 --num_channels 2
```

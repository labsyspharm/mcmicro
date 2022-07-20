---
layout: default
title: Adding a module
nav_order: 10
parent: Advanced Topics
nav_exclude: true
---

# Adding a module

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

MCMICRO allows all modules to be specified dynamically. Adding new modules requires nothing more than editing a simple configuration file in YAML format. No changes to the Nextflow codebase necessary!

## Quick start

**Step 1.** Examine [the current specifications](https://github.com/labsyspharm/mcmicro/blob/master/modules.yml) and make note of the different fields provided for each pipeline step.

**Step 2.** Create a new `specs.yml` file and define specs for your new module. Test your new file in MCMICRO with `--modules specs.yml` to verify that everything is working as expected.

**Step 3.** If you believe your module will be of general utility to MCMICRO users, update `modules.yml` in the repository root and submit a pull request.

**Step 4.** After MCMICRO developers review and test your proposed module, the changes will be merged into the main project branch.

# Input and output specs

Every module must have a command-line interface (CLI) that has been encapsulated inside a Docker container. 
MCMICRO assumes that CLI conforms to the following input-output specifications.

## Segmentation modules

**Input:**

* A file in `.ome.tif` format containing a fully stitched and registered multiplexed image.
* (Optional) A file containing a custom model for the algorithm. The file can be in any format, and it is up to the module developer to decide what formats they allow from users.

**Output:**

* An image file in `.tif` format, written to `.` (i.e., the "current working directory"). The file can be either a probability map or a segmentation mask. The image channels in probability maps annotate each pixel with probabilities that it belongs to the background or different parts of the cell such as the nucleus, cytoplasm, cell membrane or the intercellular region. Similarly, segmentation masks annotate each pixel with an integer index of the cell it belongs to, or 0 if none.
* (Optional) One or more files written to `./qc/` (i.e., `qc/` subdirectory within the "current working directory"). These will be copied by the pipeline to the corresponding location in the [project's `qc/` directory]({{ site.baseurl }}/instructions/nextflow/#quality-control).

## Cell state calling modules

**Input:**

* A file in `.csv` format containing a [spatial feature table]({{ site.baseurl }}/instructions/nextflow/#quantification). Each row in a table corresponds to a cell, while columns contain features characterizing marker expression or morphological properties.
* (Optional) A file containing a custom model for the algorithm. The file can be in any format, and it is up to the module developer to decide what formats they allow from users.

**Output:**

* One or more files in `.csv` or `.hdf5` format, written to `.` (i.e., the "current working directory"). Each file should annotate individual cells with the corresponding inferred cell state.
* (Optional) One or more files written to `./plots/` (i.e., `plots/` subdirectory within the "current working directory"). Each file can be in any format and contain any information that the module developer thinks will be useful to the user (e.g., UMAP plots showing how cells cluster together).
* (Optional) One or more files written to `./qc/` (i.e., `qc/` subdirectory within the "current working directory"). These will be copied by the pipeline to the corresponding location in the [project's `qc/` directory]({{ site.baseurl }}/instructions/nextflow/#quality-control).

# Configuration

Adding a new MCMICRO module involves specifying simple key-value pairs in `modules.yml`. For example, consider the following configuration for ilastik:

```
  name: ilastik
  container: labsyspharm/mcmicro-ilastik
  version: 1.4.5
  cmd: python /app/mc-ilastik.py --output .
  input: --input
  model: --model
  channel: --channelIDs
  idxbase: 1
  watershed: 'yes'
  opts: --num_channels 1
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

## Options

The `opts` field specifies additional default parameters that MCMICRO should pass to the module by default. Unlike `cmd`, users can override the default `opts` values by specifying `--<module name>-opts` on the command line (`--ilastik-opts` in this case.)

## Putting it all together

Given the above configuration for ilastik, users of MCMICRO can begin using the module by typing the following command:

```
nextflow run labsyspharm/mcmicro --in path/to/exemplar-001 \
  --probability-maps ilastik \
  --segmentation-channels '1 5'\
  --ilastik-opts '--num_channels 2' \
  --ilastik-model myawesomemodel.ilp
```

As exemplar-001 makes its way through the pipeline, it will eventually encounter the [probability map generation and segmentation step]({{ site.baseurl }}instructions/nextflow/#segmentation). The pipeline will then identify ilastik as the module to be executed from the `--probability-maps` flag. The actual command that MCMICRO runs will then be composed using all the above fields together:

```
python /app/mc-ilastik.py --output . --input exemplar-001.ome.tif --model myawesomemodel.ilp --channelIDs 1 5 --num_channels 2
```

---
layout: default
title: Adding a module
nav_order: 1
parent: Modules
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

MCMICRO allows segmentation and cell state caller modules to be specified dynamically. Adding new modules requires nothing more than editing a simple configuration file. No changes to the Nextflow codebase necessary!

## Quick start

**Step 1.** Navigate to [https://github.com/labsyspharm/mcmicro/blob/master/config/modules.config](https://github.com/labsyspharm/mcmicro/blob/master/config/modules.config). Press the pencil in the top-right corner. This will fork the project to your own GitHub account and allow you to modify the file in your fork.

<img src="{{ site.baseurl }}/images/addmod/Step1.png"/>

**Step 2.** Add a new module by specifying all relevant fields (see below).

<img src="{{ site.baseurl }}/images/addmod/Step2.png"/>

**Step 3.** Briefly describe your new module. Provide a reference to the method and the codebase.

<img src="{{ site.baseurl }}/images/addmod/Step3.png"/>

**Step 4.** After MCMICRO developers review and test your proposed module, the changes will be merged into the main project branch.

# Input and output specs

Every module must have a command-line interface (CLI) that has been encapsulated inside a Docker container. 
MCMICRO assumes that CLI conforms to the following input-output specifications.

## Segmentation modules

**Input:**

* A file in `.ome.tif` format containing a fully stitched and registered multiplexed image.
* (Optional) A file containing a custom model for the algorithm. The file can be in any format, and it is up to the module developer to decide what formats they allow from users.

**Output:**

* One or more image files in `.tif` format, written to `.` (i.e., the "current working directory"). Each file can be either a probability map or a segmentation mask. The image channels in probability maps annotate each pixel with probabilities that it belongs to the background or different parts of the cell such as the nucleus, cytoplasm, cell membrane or the intercellular region. Similarly, segmentation masks annotate each pixel with an integer index of the cell it belongs to, or 0 if none.
* (Optional) One or more files written to `./qc/` (i.e., `qc/` subdirectory within the "current working directory"). These will be copied by the pipeline to the corresponding location in the [project's `qc/` directory](../documentation/step-qc.html).

## Cell state calling modules

**Input:**

* A file in `.csv` format containing a [spatial feature table](../documentation/step-quant.html). Each row in a table corresponds to a cell, while columns contain features characterizing marker expression or morphological properties.
* (Optional) A file containing a custom model for the algorithm. The file can be in any format, and it is up to the module developer to decide what formats they allow from users.

**Output:**

* One or more files in `.csv` or `.hdf5` format, written to `.` (i.e., the "current working directory"). Each file should annotate individual cells with the corresponding inferred cell state.
* (Optional) One or more files written to `./plots/` (i.e., `plots/` subdirectory within the "current working directory"). Each file can be in any format and contain any information that the module developer thinks will be useful to the user (e.g., UMAP plots showing how cells cluster together).
* (Optional) One or more files written to `./qc/` (i.e., `qc/` subdirectory within the "current working directory"). These will be copied by the pipeline to the corresponding location in the [project's `qc/` directory](../documentation/step-qc.html).

# Configuration

Adding a new MCMICRO module involves specifying simple key-value pairs in `config/modules.config`. For example, consider the following configuration for ilastik:

```
[
  name      : 'ilastik',
  container : 'labsyspharm/mcmicro-ilastik',
  version   : '1.4.3',
  cmd       : 'python /app/mc-ilastik.py --output .',
  input     : '--input',
  model     : '--model'
]
```

## Name

The `name` of the module determines two things. First, it specifies the names of subdirectories for where the output files will be written to in the project directory. In the given example, the primary outputs will appear in `probability-maps/ilastik/`, while QC files will be written to `qc/ilastik/`. Second, the module name also tells MCMICRO what other parameters to look for. In our example, the pipeline will look for module specific parameters in `--ilastik-opts` and a custom model file in `--ilastik-model`.

## Container and version

The two fields must uniquely identify a Docker container image containing the tool. Mechanistically, the fields are combined using the [standard `REPOSITORY:TAG` convention](https://docs.docker.com/engine/reference/commandline/images/).

## Command

The `cmd` field must contain a command that, when executed inside the container, will produce the required set of outputs from the inputs provided to it by the pipeline.

**It is imperative that all primary outputs are written to `.` (i.e., the "current working directory"). MCMICRO will automatically sort outputs to their correct location in the project directory. Writing outputs to any other location may result in MCMICRO failing to locate them.**

## Input

The `input` field determines how the pipeline will supply inputs to the module. Some examples in the context of [exemplar-001](../documentation/installation.html#exemplar-data) may look as follows:

| Configuration | What MCMICRO will execute |
| :-- | :-- |
| <code>cmd   : 'python /app/tool.py -o .'<br>input : '-i' </code> | `python /app/tool.py -o . -i exemplar-001.ome.tif` |
| <code>cmd   : 'python /app/tool.py -o .'<br>input : '--input' </code> | `python /app/tool.py -o . --input exemplar-001.ome.tif` |
| <code>cmd   : 'python /app/tool.py -o .'<br>input : '' </code> | `python /app/tool.py -o . exemplar-001.ome.tif` |

## (Optional) Model

The `model` field functions similarly to `input` and specifies how the pipeline will supply a custom model to the tool.

## Putting it all together

Given the above configuration for ilastik, users of MCMICRO can begin using the module by typing the following command:

```
nextflow run labsyspharm/mcmicro --in path/to/exemplar-001 \
  --probability-maps ilastik \
  --ilastik-opts '--num_channels 1' \
  --ilastik-model myawesomemodel.ilp
```

As exemplar-001 makes its way through the pipeline, it will eventually encounter the [probability map generation and segmentation step](../documentation/step-segmentation.html). The pipeline will then identify ilastik as the module to be executed from the `--probability-maps` flag. The actual command that MCMICRO runs will then be composed using all the above fields together:

```
python /app/mc-ilastik.py --output . --input exemplar-001.ome.tif --model myawesomemodel.ilp --num_channels 1
```

# (Advanced) Automated tests

MCMICRO uses [GitHub Actions](https://docs.github.com/en/actions) to execute a set of automated tests on the [two exemplar images](../documentation/installation.html#exemplar-data). The tests ensure that modifications to the pipeline don't break existing module functionality. When contributing a new module to MCMICRO, consider composing a new test that ensures your module runs on the exemplar data without any issues.

Automated tests are specified in [`ci.yml`](https://github.com/labsyspharm/mcmicro/blob/master/.github/workflows/ci.yml). The exemplar data is cached and can be easily restored via `actions/cache@v2`. For example, consider the following minimal test that contrasts unmicst and ilastik on exemplar-001:

```
test-ex001:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Nextflow
        run: curl -fsSL get.nextflow.io | bash
      - name: Restore exemplar-001 cache
        uses: actions/cache@v2
        with:
          path: ~/data/exemplar-001
          key: mcmicro-exemplar-001
      - name: Test exemplar-001
        run: ./nextflow main.nf --in ~/data/exemplar-001 --probability-maps unmicst,ilastik --s3seg-opts '--probMapChan 0'
```

The test, named `test-ex001`, consists of three steps: 1) Installing nextflow, 2) Restoring exemplar-001 data from cache, and 3) Running the pipeline on the exemplar-001. The `needs:` field specifies that the test should be executed after `setup` (which verifies the existence of cached data and performs caching if it's missing).


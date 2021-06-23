---
layout: default
title: Adding a module
nav_order: 1
parent: Modules
---

# Adding a module

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

**NOTE:** It is imperative that all primary outputs are written to `.` (i.e., the "current working directory"). MCMICRO will automatically sort outputs to their correct location in the project directory. Writing outputs to any other location may result in MCMICRO failing to locate them.

##Segmentation modules

**Input:**

* A file in `.ome.tif` format containing a fully stitched and registered multiplexed image.
* (Optional) A file containing a custom model for the algorithm. The file can be in any format, and it is up to the module developer to decide what formats they allow from users.

**Output:**

* One or more image files in `.tif` format, written to `.` (i.e., the "current working directory"). Each file can be either a probability map or a segmentation mask. The image channels in probability maps annotate each pixel with probabilities that it belongs to the background or different parts of the cell such as the nucleus, cytoplasm, cell membrane or the intercellular region. Similarly, segmentation masks annotate each pixel with an integer index of the cell it belongs to, or 0 if none.
* (Optional) One or more files written to `./qc/` (i.e., `qc/` subdirectory within the "current working directory"). These will be copied by the pipeline to the corresponding location in the [project's `qc/` directory](documentation/step-qc.html).

##Cell state calling modules

**Input:**

* A file in `.csv` format containing a [spatial feature table](documentation/step-quant.html). Each row in a table corresponds to a cell, while columns contain features characterizing marker expression or morphological properties.
* (Optional) A file containing a custom model for the algorithm. The file can be in any format, and it is up to the module developer to decide what formats they allow from users.

**Output:**

* One or more files in `.csv` or `.hdf5` format, written to `.` (i.e., the "current working directory"). Each file should annotate individual cells with the corresponding inferred cell state.
* (Optional) One or more files written to `./plots/` (i.e., `plots/` subdirectory within the "current working directory"). Each file can be in any format and contain any information that the module developer thinks will be useful to the user (e.g., UMAP plots showing how cells cluster together).
* (Optional) One or more files written to `./qc/` (i.e., `qc/` subdirectory within the "current working directory"). These will be copied by the pipeline to the corresponding location in the [project's `qc/` directory](documentation/step-qc.html).



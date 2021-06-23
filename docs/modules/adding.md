---
layout: default
title: Adding a module
nav_order: 1
parent: Modules
---

# Adding a module

MCMICRO allows segmentation and cell type caller modules to be specified dynamically. Adding new modules requires nothing more than editing a simple configuration file. No changes to the Nextflow codebase necessary!

## Quick start

**Step 1.** Navigate to [https://github.com/labsyspharm/mcmicro/blob/master/config/modules.config](https://github.com/labsyspharm/mcmicro/blob/master/config/modules.config). Press the pencil in the top-right corner. This will fork the project to your own GitHub account and allow you to modify the file in your fork.

<img src="{{ site.baseurl }}/images/addmod/Step1.png"/>

**Step 2.** Add a new module by specifying all relevant fields (see below).

<img src="{{ site.baseurl }}/images/addmod/Step2.png"/>

**Step 3.** Briefly describe your new module. Provide a reference to the method and the codebase.

<img src="{{ site.baseurl }}/images/addmod/Step3.png"/>

**Step 4.** After MCMICRO developers review your proposal, the changes will be merged into the main project branch.

# Input and output specs

Every module must have a command-line interface (CLI) that has been encapsulated inside a Docker container.



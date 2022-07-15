---
layout: default
title: Parameters
nav_order: 5
---


## Usage
The basic pipeline execution consists of:
1. Ensuring you have the latest version of the pipeline  
2. Creating a parameters file
2. Using `--in` and `--params` to point the pipeline at the data and the parameter file, respectively

``` bash
# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro

# Run the pipeline on data (starting from the registration step through quantification, by default)
nextflow run labsyspharm/mcmicro --in path/to/my/data
```
>(Where `path/to/my/data` is replaced with your specific path.)

{: .fs-3}

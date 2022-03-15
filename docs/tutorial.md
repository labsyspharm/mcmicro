---
layout: default
title: Tutorial
nav_order: 3
nav_exclude: false
---

# MCMICRO tutorial

**Here we show an example of how to execute MCMICRO on two exemplar datasets:**

<br>

 **Step 1:** Ensure you have the latest version of the pipeline 

``` bash
# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro
```

<br>

**Step 2:** [Download]({{ site.baseurl }}/datasets/datasets.html) exemplar data (downloads files into the current directory).  

```
nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-001 --path
```

<br>

**Step 3:** Use `--in` to point the pipeline at the data

```
# Run the pipeline on exemplar data (starting from the registration step, by default)
nextflow run labsyspharm/mcmicro --in path/to/exemplar-001

# Use --tma to dearray a tissue microarray and process each core in parallel
nextflow run labsyspharm/mcmicro --in path/to/exemplar-002 --tma
```

{: .fs-3}
{: .fw-200}
*After a successful run, the following text will be displayed:*
![screenshot after successful run]({{ site.baseurl }}/images/screenshot-after-run.jpg)

{: .fs-3}
{: .fw-200}
*The pipeline will also generate the following directory, depending on the modules used:*
``` bash
exemplar-001
├── markers.csv
├── raw/
├── illumination/
├── registration/
├── dearray/            # When working with TMA array(using --tma flag during execution)
├── probability-maps/
├── segmentation/
├── quantification/
└── qc/
```

**Visual inspection of quality control (`qc/`) files is recommended after completing the run. **

**Here are our output files** - show for each directory stage

Depending on the modules used, directories `coreo/`, `unmicst/` and `s3seg/` may contain `.tif` images for inspection. 

*More details on output files and quality control can be found in [Directory Structure](/instructions/dir.html).*
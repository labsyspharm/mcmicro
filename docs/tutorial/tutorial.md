---
layout: default
title: Tutorial
nav_order: 3
nav_exclude: false
has_children: true
---

# MCMICRO tutorial

**Here we show an example of how to execute MCMICRO on two exemplar datasets using the command line (Nextflow) interface:**

<br>

 **Step 0:** Be sure to [install](../instructions/nextflow/installation.html) MCMICRO before proceeding through these steps.
 
Enter the commands `nextflow run hello` and `docker run hello-world` to verify that both Nexflow and Docker* are functional.

*\*You may need to run Docker as Administrator.*

<br>

 **Step 1:** Ensure you have the latest version of the pipeline 

``` bash
# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro
```

<br>

**Step 2:** [Download]({{ site.baseurl }}/datasets/datasets.html) exemplar data. Replace \*path\* with where you want to store the files. (use `.` for path to downloads files into the current directory)

``` bash
# Download exemplar-001
nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-001 --path *path*

# Download exemplar-002
nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-002 --path *path*
```

Both exemplar datasets have the [directory structure]({{ site.baseurl }}/instructions/nextflow/#input) of

``` bash
exemplar-001 or exemplar-002
├── markers.csv
├── raw/
|   ├── exemplar-001-cycle-06.ome
|   ├── exemplar-001-cycle-07.ome
|   └── ...
|   
└── illumination/
    ├── ...
    ├── exemplar-001-cycle-06-dfp.tif
    ├── exemplar-001-cycle-06-ffp.tif
    ├── ...
    └── ...
# exemplar-001 contains cycle 6-8; exemplar-002 contains cycle 1-10.Ecah cycle has one .ome file in raw/ and two .tif files in illumination/
```
These images look like the following:

<div class="row">
<div class="col-xs-4 col-sm-4">
<div markdown="1">
![exemplar-001-cycle-06.ome](../images/tutorials/exemplar-001-cycle-06.png)

`exemplar-001-cycle-06.ome`

*\* This is the first image in a stack of 24 images.*
</div>
</div>

<div class="col-xs-4 col-sm-4">
<div markdown="1">
![exemplar-001-cycle-06-dfp.tif](../images/tutorials/exemplar-001-cycle-06-dfp.png)

`exemplar-001-cycle-06-dfp.tif`

*\* This is the first image of a stack of 4 images, previewed in Fiji with auto adjustments made to brightness and contrast.*
</div>
</div>

<div class="col-xs-4 col-sm-4">
<div markdown="1">
![exemplar-001-cycle-06-ffp.tif](../images/tutorials/exemplar-001-cycle-06-ffp.png)

`exemplar-001-cycle-06-ffp.tif`

*\* This is the first image of a stack of 4 images, previewed in Fiji with auto adjustments made to brightness and contrast.*
</div>
</div>

</div>

<br>

**Step 3:** Use `--in` to point the pipeline at the data. \*path\* should point to where your files are stored. (`.` points to the current directory)

``` bash
# Run the pipeline on exemplar data (starting from the registration step, by default)
nextflow run labsyspharm/mcmicro --in *path*/exemplar-001

# Use --tma to dearray a tissue microarray and process each core in parallel
nextflow run labsyspharm/mcmicro --in *path*/exemplar-002 --tma
```

**Note:** On an average workstation, it takes approximately 5-10 minutes to process exemplar-001 from start to finish. Exemplar-002 is substantially larger, and takes 30-40 minutes on an average workstation.


{: .fs-3}
{: .fw-200}
*After a successful run, the following text will be displayed for exemplar-001 and exemplar-002:*
![screenshot after successful run]({{ site.baseurl }}/images/screenshot-after-run.jpg)

![screenshot after successful run](../images/tutorials/exemplar-002-message.PNG)

{: .fs-3}
{: .fw-200}
*The pipeline will generate the following directory, depending on the modules used.* 

<style>
  code {
    white-space : pre-wrap !important;
    word-break: break-word;
  }
  details > summary {
    color: #00B0E9;
    font-weight: bold;
  }
</style>

<details>

<summary>Expand to see exemplar-001 and exemplar-002 output files*</summary>

<div markdown="1">
*\*`raw/` and `illumination/` contents will remain the same. They will be not elaborated on here.*
</div>

<div class="row">

<div class="col-xs-12 col-sm-6">
<div markdown="1">

``` bash
exemplar-001
├── markers.csv
├── raw/
├── illumination/
├── registration/
|  └── exemplar-001.ome
├── probability-maps/
|   └── unmicst/    
|       └── exemplar-001-pmap.tif
├── segmentation/
|   ├── cell.ome
|   └── nuclei.ome
├── quantification/
|   └── unmicst-exemplar-001_cell.csv
└── qc/
   ├── provenance/
   |   ├── quantification·mcquant(1).txt
   |   ├── quantification·mcquant(1).sh
   |   ├── reigstration·ashlar.txt
   |   ├── registration·ashlar.sh
   |   ├── segmentation·s3seg(1).txt
   |   ├── segmentation·s3seg(1).sh
   |   ├── segmentation·worker(unmicst-1).txt
   |   └── segmentation·workder(unmicst-1).sh
   ├── s3seg/
   |   └── unmicst-exemplar-001/
   |       ├── cellOutlines.ome
   |       └── nucleiOutlines.ome
   ├── unmicst/
   |   └── exemplar-001-Preview_1.tif
   └── params.yml










































```
</div>
</div>

<div class="col-xs-12 col-sm-6">
<div markdown="1">

``` bash
exemplar-002
├── markers.csv
├── raw/
├── illumination/
├── registration/
|   └── exemplar-002.ome
├── dearray/
|   ├── masks/
|   |   ├── 1_mask.tif
|   |   ├── 2_mask.tif
|   |   ├── 3_mask.tif
|   |   └── 4_mask.tif
|   ├── 1.tif
|   ├── 2.tif
|   ├── 3.tif
|   └── 4.tif
├── probability-maps/
|   └── unmicst/
|       ├── 1-pmap.tif
|       ├── 2_pmap.tif
|       ├── 3_pmap.tif
|       └── 4_pmap.tif   
├── segmentation/
|   ├── unmicst-1/
|   |   ├── cell.ome
|   |   └── nuclei.ome
|   ├── unmicst-2/
|   |   ├── cell.ome
|   |   └── nuclei.ome
|   ├── unmicst-3/
|   |   ├── cell.ome
|   |   └── nuclei.ome
|   └── unmicst-4/
|       ├── cell.ome
|       └── nuclei.ome
├── quantification/
|   ├── unmicst-1_cell.csv
|   ├── unmicst-2_cell.csv
|   ├── unmicst-3_cell.csv
|   └── unmicst-4_cell.csv
└── qc/
    ├──coreo/
    |  ├── centroidsY-X.txt
    |  └── TMA_MAP.tif
    ├── provenance/
    |   ├── dearraycoreograph(1).txt
    |   ├── dearraycoreograph(1).sh
    |   ├── quantification·mcquant(1).txt
    |   ├── quantification·mcquant(1).sh
    |   ├── ...
    |   ├── quantification·mcquant(4).txt
    |   ├── quantification·mcquant(4).sh 
    |   ├── reigstration·ashlar.txt
    |   ├── registration·ashlar.sh
    |   ├── segmentation·s3seg(1).txt
    |   ├── segmentation·s3seg(1).sh
    |   ├── ...
    |   ├── segmentation·s3seg(4).txt
    |   ├── segmentation·s3seg(4).sh 
    |   ├── segmentation·worker(unmicst-1).txt
    |   ├── segmentation·worker(unmicst-1).sh 
    |   ├── ...
    |   ├── segmentation·worker(unmicst-4).txt
    |   └── segmentation·workder(unmicst-4).sh
    ├── s3seg/
    |   └── unmicst-exemplar-001/
    |       ├── cellOutlines.ome
    |       └── nucleiOutlines.ome
    ├── unmicst/
    |   └── exemplar-001-Preview_1.tif
    └── params.yml
# Working with TMA array (using --tma flag) produces the dearray/ directory
```
</div>
</div>

</div>
</details>

**Visual inspection of quality control (`qc/`) files is recommended after completing the run.**

Depending on the modules used, directories `coreo/`, `unmicst/` and `s3seg/` may contain `.tif` images for inspection. 

*More details on output files and quality control can be found in [Directory Structure](/instructions/dir.html).*
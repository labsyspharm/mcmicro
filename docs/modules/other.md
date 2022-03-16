---
layout: default
title: Other modules
nav_order: 40
parent: Modules
---

# Other Modules

1. [Ilastik](./other.html#ilastik)
2. [Cypository](./other.html#ilastik)
3. [naivestates](./other.html#naivestates)
4. [FastPG](./other.html#fastpg) 


<br>

[Back to main modules](./){: .btn .btn-outline} 

---

## Ilastik

{: .text-grey-dk-250}
{: .fw-200}
{: .fs-3}
Last updated on 03-15-2022, check the [GitHub](https://github.com/labsyspharm/mcmicro-ilastik){:target="_blank"} for the most up-to-date documentation.

## Description
Ilastik is another method for generating probability maps that can be used as an alternative to UnMICST

### Usage
Arguments should be passed to Ilastik with the `--ilastik-opts` flag

### Optional arguments

| Parameter | Default | Description |
| --- | --- | --- |
| `--nonzero_fraction <value>` |`None` | Indicates fraction of pixels per crop above global threshold to ensure tissue and not only background is selected |
| `--nuclei_index <index>` |`1` | Index of nuclei channel to use for nonzero_fraction argument |
| `--crop` | Omitted | If specified, crop regions for ilastik training |
| `--num_channels <value>` | `None`| Number of channels to export per image (Ex: 40 corresponds to a 40 channel ome.tif image) |
| `--channelIDs <indices>` |`None` | Integer indices specifying which channels to export (Ex: 1 2 4). **NOTE: You must specify a channel to use for filtering in S3segmenter as --probMapChan in --s3seg-opts**|
| `--ring_mask`| Omitted | Specify if you have a ring mask in the same directory to use for reducing size of hdf5 image |
| `--crop_amount <integer>`| `None`| Number of crops you would like to extract |



[Back to top](./other.html#other-modules){: .btn .btn-purple} 

---

## Cypository

{: .text-grey-dk-250}
{: .fw-200}
{: .fs-3}
Last updated on 03-15-2022, check the [GitHub](https://github.com/HMS-IDAC/Cypository#cypository---pytorch-mask-rcnn-for-cell-segmentation){:target="_blank"} for the most up-to-date documentation.

## Description
Cypository is used to segment the cytoplasm of cells. 

### Usage
Arguments should be provided to MCMICRO with the `--___-opts` flag

### Required arguments
Image path (provided by Nextflow when operating through the MCMICRO pipeline)

### Optional arguments

| Parameter | Default | Description |
| --- | --- | --- |
|``--model``|  | Currently only one model exists (zeisscyto)|
|``--outputPath``| |path where output files should be saved to.  |
|``--channel``| | channel containing the cytoplasm stain. 0-based indexing. | 
| ``--threshold``|  0.6  |A value between 0 and 1 to filter out false detections.|  
|``--overlap`` | |The image is split into overlapping tiles before cytoplasm detection. This parameter specifies the amount of overlap in pixels.|
|``--scalingFactor``| 1 (no resizing)  |Factor by which to increase/decrease image size by.| 
|``--GPU``|Default behavior is the first GPU card (0-based indexing).| If multiple GPUs are available, this specifies which GPU card to use.|

[Back to top](./other.html#other-modules){: .btn .btn-purple} 

---

## Naivestates

{: .text-grey-dk-250}
{: .fw-200}
{: .fs-3}
Last updated on 03-15-2022, check the [GitHub](https://github.com/labsyspharm/naivestates){:target="_blank"} for the most up-to-date documentation.

### Description
`naivestates` is a label-free, cluster-free tool for inferring cell types from quantified marker expression data, based on known marker <-> cell type associations. 

### Usage
Arguments should be provided to MCMICRO with the `--nstates-opts` flag

Example: `nextflow run labsyspharm/mcmicro --in /my/data --nstates-opts '--log no --plots pdf'`

### Required arguments
* A list of marker names. You can provide a `markers.csv` defined in an MCMICRO-compatible format (i.e., comma-delimited with marker names listed in the `marker_name` column). 
* * Marker expression on a per-cell basis, provided in `.csv` format. One of the columns must contain cell IDs. 

Example input file:
```
CellID,KERATIN,FOXP3,SMA
1,64.18060200668896,193.00334448160535,303.5016722408027
2,54.850202429149796,151.19433198380565,176.3846153846154
3,63.94712643678161,210.43218390804597,483.9448275862069
4,142.01320132013203,227.85808580858085,420.76897689768975
5,56.66379310344828,197.01896551724138,343.7810344827586
6,69.97454545454545,187.59636363636363,267.9709090909091
7,67.57754010695187,185.63368983957218,351.7914438502674
8,64.012,190.02,349.348
9,56.9622641509434,159.79245283018867,236.43867924528303
...
```

* Ensure that the file lives in `/path/to/data/folder/` and modify the Docker call to use the new file:

```
docker run --rm -v /path/to/data/folder:/data labsyspharm/naivestates:1.2.0 \
  /app/main.R -i /data/myfile.csv -m /data/markers.csv
```

{: .fw-400}
{: .fs-3}
*Docker-level arguments:*

{: .fw-200}
{: .fs-3}
-   `--rm` once again cleans up the container instance after it finishes running the code
-   `-v /path/to/data/folder:/data` maps the local folder containing your data to `/data` inside the container
-   `:1.2.0` specifies the container version that we pulled above

{: .fw-400}
{: .fs-3}
*Tool-level arguments:*

{: .fw-200}
{: .fs-3}
-   `-i /data/myfile.csv` specifies which data file to process

### Optional arguments

| Parameter | Default | Description |
| --- | --- | --- |
|`-o <path>` | `/data` | Alternative output directory. (*Note that any file written to a directory that wasn't mapped with `docker -v` will not persist when the container is destroyed.*)|
|`--plots <off|pdf|png>` | `off` | Produces QC plots of individual marker fits and summary UMAP plots in .png or .pdf format. |
| `--id <name>` | `CellID` |Name of the column that contains cell IDs|
| `--log <yes|no|auto>` | `auto` |When a log<sub>10</sub> transformation should be applied prior to fitting the data. The tool will do this automatically if it detects large values. Use `--log no` to force the use of original, non-transformed values instead.|
|`--comb <hmean|gmean>` | `gmean`| Whether to use harmonic mean (`hmean`) or geometric mean (`gmean`) to combine probabilities of expression for individual markers.|
|`--sfx <suffix>` |automatically determined| A common suffix on the marker columns (e.g., `_cellMask` or `_nucleiMask`). The suffix will be removed in the output plots and tables to improve readability. Use `$` to force an empty suffix.|
| `--umap`|disabled| Include this flag to generate UMAP plots.|
|`--mct <filename>` | |The tool has a basic marker -> cell type (mct) mapping in `typemap.csv`. More sophisticated mct mappings can be defined by creating a `custom-map.csv` file with two columns: `Marker` and `State`. Ensure that `custom map.csv` is in `/path/to/data/folder` and point the tool at it with `--mct` (e.g., `/app/main.R -i /data/myfile.csv --mct /data/custom-map.csv -m aSMA,CD45,panCK`) |

[Back to top](./other.html#other-modules){: .btn .btn-purple} 

---

## FastPG

{: .text-grey-dk-250}
{: .fw-200}
{: .fs-3}
Last updated on 03-15-2022, check the [GitHub](https://github.com/labsyspharm/mcmicro-fastPG#parameter-reference){:target="_blank"} for the most up-to-date documentation.

### Description
FastPG does "fast phenograph-like clustering of items with scores of features". This module provides a command-line interface for the popular Phenograph method [(FastPG - developed elsewhere)](https://github.com/sararselitsky/FastPG), through a C++ implementation.

### Usage
Arguments should be provided to MCMICRO with the `--fastpg-opts` flag

### Required arguments
Input and output paths (provided by Nextflow when operating through the MCMICRO pipeline)

### Optional arguments

| Parameter | Default | Description |
| --- | --- | --- |
|```-h, --help``` | |Show help message and exit|
| ``-m MARKERS`` | | A text file with a marker on each line to specify which markers to use for clustering |
| ``-v, --verbose`` ||Flag to print out progress of script |
| ``-k NEIGHBORS `` | 30 |The number of nearest neighbors to use when clustering.|
|``-n NUM_THREADS``| 1 |The number of cpus to use during the k nearest neighbors part of clustering.|
|``-c, --method``| | Include a column with the method name in the output files.|
| ``-y CONFIG``| | A yaml config file that states whether the input data should be log/logicl transformed.|
|``  --force-transform ``| | Log transform the input data. If omitted, and --no-- transform is omitted, log transform is only performed if the max value in the input data is >1000.|
|`` --no-transform`` | |Do not perform Log transformation on the input data. If omitted, and --force-transform is omitted, log transform is only performed if the max value in the input data is >1000.|

[Back to top](./other.html#other-modules){: .btn .btn-purple} [Back to main modules](./){: .btn .btn-outline} 
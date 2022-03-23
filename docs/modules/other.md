---
layout: default
title: Other modules
nav_order: 40
parent: Modules
---

# Other Modules

Last updated on {{ site.time | date: "%Y-%m-%d" }}.

Segmentation
1. [Ilastik](./other.html#ilastik)
1. [Cypository](./other.html#cypository)

Clsutering and cell type inference
1. [Clustering](./other.html#clustering) 
1. [naivestates](./other.html#naivestates)

<br>

[Back to main modules](./){: .btn .btn-outline} 

---

## Ilastik

### Description
The module provides a command-line interface to the popular [ilastik](https://www.ilastik.org/) toolkit and serves as another method for generating probability maps that can be used as an alternative to UnMICST. Check the [GitHub](https://github.com/labsyspharm/mcmicro-ilastik){:target="_blank"} for the most up-to-date documentation.

### Usage
By default, MCMICRO runs UnMicst for probability map generation. To run Ilastik instead of or in addition to UnMicst, use the `--probability-maps` flag. When specifying multiple methods, note that the method names must be delimited by a comma with no space. Arguments should be passed to Ilastik with the `--ilastik-opts` flag. Custom models can be provided to Ilastik via `--ilastik-model`.

* Examples:
  * `nextflow run labsyspharm/mcmicro --in /my/project --probability-maps ilastik --ilastik-opts '--crop'`
  * `nextflow run labsyspharm/mcmicro --in /my/project --probability-maps ilastik,unmicst --ilastik-model mymodel.ilp`
* Default: `--ilastik-opts '--num_channels 1'`
* Running outside of MCMICRO: [Instructions](https://github.com/labsyspharm/mcmicro-ilastik){:target="_blank"}.

### Input
A stitched and registered ``.ome.tif``, preferably flat field corrected. Nextflow will use as input files from the `registration/` subdirectory for whole-slide images and from the `dearray/` subdirectory for tissue microarrays.

### Output
The output is similar to that produced by UnMicst, namely a ```.tif``` stack where the different probability maps for each class are concatenated in the Z-axis in the order: nuclei foreground, nuclei contours, and background. Nextflow will write output to the `probability-maps/ilastik/` subdirectory within the project folder.

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

### Description

Cypository is used to segment the cytoplasm of cells. Check the [GitHub repository](https://github.com/HMS-IDAC/Cypository#cypository---pytorch-mask-rcnn-for-cell-segmentation){:target="_blank"} for the most up-to-date documentation.

### Usage
Use `--probability-maps` to enable Cypository. In general, it would be uncommon to run Cypository alongside probability map generators for nuclei, but it can be done by specifying method names delimited with a comma and no space, e.g., `--probability-maps cypository,unmicst`. Additional Cypository parameters should be provided to MCMICRO with the `--cypository-opts` flag.

* Example: `nextflow run labsyspharm/mcmicro --in /my/project --probability-maps cypository --cypository-opts '--channel 5'`
* Default: `--cypository-opts '--model zeisscyto'`

### Input
A stitched and registered ``.ome.tif``, preferably flat field corrected. Nextflow will use as input files from the `registration/` subdirectory for whole-slide images and from the `dearray/` subdirectory for tissue microarrays.

### Output
A `.tif` file that annotates individual pixels with the probability that they belong to the cytoplasm of a cell. Nextflow will write output to the `probability-maps/cypository/` subdirectory within the project folder.

### Optional arguments

| Parameter | Default | Description |
| --- | --- | --- |
|``--model``|  | Currently only one model exists (zeisscyto)|
|``--channel``| | channel containing the cytoplasm stain. 0-based indexing. | 
|``--threshold``|  0.6  |A value between 0 and 1 to filter out false detections.|  
|``--overlap`` | |The image is split into overlapping tiles before cytoplasm detection. This parameter specifies the amount of overlap in pixels.|
|``--scalingFactor``| 1 (no resizing)  |Factor by which to increase/decrease image size by.| 
|``--GPU``|Default behavior is the first GPU card (0-based indexing).| If multiple GPUs are available, this specifies which GPU card to use.|

[Back to top](./other.html#other-modules){: .btn .btn-purple} 

---

## Clustering

### Description
MCMICRO integrates three methods for clustering single-cell data. These are [FastPG](https://www.biorxiv.org/content/10.1101/2020.06.19.159749v2){:target="_blank"} (Fast C++ implementation of the popular Phenograph method), Leiden community detection via [scanpy](https://scanpy.readthedocs.io/en/stable/){:target="_blank"}, and [FlowSOM](https://bioconductor.org/packages/release/bioc/html/FlowSOM.html){:target="_blank"}.

### Usage
Use the `--cell-states` flag to select one or more methods. Method names should be delimited with a comma and no space. Additional method parameters should be provided to MCMICRO with the following flags: `--fastpg-opts`, `--scanpy-opts`, `--flowsom-opts`.

* Examples:
  * `nextflow run labsyspharm/mcmicro --in /my/project --stop-at cell-states --cell-states fastpg,flowsom --fastpg-opts '-k 10'`
  * `nextflow run labsyspharm/mcmicro --in /my/project --stop-at cell-states --cell-states scanpy --scanpy-opts '-k 10'`
* Running outside of MCMICRO:
  * [Instructions for FastPG](https://github.com/labsyspharm/mcmicro-fastpg){:target="_blank"}
  * [Instructions for scanpy](https://github.com/labsyspharm/mcmicro-scanpy){:target="_blank"}
  * [Instructions for FlowSOM](https://github.com/labsyspharm/mcmicro-flowsom){:target="_blank"}

### Input

All methods accept as input the cell-by-feature matrix in `.csv` format. Nextflow looks for these files in the `quantification/` subfolder within the project directory.

### Output

All methods output a `.csv` file annotating individual cells with their cluster index. Nextflow will write these files to the `cell-states/` subfolder within the project directory.

### Optional arguments to FastPG

| Parameter | Default | Description |
| --- | --- | --- |
| ``-v, --verbose`` ||Flag to print out progress of script |
| ``-k NEIGHBORS `` | 30 |The number of nearest neighbors to use when clustering.|
|``-n NUM_THREADS``| 1 |The number of cpus to use during the k nearest neighbors part of clustering.|
|``-c, --method``| | Include a column with the method name in the output files.|
|``--force-transform``| | Log transform the input data. If omitted, and --no-- transform is omitted, log transform is only performed if the max value in the input data is >1000.|
|`` --no-transform`` | |Do not perform Log transformation on the input data. If omitted, and --force-transform is omitted, log transform is only performed if the max value in the input data is >1000.|

### Optional arguments to scapy

| Parameter | Default | Description |
| --- | --- | --- |
| ``-v, --verbose`` ||Flag to print out progress of script |
| ``-k NEIGHBORS `` | 30 |The number of nearest neighbors to use when clustering.|
|``-c, --method``| | Include a column with the method name in the output files.|
|``--force-transform``| | Log transform the input data. If omitted, and --no-- transform is omitted, log transform is only performed if the max value in the input data is >1000.|
|`` --no-transform`` | |Do not perform Log transformation on the input data. If omitted, and --force-transform is omitted, log transform is only performed if the max value in the input data is >1000.|

### Optional arguments to scanpy

| Parameter | Default | Description |
| --- | --- | --- |
| `-v, --verbose` | | Flag to print out progress of script |
| `-c, --method` | | Include a column with the method name in the output files. |
| `-n, --num-metaclusters` | 25 | The number of clusters for meta-clustering. |
| `--xdim XDIM` | 10 | The number of neurons in the SOM in the x dimension. |
| `--ydim YDIM` | 10 | The number of neurons in the SOM in the y dimension. |
|``--force-transform``| | Log transform the input data. If omitted, and --no-- transform is omitted, log transform is only performed if the max value in the input data is >1000.|
|`` --no-transform`` | |Do not perform Log transformation on the input data. If omitted, and --force-transform is omitted, log transform is only performed if the max value in the input data is >1000.|

[Back to top](./other.html#other-modules){: .btn .btn-purple}

---

## Naivestates

### Description
`naivestates` is a label-free, cluster-free tool for inferring cell types from quantified marker expression data, based on known marker <-> cell type associations. Check the [GitHub repository](https://github.com/labsyspharm/naivestates){:target="_blank"} for the most up-to-date documentation.

### Usage
Use the `--cell-states` flag to select naivestates. When running alongside other cell state inference methods, such as SCIMAP, method names should be delimited with a comma and no space. Custom marker to cell type (mct) mapping can be provided to naivestates via `--naivestates-model`. Arguments should be provided to MCMICRO with the `--naivestates-opts` flag.

* Examples:
  * `nextflow run labsyspharm/mcmicro --in /my/project --stop-at cell-states --cell-states naivestates --naivestates-opts '--log no'`
  * `nextflow run labsyspharm/mcmicro --in /my/project --stop-at cell-states --cell-states naivestates,scimap --naivestates-model map.csv`
* Default: `--naivestates--opts '-p png'`
* Running outside of MCMICRO: [Instructions](https://github.com/labsyspharm/mcmicro-ilastik){:target="_blank"}.

### Inputs

* A cell-by-feature table in `.csv` format, such as one produced by MCquant. Nextflow will look for such tables in the `quantification/` subfolder of the project directory.
* [Optional] A two-column `.csv` file providing a many-to-many mapping between markers and cell types/states. The columns must be named `Marker` and `State`.

### Outputs
* A `.csv` file providing probabilities that a marker is expressed for each cell-marker pair.
* If the mapping to cell types is provided, a second `.csv` file with probabilistic annotations of each cell with its type/state.
* A set of plots showing probability distributions and UMAP projections

Nextflow will write all outputs to the `cell-states/naivestates/` subdirectory within the project. If relevant, additional QC files will be written to `qc/naivestates`.

### Optional arguments

| Parameter | Default | Description |
| --- | --- | --- |
|`--plots <off|pdf|png>` | `off` | Produces QC plots of individual marker fits and summary UMAP plots in .png or .pdf format. |
| `--id <name>` | `CellID` |Name of the column that contains cell IDs|
| `--log <yes|no|auto>` | `auto` |When a log<sub>10</sub> transformation should be applied prior to fitting the data. The tool will do this automatically if it detects large values. Use `--log no` to force the use of original, non-transformed values instead.|
|`--comb <hmean|gmean>` | `gmean`| Whether to use harmonic mean (`hmean`) or geometric mean (`gmean`) to combine probabilities of expression for individual markers.|
|`--sfx <suffix>` |automatically determined| A common suffix on the marker columns (e.g., `_cellMask` or `_nucleiMask`). The suffix will be removed in the output plots and tables to improve readability. Use `$` to force an empty suffix.|
| `--umap`|disabled| Include this flag to generate UMAP plots.|
|`--mct <filename>` | |The tool has a basic marker -> cell type (mct) mapping in `typemap.csv`. More sophisticated mct mappings can be defined by creating a `custom-map.csv` file with two columns: `Marker` and `State`. |

[Back to top](./other.html#other-modules){: .btn .btn-purple} [Back to main modules](./){: .btn .btn-outline} 

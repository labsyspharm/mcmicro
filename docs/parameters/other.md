---
layout: default
title: "Options: Other modules"
nav_order: 40
parent: Parameters
nav_exclude: true
---

# Other Modules
Staging
1. [phenoimager2mc](./other.html#phenoimager2mc)

Segmentation
1. [Ilastik](./other.html#ilastik)
1. [Cypository](./other.html#cypository)
1. [Mesmer](./other.html#mesmer)
1. [Cellpose](./other.html#cellpose)

Clustering and cell type inference
1. [Clustering](./other.html#clustering) 
1. [naivestates](./other.html#naivestates)

Background subtraction
1. [Backsub](./other.html#backsub)

<br>

[Back to main modules](./){: .btn .btn-outline} 

---

## Staging - Phenoimager2mc
{: .fw-500}

### Description
Introducing an additional `staging` step in the pipeline, the [phenoimager2mc](https://github.com/schapirolabor/phenoimager2mc){:target="_blank"} module takes in individual unmixed component data tiles produced by the [InForm software by Akoya](https://www.akoyabio.com/phenoimager/inform-tissue-finder/) and produces an `ome-tif` file per cycle that is compatible with ASHLAR.

### Usage
By default, `staging` is not performed and the parameter has to be provided as shown below. In addition, the `staging-method: phenoimager2mc` parameter can specify which staging option should be used. It should be noted, `illumination` is run by default after `staging` and should actively be turned off if not needed as presented. It is highly recommended that the input tiles already have overlaps between them, if not, gaps will be introduced.

* Example `params.yml`:

``` yaml
workflow:
  start-at: staging
  staging: true
  illumination: false
  staging-method: phenoimager2mc
options:
  phenoimager2mc: -m 6 --normalization max
```
* Specify number of channels per cycle: `-m`
* Specify normalization (float32 -> uint16) method: `--normalization`, options `max`, `99th` for maximum value normalization or 99th percentile, respectively.
* Running outside of MCMICRO: [Instructions](https://github.com/labsyspharm/mcmicro-ilastik){:target="_blank"}.

[Back to top](./other.html#other-modules){: .btn .btn-purple} 

## Ilastik
{: .fw-500}

### Description
The module provides a command-line interface to the popular [ilastik](https://www.ilastik.org/) toolkit and serves as another method for generating probability maps that can be used as an alternative to UnMICST. Check the [GitHub](https://github.com/labsyspharm/mcmicro-ilastik){:target="_blank"} for the most up-to-date documentation.

### Usage
By default, MCMICRO runs UnMicst for probability map generation. To run Ilastik instead of or in addition to UnMicst, add `segmentation: ilastik` to [workflow parameters]({{site.baseurl}}/parameters/). When specifying multiple methods, the method names should be provided as a list enclosed in square brackets. Arguments should be passed to Ilastik via `ilastik:` in the module options section, while custom models can be provided to Ilastik via `ilastik-model:` workflow parameter.

* Example `params.yml`:

``` yaml
workflow:
  segmentation: [ilastik, unmicst]
  ilastik-model: /full/path/to/mymodel.ilp
options:
  ilastik: --nonzero_fraction 0.5 --num_channels 1
```
* Default ilastik options: `--num_channels 1`
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
| `--num_channels <value>` | `None`| Number of channels to export per image (Ex: 40 corresponds to a 40 channel ome.tif image) |
| `--channelIDs <indices>` |`None` | Integer indices specifying which channels to export (Ex: 1 2 4). **NOTE: You must specify a channel to use for filtering in S3segmenter as --probMapChan in --s3seg-opts**|
| `--ring_mask`| Omitted | Specify if you have a ring mask in the same directory to use for reducing size of hdf5 image |
| `--crop_amount <integer>`| `None`| Number of crops you would like to extract |

[Back to top](./other.html#other-modules){: .btn .btn-purple} 

---

## Cypository
{: .fw-500}

### Description
Cypository is used to segment the cytoplasm of cells. Check the [GitHub repository](https://github.com/HMS-IDAC/Cypository#cypository---pytorch-mask-rcnn-for-cell-segmentation){:target="_blank"} for the most up-to-date documentation.

### Usage
Add `segmentation: cypository` to [workflow parameters]({{site.baseurl}}/parameters/) to enable Cypository. In general, it would be uncommon to run Cypository alongside probability map generators for nuclei, but it can be done by specifying method names as a list enclosed in square brackets, e.g., `segmentation: [cypository, unmicst]`. Additional Cypository parameters should be provided to MCMICRO by including a `cypository:` field in the module options section.

* Example `params.yml`:
``` yaml
workflow:
  segmentation: cypository
options:
  cypository: --channel 5
```

* Default cypository options: `--model zeisscyto`

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

## Mesmer
{: .fw-500}

### Description
The [Mesmer](https://doi.org/10.1038/s41587-021-01094-0){:target="_blank"} module provides an alternative segmentation approach to UnMicst and ilastik. It is implemented and maintained by an external group. Check their [GitHub repository](https://github.com/vanvalenlab/deepcell-applications){:target="_blank"} for the most up-to-date information.

### Usage

Add `segmentation: mesmer` to [workflow parameters]({{site.baseurl}}/parameters/) to enable Mesmer. When running together with UnMicst and/or ilastik, method names must be provided as a list enclosed in square brackets. Additional Mesmer parameters can be provided to MCMICRO by including a `mesmer:` field in the module options section.

* Example `params.yml`:

``` yaml
workflow:
  segmentation: mesmer
options:
  mesmer: --image-mpp 0.25
```
* Running outside of MCMICRO: [Instructions](https://github.com/vanvalenlab/deepcell-applications){:target="_blank"}.

### Input

A stitched and registered ``.ome.tif``, preferably flat field corrected. Nextflow will use as input files from the `registration/` subdirectory for whole-slide images and from the `dearray/` subdirectory for tissue microarrays.

### Output

A segmentation mask, similar to the ones produced by S3segmenter. Nextflow will write these files directly to `segmentation/`.

### Optional arguments

| Name | Description | Default Value |
| :--- | :--- | :--- |
| `--nuclear-channel` | The numerical index of the channel(s) from `nuclear-image` to select. If multiple values are passed, the channels will be summed. | `0` |
| `--compartment` | Predict nuclear or whole-cell segmentation. | `"whole-cell"` |
| `--image-mpp` | The resolution of the image in microns-per-pixel. A value of 0.5 corresponds to 20x zoom. | `0.5` |
| `--batch-size` | Number of images to predict on per batch. | `4` |

---

## Cellpose
{: .fw-500}

### Description
Cellpose is a DL segmentation algorithm able to segment the nuclear or cytoplasmic compartments of the cell.  Publications of this algorithm can be found in [1](https://www.nature.com/articles/s41592-020-01018-x){:target="_blank"} and [2](https://www.nature.com/articles/s41592-022-01663-4){:target="_blank"}.  A thorough documentation of the script and CLI can be found [here](https://cellpose.readthedocs.io/en/latest/index.html){:target="_blank"}.

### Usage

To use this segmentation method add the line `segmentation: cellpose` in the workflow section of the `params.yml` file.  Under the options section of `params.yml` specify the input arguments of the cellpose script, such as segmentation model and channel(s) on which the model will be applied.  Notice that the channel(s) argument(s), i.e. --chan and --chan2, expect a zero-based index.  

For large data sets it is recommended to use the parameters `segmentation-recyze: true` along with `segmentation-channel:`.  In the example below we consider an image stack of 12 channels with the nuclear marker in channel 2 and membrane marker in channel 7.  The use of `segmentation-recyze: true` will reduce the image stack to these two channels prior to segmentation, hence reindexing the stack channels such that 2-->0 and 7-->1. 
If `segmentation-max-projection: true` and multiple channels are provided for nuclear and membrane stains with `segmentation-nuclear-channel:` and `segmentation-membrane-channel:`, the returned image stack will contain the maximum projection of the respective nuclear (recyze output channel 0) and membrane channels (recyze output channel 1).


* Example `params.yml`:

``` yaml
workflow:
  segmentation-channel: 2 7
  segmentation-recyze: true
  segmentation: cellpose
options:
  cellpose: --pretrained_model cyto --chan 1 --chan2 0 --no_npy
```

* Example `params.yml` using max-projection - the input image is large, so `segmentation-recyze` is toggled. The segmentation in this case should be run on the maximum projection of two nuclear markers (channels 5 and 11), and 3 membrane markers (channels 2 3 and 7). The output from `Recyze` will be a two-channel `tif`, the nuclear channel max projection - channel 0, is provided to the `cyto` model with `--chan2 0`, and the membrane channel max  projection - channel 1, is provided to the model with `--chan 1`.

``` yaml
workflow:
  segmentation-channel: 2 3 5 7 11
  segmentation-recyze: true
  segmentation: cellpose
  segmentation-max-projection: true
  segmentation-nuclear-channel: 5 11
  segmentation-membrane-channel: 2 3 7
options:
  cellpose: --pretrained_model cyto --chan 1 --chan2 0 --no_npy
```
* Running outside of MCMICRO: [Github](https://github.com/MouseLand/cellpose){:target="_blank"}, [Instructions](https://cellpose.readthedocs.io/en/latest/installation.html){:target="_blank"}.

### Input

* The image (`.tif`) to be segmented should be in the `registration/` subdirectory.
* --pretained_model: name of the built-in model to be used for segmentation, options include “_nuclei_”,“_cyto_” and “_cyto2_”.  Alternatively you can give a file path to a custom retrained model.  Custom models can be trained in the [cellpose GUI](https://cellpose.readthedocs.io/en/latest/gui.html){:target="_blank"}.
* --chan: zero-based index of the channel on which the segmentation model will be applied.  When using the “nuclei” model provide the index of the nuclear channel, e.g. DAPI.  In the case of the "cyto" models provide the channel of the membrane marker.
* --chan2 [optional]: index of the nuclear marker channel.  This argument is valid only when using the "cyto" models.

### Output

A `.tif` image with the segmentation masks in the `segmentation/` subdirectory.

### Optional arguments

| Name | Description | Default Value |
| :--- | :--- | :--- |
| `--pretrained_model` | Name of a built-in segmentation model or a file path to a custom model. | `cyto` |
| `--chan` | Index of the selected channel to segment.  | `0` |
| `--chan2` | Index of the nuclear marker channel. | `0` |
| `--no_npy` | Boolean flag to suppress saving the .npy files output (recommended to avoid overflow errors when processing large data sets). | `False` |

---

## Clustering
{: .fw-500}

### Description
MCMICRO integrates three methods for clustering single-cell data. These are [FastPG](https://www.biorxiv.org/content/10.1101/2020.06.19.159749v2){:target="_blank"} (Fast C++ implementation of the popular Phenograph method), Leiden community detection via [scanpy](https://scanpy.readthedocs.io/en/stable/){:target="_blank"}, and [FlowSOM](https://bioconductor.org/packages/release/bioc/html/FlowSOM.html){:target="_blank"}.

### Usage
Add a `downstream:` field to [workflow parameters]({{site.baseurl}}/parameters/) to select one or more methods. Method names should be provided as a comma-delimited list enclosed in square brackets. Additional method parameters should be provided to MCMICRO by adding `fastpg:`, `scanpy:` and `flowsom:` fields to the module options section.

* Example `params.yml`:

``` yaml
workflow:
  stop-at: downstream
  downstream: [fastpg, flowsom, scanpy]
options:
  fastpg: -k 10
  scanpy: -k 10
```
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

### Optional arguments to FlowSOM

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
{: .fw-500}


### Description
`naivestates` is a label-free, cluster-free tool for inferring cell types from quantified marker expression data, based on known marker <-> cell type associations. Check the [GitHub repository](https://github.com/labsyspharm/naivestates){:target="_blank"} for the most up-to-date documentation.

### Usage
Add a `downstream:` field to [workflow parameters]({{site.baseurl}}/parameters/) to select naivestates. When running alongside other cell state inference methods, such as SCIMAP, method names should be provided as a list enclosed in square brackets. Custom marker to cell type (mct) mapping can be provided to naivestates via the `naivestates-model:` workflow parameters, while additional arguments should be specified by including a `naivestates:` field in the module options section.

* Example `params.yml`:

``` yaml
workflow:
  stop-at: downstream
  downstream: naivestates
  naivestates-model: /full/path/to/mct.csv
options:
  naivestates: --log no
```
* Default naivestates options: `-p png`
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

[Back to top](./other.html#other-modules){: .btn .btn-purple}

---

## Backsub
{: .fw-500}


### Description
`Backsub` is an autofluorescence subtraction module for sequential IF images. It performs pixel-level subtraction on large `.ome.tif` images primarily developed with the Lunaphore COMET platform outputs in mind.

### Usage
By default, MCMICRO assumes background subtraction should not be performed. Add `background: true` to [module options]({{site.baseurl}}/parameters/workflow.html#background) to indicate it should be. By default, the `background-method` parameter is set to `backsub`. 
If channels are removed using this module, and `segmentation-channel` is specified, it should be kept in mind that the index provided with `segmentation-channel` would refer to the index after channel removal.

* Example `params.yml`:

``` yaml
workflow:
  background: true
  background-method: backsub
```

* Running outside of MCMICRO: [Instructions](https://github.com/SchapiroLabor/Background_subtraction){:target="_blank"}.

### Inputs

* Stitched and registered multi-cycle `.ome.tif`
* The `markers.csv` file must contain a `marker_name` column specifying channel markers. The `background` column indicates which channel should be subtracted and the value must match the marker name of the background channel. The `exposure` column with exposure times for respective channel acquisitions is also required. Additionally, the `remove` column can have "TRUE" values for channels which shouldn't be included in the output. An example `markers.csv` can be found [here](https://github.com/SchapiroLabor/Background_subtraction/blob/main/example/markers.csv).

### Outputs

* A pyramidal, tiled `.ome.tif`. Nextflow will write the output file to `background/` within the project directory.
* A modified `markers.csv` to match the background subtracted image.

### Optional arguments

| Parameter | Default | Description |
| --- | --- | --- |
| `--pixel-size` | `None` | The resolution of the image in microns-per-pixel. If not provided, it is read from metadata. If that is not possible, 1 is assigned. |
| `--tile-size` | `1024` | Tile size used for pyramid image generation.|
| `--chunk-size` | `5000` | Chunk size used for lazy loading and processing the image.|

[Back to Other Modules](./core.html#other-modules){: .btn .btn-purple} [Back to top](./core){: .btn .btn-outline} 
---
layout: default
title: "Options: Core Modules"
parent: Parameters
nav_order: 5
---
{: .text-center }
# The MCMICRO pipeline

<svg xmlns="http://www.w3.org/2000/svg" xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" viewBox="0 0 439 166" inkscape:version="0.92.4 (5da689c313, 2019-01-14)" sodipodi:docname="imgmap_modules.svg" style="background-image: url(../images/pipeline-no-microscope.png)">

<defs>
<style>
svg {
          background-size: 100% 100%;
          background-repeat: no-repeat;
          max-width: 1500px;
          width: 100%
        }
        path {
            fill: transparent;
        }
</style>
</defs>

<a xlink:href="./core.html#basic">
<title>BaSic</title>
<path d="M1 161h63l-1 52-63 1Z" inkscape:connector-curvature="0" transform="translate(0 -131)"/>
</a>

<a xlink:href="./core.html#ashlar">
<title>ASHLAR</title>
<path d="m73 160 65 1-2 50H73z" inkscape:connector-curvature="0" transform="translate(0 -131)"/>
</a>

<a xlink:href="./core.html#coreograph">
<title>Coreograph</title>
<path d="M107 245h63v52h-62z" inkscape:connector-curvature="0" transform="translate(0 -131)"/>
</a>

<a xlink:href="./core.html#unmicst">
<title>UNMICST</title>
<path d="m198 161 64-1v46l-64-2z" inkscape:connector-curvature="0" transform="translate(0 -131)"/>
</a>

<a xlink:href="./core.html#s3segmenter">
<title>S3Segmenter</title>
<path d="m200 206 63 1-1 32-63-3z" inkscape:connector-curvature="0" transform="translate(0 -131)"/>
</a>

<a xlink:href="./core.html#mcquant">
<title>MCQuant</title>
<path d="M271 160h63l1 52h-63z" inkscape:connector-curvature="0" transform="translate(0 -131)"/>
</a>

<a xlink:href="./core.html#cylinter">
<title>CyLinter</title>
<path d="m271 245 62-1 2 52-63-1z" inkscape:connector-curvature="0" transform="translate(0 -131)"/>
</a>

<a xlink:href="./core.html#scimap">
<title>SCIMAP</title>
<path d="m344 159 42 1v56l-41-1z" inkscape:connector-curvature="0" transform="translate(0 -131)"/>
</a>

<a xlink:href="./core.html#minerva">
<title>Minerva</title>
<path d="M396 160h42l-1 57-41-1z" inkscape:connector-curvature="0" transform="translate(0 -131)"/>
</a>

<a xlink:href="./core.html#other-modules">
<title>Other Modules</title>
<path d="m394 242 44 1 1 54h-46z"  inkscape:connector-curvature="0" transform="translate(0 -131)"/>
</a>

</svg>

{: .text-center}
{: .fw-200}
*Click on the different modules to learn more.*

<br>

Core modules:
{: .fw-500}
{: .fs-7}
{: .text-blue-000}

{: .fs-3}
Last updated on {{ site.time | date: "%Y-%m-%d" }}.

*All modules in MCMICRO are available as standalone executable Docker containers. When running modules within MCMICRO, the inputs and outputs will be handled by the pipeline and do not need to be specified explicitly.*

## BaSiC
{: .fw-500}
{: .text-yellow-100}
*Illumination correction*

### Description

The module implements the BaSiC method for correcting uneven illumination, developed externally by [(Peng et al., 2017)](https://doi.org/10.1038/ncomms14836){:target="_blank"}. The module doesn't have any additional parameters.

### Usage

By default, MCMICRO skips this step as it requires manual inspection of the outputs to ensure that illumination correction does not introduce artifacts for downstream processing.  Add `start-at: illumination` to [workflow parameters]({{site.baseurl}}/parameters/) to request that MCMICRO runs the module.

* Example `params.yml`:

``` yaml
workflow:
  start-at: illumination
```

* Running outside of MCMICRO: [Instructions](https://github.com/labsyspharm/basic-illumination#running-as-a-docker-container){:target="_blank"}.

### Input
Unstitched images in any [BioFormats-compatible format](https://docs.openmicroscopy.org/bio-formats/latest/supported-formats.html){:target="_blank"}. Nextflow will take these from the `raw/` subdirectory within the project.

### Output
Dark-field and flat-field profiles for each unstitched image. Nextflow will write these to the `illumination/` subdirectory within the project.

[Back to top](./){: .btn .btn-outline} 

---

## ASHLAR
{: .fw-500}
{: .text-yellow-200}
*Stitching and registration*

### Description

The module performs simultaneous stiching of tiles and registration across channels. Check the [ASHLAR website](https://labsyspharm.github.io/ashlar){:target="_blank"} for the most up-to-date documentation.

### Usage

MCMICRO runs ASHLAR by default. Add `ashlar:` to [module options]({{site.baseurl}}/parameters/) to control its behavior.

* Example `params.yml`:

``` yaml
options:
  ashlar: --flip-y -c 5
```

* Default: `ashlar: -m 30`
* Running outside of MCMICRO: [ASHLAR website](https://labsyspharm.github.io/ashlar){:target="_blank"}.

### Input
* Unstitched images in any [BioFormats-compatible format](https://docs.openmicroscopy.org/bio-formats/latest/supported-formats.html){:target="_blank"}. Nextflow will take these from the `raw/` subdirectory within the project.
* [Optional] Dark-field and flat-field profiles from illumination correction. Nextflow will take these from the `illumination/` subdirectory within the project.

### Output
A pyramidal, tiled `.ome.tif`. Nextflow will write the output file to `registration/` within the project directory.

### Optional parameters for ASHLAR

|  Name; Shorthand | Description | Default|
|---|---|---|
|```--align-channel CHANNEL; -c CHANNEL```| Align images using channel number CHANNEL | Numbering starts at 0|
|```--flip-x```|Flip tile positions left-to-right to account for unusual microscope configurations | |
|```--flip-y```|Flip tile positions top-to-bottom to account for unusual microscope configurations | |
|```--flip-mosaic-x```|Flip mosaic image horizontally||
|```--flip-mosaic-y```|Flip mosaic image vertically||
|```--output-channels CHANNEL [CHANNEL...]```|Output only channels listed in CHANNELS|Numbering starts at 0|
|```--maximum-shift SHIFT; -m SHIFT```|Maximum allowed per-tile corrective shift in microns||
|```--filter-sigma SIGMA```|Width in pixels of Gaussian filter to apply to images before alignment| Default is 0 (which disables filtering)|
|```--filename-format FORMAT; -f FORMAT```|Use FORMAT to generate output filenames, with {cycle} and {channel} as required placeholders for the cycle and channel numbers | default is cycle\_{cycle}\_channel\_{channel}.tif|
|```--pyramid```|Write output as a single pyramidal TIFF||
|```--tile-size PIXELS```|Set tile width and height to PIXELS (pyramid output only)|Default is 1024|
|```--plates```|Enable mode for multi-well plates (for high-throughput screening assays)||

### Troubleshooting
Visit the [ASHLAR website](https://labsyspharm.github.io/ashlar){:target="_blank"} for troubleshooting tips.

[Back to top](./){: .btn .btn-outline} 

---

## Coreograph
{: .fw-500}
{: .text-red-300}
*TMA core detection and dearraying*

### Description
The modules uses the popular UNet deep learning architecture to identify cores within a tissue microarray (TMA). After identifying the cores, it extracts each one into a separate image to enable parallel downstream processing of all cores.

### Usage

By default, MCMICRO assumes that the input is a whole-slide image. Add `tma: true` to [module options]({{site.baseurl}}/parameters/) to indicate that the input is a TMA instead. Add `coreograph:` to [module options]({{site.baseurl}}/parameters/) to control the module behavior.

* Example `params.yml`:

``` yaml
workflow:
  tma: true
options:
  coreograph: --channel 3
```

* Running outside of MCMICRO: [Instructions](https://github.com/HMS-IDAC/UNetCoreograph){:target="_blank"}.

### Input
A fluorescence image of a tissue microarray where at least one channel is of DNA (such as Hoechst or DAPI). Nextflow will take this from the `registration/` subfolder within the project.

### Output\*

1. Individual cores as `.tif` stacks with user-selectable channel ranges
2. Binary tissue masks (saved in the 'mask' subfolder)
3. A TMA map showing the labels and outlines of each core for quality control purposes<br>
4. A text file listing the centroids of each core in the format: Y, X

{: .fs-3}
\* Nextflow will write images and masks to the `dearray/` subfolder and the TMA map to the `qc/coreo/` subfolder within the project.

![map]({{ site.baseurl }}/images/coreograph1.png)<br>

### Optional arguments to Coreograph

| Parameter | Default | Description |
| --- | --- | --- |
| `--downsampleFactor`  | Default is 5 times to match the training data |How many times to downsample the raw image file|
|`--channel` | | Which channel is fed into UNet to generate probability maps (usually DAPI) |
|`--buffer` | 2 | The extra space around a core before cropping it. A value of 2 means there is twice the width of the core added as buffer around it.|
 | `--outputChan` | |a range of channels to be exported. -1 is default and will export all channels (takes awhile). Select a single channel or a continuous range. ``--outputChan 0 10`` will export channel 0 up to and including channel 10 |
 | `--tissue` | | Coreograph will assume that its input is a whole-slide image and will work to isolate individual tissue chunks into separate files |

### Troubleshooting
A troubleshooting guide can be found within [Coreograph parameter tuning]({{site.baseurl}}/troubleshooting/tuning/coreograph.html).

[Back to top](./){: .btn .btn-outline} 

---

## UnMICST
{: .fw-500}
{: .text-red-100}
*Image segmentation - probability map generation*

### Description

UnMICST uses a convolutional neural network to annotate each pixel with the probability that it belongs to a given subcellular component (nucleus, cytoplasm, cell boundary). Check the [UnMICST website](https://labsyspharm.github.io/UnMICST-info/){:target="_blank"} for the most up-to-date documentation.

### Usage
MCMICRO applies UnMicst to all input images by default. Add `unmicst:` to [module options]({{site.baseurl}}/parameters/) to control its behavior.

* Example `params.yml`:

``` yaml
options:
  unmicst: --scalingFactor 0.5
```

* Running outside of MCMICRO: [Instructions](https://github.com/HMS-IDAC/UnMicst){:target="_blank"}.

### Input
An ``.ome.tif``, preferably flat field corrected. The model is trained on images acquired at a pixelsize of 0.65 microns/px. If your settings differ, you can upsample/downsample to some extent. Nextflow will use as input files from the `registration/` subdirectory for whole-slide images and from the `dearray/` subdirectory for tissue microarrays.

### Output \*
1. a ```.tif``` stack where the different probability maps for each class are concatenated in the Z-axis in the order: nuclei foreground, nuclei contours, and background.
2. a QC image with the DNA image concatenated with the nuclei contour probability map with suffix *Preview*

{: .fs-3}
\* Nextflow will write probability maps to the `probability-maps/unmicst/` subfolder and the previews to the `qc/unmicst/` subfolder within the project.

### Optional arguments to UnMicst

| Parameter | Default | Description |
| --- | --- | --- |
| `--tool <version>` | `unmicst-solo` | UnMicst version: *unmicst-legacy* is the old single channel model. *unmicst-solo* uses DAPI. *unmicst-duo* uses DAPI and lamin. |
| `--model` | human nuclei from DAPI | The name of the UNet model. By default, this is the human nuclei model that identifies nuclei centers, nuclei contours, and background from a DAPI channel. Other models include mouse nuclei from DAPI, and cytoplasm from stains resembling WGA |
| `--channel <number>` | `1` | The channel used to infer and generate probability maps from. If using UnMicst2, then specify 2 channels. If only 1 channel is specified, it will simply be duplicated. **NOTE: If not using default value, the 1st channel must be specified to S3segmenter as --probMapChan in --s3seg-opts**|
| `--classOrder` | None | If your training data isn't in the order 1. background, 2. contours, 3. foreground, you can specify the order here. For example, if you had trained the class order backwards, specify `--classOrder 3 2 1`. If you only have background and contours, use `--classOrder 1 2 1`. |
| `--mean <value>` | Extracted from the model | Override the trained model's mean intensity. Useful if your images are significantly dimmer or brighter. |
| `--std <value>` | Extracted from the model | Override the trained model's standard deviation intensity. Useful if your images are significantly dimmer or brighter. |
| `--scalingFactor <value>` | `1` | An upsample or downsample factor used to resize the image. Useful when the pixel sizes of your image differ from the model (ie. 0.65 microns/pixel for human nuclei model) |
| `--stackOutput` | Specified | If selected, UnMicst will write all probability maps as a single multipage tiff file. Otherwise, UnMicst will write each class as a separate file. |
| `--GPU <index>` | Automatic | Explicitly specify which GPU (1-based indexing) you want to use. Useful for running on local workstations with multiple GPUs. |

### Troubleshooting
A troubleshooting guide can be found within [UnMICST parameter tuning]({{site.baseurl}}/troubleshooting/tuning/unmicst.html) - additional information is also available on the [UnMICST website](https://labsyspharm.github.io/UnMICST-info/){:target="_blank"} .

[Back to top](./){: .btn .btn-outline} 

___

## S3segmenter
{: .fw-500}
{: .text-purple-000}
*Image segmentation - cell mask generation*

### Description

The modules applies standard watershed segmentation to probability maps to produce the final cell/nucleus/cytoplasm/etc. masks.

### Usage
By default, MCMICRO applies S3segmenter to the output of all modules that produce probability maps. Add `s3seg:` to [module options]({{site.baseurl}}/parameters/) to control its behavior..

* Example `params.yml`:

``` yaml
options:
  s3seg: --logSigma 2 10
```

### Inputs
1.  A fully-stitched and registered ``.ome.tif``, preferably flat field corrected. Nextflow will take these from the `registration/` and `dearray/` subdirectories, as approrpriate.
2.  A 3-class probability map, as derived by modules such as [UnMICST](./core.html#unmicst) or [Ilastik](./other.html#ilastik).

[S3segmenter](https://github.com/HMS-IDAC/S3segmenter){:target="_blank"} assumes that you have:
1. Acquired images of your sample with optimal acquisition settings.
2. Stitched and registered the tiles and channels respectively (if working with a large piece of tissue) and saved it as a Bioformats compatible tiff file.
3. Processed your image in some way so as to increase contrast between individual nuclei using classical or machine learning methods such as [Ilastik](./other.html#ilastik) (a random forest model) or [UnMICST](./core.html#unmicst) (a deep learning semantic segmentation model based on the UNet architecture). MCMICRO supports both.
{: .fs-3}

### Output
**1) 32-bit label masks for each compartment of the cell:**  

{: .fs-3}
  >* `nuclei.ome.tif` (nuclei) 
  >* `cytoplasm.ome.tif` (cytoplasm) 
  >* `cell.ome.tif` (whole cell)
  >* If only nuclei segmentation was carried out, `cell.ome.tif` is identical to `nuclei.ome.tif`

Nextflow saves these files to the `segmentation/` subfolder within your project.
 
**2) Two-channel quality control files with outlines overlaid on gray scale image of channel used for segmentation**  

{: .fs-3}
  >* `nucleiOutlines.tif` (nuclei),
  >* `cytoplasmOutlines.tif` (cytoplasm) 
  >* `cellOutlines.tif` (whole cell)
  >* If only nuclei segmentation was carried out, `cellOutlines.tif` is identical to `nucleiOutilnes.tif`

Nextflow saves these files to the `qc/s3seg/` subfolder within your project.

{: .fs-3}
**NOTE:** There are at least 2 ways to segment cytoplasm: i) using a watershed approach or ii) taking an annulus/ring around nuclei. Files generated using the annulus/ring method will have ‘Ring’ in the filename whereas files generated using watershed segmentation will not. It is important that these two groups of files are NOT combined and analyzed simultaneously as cell IDs will be different between them.

### Optional arguments to S3Segmenter

| Parameter | Default | Description |
| --- | --- | --- |
| `--probMapChan <index>` | `1` | which channel is used for nuclei segmentation. **Coincides with the channel used in upstream semantic segmentation modules. Must specify when different from default.**  |
| `--crop <selection>` | `noCrop` | Type of cropping: `interactiveCrop` - a window will appear for user input to crop a smaller region of the image; `plate` - this is for small fields of view such as from a multiwell plate; `noCrop`, the default, is to use the entire image |

#### Nuclei parameters:

| Parameter | Default | Description |
| --- | --- | --- |
| `--nucleiFilter <selection>` | `IntPM` | Method to filter false positive nuclei: `IntPM` - filter based on probability intensity; `Int` - filted based on raw image intensity |
| `--logSigma <value> <value>` | `3 60` | A range of nuclei diameters to search for. |

#### Cytoplasm parameters:

| Parameter | Default | Description |
| --- | --- | --- |
| `--segmentCytoplasm <selection>` | `ignoreCytoplasm` | Select whether to `segmentCytoplasm` or `ignoreCytoplasm` |
| `--CytoMaskChan <index>` | `2` | One or more channels to use for segmenting cytoplasm, specified as 1-based indices (e.g., `2` is the 2nd channel). |
| `--cytoMethod <selection>` | `distanceTransform` | The method to segment cytoplasm: `distanceTransform` - take the distance transform outwards from each nucleus and mask with the tissue mask; `ring` - take an annulus of a certain pixel size around the nucleus (see `cytoDilation`); `hybrid` - uses a combination of greyscale intensity and distance transform to more accurately approximate the extent of the cytoplasm. Similar to Cellprofiler's implementation. |
| `--cytoDilation <value>` | `5` | The number of pixels to expand from the nucleus to get the cytoplasm ring. |
| `--TissueMaskChan <index>` | Union of `probMapChan` and `CytoMaskChan` | One or more channels to use for identifying the general tissue area for masking purposes. |

### Troubleshooting
A troubleshooting guide can be found within [S3segmenter parameter tuning]({{site.baseurl}}/troubleshooting/tuning/s3seg.html).

[Back to top](./){: .btn .btn-outline} 

___

## MCQuant
{: .fw-500}
{: .text-purple-200}
*Single-cell data quantification*


### Description
The modules uses one or more segmentation masks against the original image to quantify the expression of every channel on a per-cell basis. Check the [MCQuant README](https://github.com/labsyspharm/quantification#single-cell-quantification){:target="_blank"} for the most up-to-date documentation.

### Usage
By default, MCMICRO runs MCQuant on all cell segmentation masks that match the `cell*.tif` filename pattern. Add `mcquant:` to [module options]({{site.baseurl}}/parameters/) to specify a different mask or to provide additional module-specific arguments to MCMICRO.

* Example `params.yml`:

``` yaml
options:
  mcquant: --masks cytoMask.tif nucleiMask.tif
```

* Running outside of MCMICRO: [Instructions](https://github.com/labsyspharm/quantification){:target="_blank"}.

### Inputs

1. A fully stitched and registered image in `.ome.tif` format. Nextflow will use images in the `registration/` and `dearray/` subfolders as appropriate.
2. One or more segmentation masks in `.tif` format. Nextflow will use files in the `segmentation/` subfolder within the project.
3. A `.csv` file containing a `marker_name` column specifying names of individual channels. Nextflow will look for this file in the project directory.

### Output

A cell-by-feature table mapping Cell IDs to marker expression and morphological features (including x,y coordinates).

### Optional parameters for MCQuant

| Parameter | Description |
| --- | --- |
| `--mask_props` | Space separated list of additional metrics to be calculated for every mask. This is intended for metrics that depend only on the cell mask. If the metric depends on signal intensity, use `--intensity-props` instead. See list at [https://scikit-image.org/docs/dev/api/skimage.measure.html#regionprops](https://scikit-image.org/docs/dev/api/skimage.measure.html#regionprops). |
| `--intensity_props` | Space separated list of additional metrics to be calculated for every marker separately. By default only mean intensity is calculated. If the metric doesn't depend on signal intensity, use `--mask-props` instead. See list at [https://scikit-image.org/docs/dev/api/skimage.measure.html#regionprops](https://scikit-image.org/docs/dev/api/skimage.measure.html#regionprops) Additionally available is gini_index, which calculates a single number between 0 and 1, representing how unequal the signal is distributed in each region. See https://en.wikipedia.org/wiki/Gini_coefficient. For example, to calculate the median intensity, specify `--intensity_props median_intensity`.

[Back to top](./){: .btn .btn-outline} 

___

## CyLinter
{: .fw-500}
{: .text-red-000}
*Quality control*

### Description
CyLinter is a human-in-the-loop quality control pipeline. It accepts as input the set of files generated by MCMICRO, including segmentation masks and single-cell feature tables, and returns a set of de-noised feature tables for use in downstream analyses.

### Usage
Because it requires human interactivity, CyLinter is not executed by MCMICRO directly. Instead, users are encourage to follow steps outlined on the [CyLinter website](https://labsyspharm.github.io/cylinter/){:target="_blank"} after applying MCMICRO to their data.

{: .text-center }
{: .fs-3 }
{: .fw-300 }
![Overview of CyLinter quality control software]({{ site.baseurl }}/images/cylinter_banner.png)
Screenshots depicting different phases of the CyLinter workflow.

[Back to top](./){: .btn .btn-outline} 

___

## SCIMAP
{: .fw-500}
{: .text-blue-100}

*Spatial analysis*


### Description
SCIMAP is a suite of tools that enables spatial single-cell analyses. Check the [SCIMAP website](https://scimap.xyz){:target="_blank"} for the most up-to-date documentation.

### Usage
MCMICRO allows users to automatically apply SCIMAP's clustering algorithms to the cell-by-feature table produced by MCQuant. The clustering results can be subsequently used for manual assignment of cell states. Since MCMICRO stops at MCQuant by default, users will need to explicitly request that the pipeline continues to the clustering step. MCMICRO's usage of SCIMAP doesn't have any parameters, and users are encouraged to check the [SCIMAP website](https://scimap.xyz){:target="_blank"} for more sophisticated human-in-the-loop analyses.

Add `downstream: scimap` and `stop-at: downstream` to [workflow parameters]({{site.baseurl}}/parameters/) to enable SCIMAP. Add `mcquant:` to [module options]({{site.baseurl}}/parameters/) to control its behavior.

* Example `params.yml`:

``` yaml
workflow:
  stop-at: downstream
  downstream: scimap
options:
  scimap: --csv
```

* Running outside of MCMICRO: [Instructions](https://scimap.xyz){:target="_blank"}.

### Input

A cell-by-feature table in `.csv` format, as produced by MCQuant. Nextflow will look for these tables in the `quantification/` subdirectory within the project.

### Output

1. A table of cluster assignments for each cell by the different clustering algorithms implemented within SCIMAP. These tables will be generated in `.csv` and `.h5ad` formats.
2. A set of UMAP plots for the different clustering algorithms, with individual plots written to the `plots/` subdirectory in `.pdf` format.

Nextflow will write all outputs to the `cell-states/scimap/` subdirectory within the project.

[Back to top](./){: .btn .btn-outline} 

---

## Minerva
{: .fw-500}
{: .text-green-200}
*Interactive viewing and sharing*

### Description
Minerave allows for fast, interactive viewing of multiplexed images. It also enables highlighting and effective sharing of important regions of interest among collaborators.

### Usage
MCMICRO can automatically generate un-annotated Minerva stories if users enable the [`viz` workflow parameter](https://mcmicro.org/parameters/workflow.html#viz).  

Annotated narratives must be manually generated, and users must provide MCMICRO outputs to Minerva in a separate workflow. To learn more about making Minerva stories, visit the [Minerva wiki](https://github.com/labsyspharm/minerva-story/wiki){:target="_blank"} for the most up-to-date information about the Minerva suite.

[Back to top](./){: .btn .btn-outline} 

---

## [Other modules](./other.html)

| Name | Purpose | References |
| :-- | :-- | :-- | :-- |
| [Ilastik](./other.html#ilastik) | Probability map generator | [Code](https://github.com/labsyspharm/mcmicro-ilastik) - [DOI](https://doi.org/10.1038/s41592-019-0582-9) |
| [Cypository](./other.html#ilastik) | Probability map generator (cytoplasm only) | [Code](https://github.com/HMS-IDAC/Cypository) |
| [Mesmer](./other.html#mesmer) | Instance segmentation | [Code](https://github.com/vanvalenlab/deepcell-applications) - [DOI](https://doi.org/10.1038/s41587-021-01094-0) |
| [naivestates](./other.html#naivestates) | Cell type calling with Naive Bayes | [Code](https://github.com/labsyspharm/naivestates) |
| [FastPG](./other.html#clustering) | Clustering (Louvain community detection) | [Code](https://github.com/labsyspharm/mcmicro-fastPG) - [DOI](https://www.biorxiv.org/content/10.1101/2020.06.19.159749v2) |
| [scanpy](./other.html#clustering) | Clustering (Leiden community detection) | [Code](https://github.com/labsyspharm/mcmicro-scanpy) |
| [FlowSOM](./other.html#clustering) | Clustering (Self-organizing maps) | [Code](https://github.com/labsyspharm/mcmicro-flowsom) |


# Suggest a module

Module suggestions can be made by posting to [https://forum.image.sc/](https://forum.image.sc/){:target="_blank"} and tagging your post with the `mcmicro` tag.

[Back to top](./){: .btn .btn-outline} 

{: .no_toc }

---
layout: default
title: Nextflow workflow
nav_order: 20
parent: Pipeline documentation

---

# Running the MCMICRO Pipeline

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>


## Usage
Once [installed](./installation.html), the basic pipeline execution consists of:  
1. Ensuring you have the latest version of the pipeline  
2. Using `--in` to point the pipeline at the data

``` bash
# Get the latest version of the pipeline
nextflow pull labsyspharm/mcmicro

# Run the pipeline on data (starting from the registration step through quantification, by default)
nextflow run labsyspharm/mcmicro --in path/to/my/data
```
>(Where `path/to/my/data` is replaced with your specific path.)
{: .fs-3}

[Back to top](./){: .btn .btn-outline} 

---

## Input

**At the minimum, the pipeline expects two inputs with an optional third one:**
1. `markers.csv` in the parent directory (containing [metadata with markers](./#markers))
2. [Raw images](./#raw-images) in the `raw/` subdirectory
3. (Optional) [Illumination profiles](./#optional-illumination-corrected-images) in the `illumination/` subdirectory.

{: .fs-3}
Example input directory:
```
exemplar-001
├── markers.csv
├── raw/
└── illumination/
```

<br>

### Markers
The file `markers.csv` must be in a comma-delimited format and contain a column titled `marker_name` that defines marker names of every channel:

{: .fs-3}
Example markers file:
```
cycle,marker_name
1,DNA_1
1,AF488
1,AF555
1,AF647
2,DNA_2
2,A488_background
2,A555_background
2,A647_background
3,DNA_3
3,FDX1
3,CD357
3,CD1D
```

{: .fs-3}
*All other columns are optional but can be used to specify additional metadata (e.g., known mapping to cell types) to be used by individual modules.*

<br>

### Raw images
The exemplar `raw/` files are in the open standard OME-TIFF format, but in practice your input files will be in whatever format your microscope produces. The pipeline supports all [Bio-Formats-compatible](https://docs.openmicroscopy.org/bio-formats/6.0.1/supported-formats.html){:target="_blank"} image formats, but [additional parameters may be required]({{site.baseurl}}/instructions/faq.html#q-mcmicro-doesnt-seem-to-recognize-my-file-format-how-do-i-tell-it-what-files-to-look-for).

<br>

### (Optional) Illumination corrected images
Pre-computed flat-field and dark-field illumination profiles can be placed in the `illumination/` directory. If no pre-computed profiles are available, MCMICRO can compute these using [BaSiC]({{site.baseurl}}/modules/#basic). This step is not executed by default, because proper illumination correction requires careful curation and visual inspection of the profiles produced by computational tools. After familiarizing yourself with the [general concepts] (https://en.wikipedia.org/wiki/Flat-field_correction){:target="_blank"}, the profiles can be computed by [specifying](#specifying-start-and-stop-modules) `--start-at illumination`.

[Back to top](./){: .btn .btn-outline} 

---

## Output

### Stitching and registration
[ASHLAR]({{site.baseurl}}/modules/#ashlar) is the default first step of the pipeline. ASHLAR will aggregate individual image tiles from `raw/` along with the corresponding illumination profiles to produce a stitched and registered mosaic image. 

This mosaic image will be published to the `registration/` subdirectory:
```
exemplar-001
├── markers.csv
├── raw/
├── illumination/
└── registration/
    └── exemplar-001.ome.tif
```
The output filename will be generated based on the name of the project directory.


<br>

### (Optional) TMA dearray
When working with Tissue Microarrays (TMA), [Coreograph]({{site.baseurl}}/modules/#coreograph) is used for TMA dearraying. The `registration/` folder will contain an image of the entire TMA. Use the `--tma` flag during [pipeline execution](./#parameters) to have MCMICRO identify and isolate individual cores. 

Each core will be written out into a standalone file in the `dearray/` subdirectory along with the mask specifying where in the original image the core appeared:
```
exemplar-002
├── ...
├── registration/
│   └── exemplar-002.ome.tiff
└── dearray/
    ├── 1.tif
    ├── 2.tif
    ├── 3.tif
    ├── 4.tif
    └── masks/
        ├── 1_mask.tif
        ├── 2_mask.tif
        ├── 3_mask.tif
        └── 4_mask.tif
```
All cores will then be processed in parallel by all subsequent steps.

<br>

### Segmentation
Cell segmentation is carried out in two steps. First, the pipeline generates probability maps that annotate each pixel with the probability that it belongs to a given subcellular component (nucleus, cytoplasm, cell boundary) using [UnMICST]({{site.baseurl}}/modules/#unmicst) (default) or [Ilastik]({{site.baseurl}}/modules/other.html#ilastik). The second step applies standard watershed segmentation to produce the final cell/nucleus/cytoplasm/etc. masks using [S3segmenter]({{site.baseurl}}/modules/#s3segmenter). 

The two steps will appear in `probability-maps/` and `segmentation` directories, respectively. When there are multiple modules for a given pipeline step, their results will be subdivided into additional subdirectories:
```
exemplar-001
├── ...
├── probability-maps/
│   ├── ilastik/
│   │   └── exemplar-001_Probabilities.tif
│   └── unmicst/
│       └── exemplar-001_Probabilities_0.tif
└── segmentation/
    ├── ilastik-exemplar-001/
    │   ├── cell.ome.tif
    │   └── nuclei.ome.tif
    └── unmicst-exemplar-001/
        ├── cell.ome.tif
        └── nuclei.ome.tif
```

<br>

### Quantification
The final step, [MCQuant]({{site.baseurl}}/modules/#mcquant), combines information in segmentation masks, the original stitched image and `markers.csv` to produce *Spatial Feature Tables* that summarize the expression of every marker on a per-cell basis, alongside additional morphological features (cell shape, size, etc.). 

Spatial Feature Tables will be published to the `quantification/` directory:
```
exemplar-001
├── ...
├── segmentation/
└── quantification/
    ├── ilastik-exemplar-001_cell.csv
    └── unmicst-exemplar-001_cell.csv
```

There is a direct correspondence between the `.csv` filenames and the filenames of segmentation masks. For example, `quantification/unmicst-exemplar-001_cell.csv` quantifies `segmentation/unmicst-exemplar-001/cell.ome.tif`.


<br>

### Quality control
Additional information during pipeline execution will be written to the `qc/` directory, by both individual modules and the pipeline itself.
```
exemplar-002
├── ...
└── qc
    ├── params.yml
    ├── provenance/
    │   ├── probmaps:ilastik (1).log
    │   ├── probmaps:ilastik (1).sh
    │   ├── probmaps:unmicst (1).log
    │   ├── probmaps:unmicst (1).sh
    │   ├── quantification (1).log
    │   ├── quantification (1).sh
    │   └── ...
    ├── coreo/
    ├── s3seg/
    └── unmicst/
```

**While the exact content of the `qc/` directory will depend on which modules were executed, two sources of information can always be found there:**  

1. The file `params.yml` will contain the full record of module versions and all parameters used to run the pipeline. This allows for full reproducibility of future runs.
1. The `provenance/` subdirectory will contain exact commands (`.sh`) executed by individual modules, as well the output (`.log`) of these commands.  

\* *You should retain `params.yml` and `provenance/` because these files enable full reproducibility of a pipeline run. The other QC files can be safely deleted once the quality of the outputs has been verified and no more parameter tuning is expected.*
{: .fs-3}
{: .fw-500}

<br>

**The remaining directories will contain QC files specific to individual modules:**

1. When working with TMAs, `coreo/` will contain `TMA_MAP.tif`, a mask showing where in the original TMA image the segmented cores reside.
1. If UnMicst was used to generate probability maps, `unmicst/` will contain thumbnail previews, allowing for a quick assessment of their quality.
1. After segmentation, two-channel tif files containing DAPI and nuclei/cell/cytoplasm outlines will reside in `s3seg/`, allowing for a visual inspection of segmentation quality.
 
[Back to top](./){: .btn .btn-outline} 

---

## Parameters
The following parameters control the pipeline as a whole. These can be specified on the command line using the double-dash format (e.g., `--in`), or inside a [YAML file](./#using-yaml-parameter-files) as key-value pairs. 

### Required arguments:

| Parameter | Description |
| --- | --- |
| `--in /local/path` | Location of the data |

### Optional arguments:

| Parameter | Default | Description |
| --- | --- | --- |
| `--sample-name <myname>` | Directory name supplied to `--in` | The name of the experiment/specimen |
| `--start-at <step>` | `registration` | Name of the first step to be executed by the pipeline. Must be one of `illumination`, `registration`, `dearray` (TMA only), `probability-maps`, `segmentation`, `quantification`, `cell-states` |
| `--stop-at <step>` | `quantification` | Name of the final step to be executed by the pipeline. Spans the same vocabulary as `--start-at`. |
| `--tma` | Omitted | If specified, MCMICRO treats input data as a TMA. If omitted, the input is assumed to be a whole-slide image. |
| `--ilastik-model <model.ilp>` | None | A custom `.ilp` file to be used as the classifier model for ilastik. |
| `--probability-maps <choice>` | `unmicst` | Which module(s) to use for probability map computation. Module names should be delimited with a comma without spaces, e.g., `--probability-maps unmicst,ilastik` |

<br>

### Specifying path for intermediate files
By default Nextflow writes intermediate files to a `work/` directory inside whatever location you initiate a pipeline run from. Use `-w` flag to provide a different location. 

``` bash
nextflow run labsyspharm/mcmicro --in /path/to/my-data -w /path/to/work/
```

<br>

### Specifying start and stop modules
By default, the pipeline starts from the registration step ([ASHLAR]({{site.baseurl}}/modules/#ashlar)), proceeds through [UnMICST]({{site.baseurl}}/modules/#unmicst), [S3segmenter]({{site.baseurl}}/modules/#s3segmenter), and stops after executing the quantification [MCQuant]({{site.baseurl}}/modules/#mcquant) step. 

Use `--start-at` and `--stop-at` flags to execute any contiguous section of the pipeline instead. Any subdirectory name listed in the [directory structure](./#directory-structure) is a valid starting and stopping point.  


``` bash
# If you already have a pre-stitched TMA image, start at the dearray step
nextflow run labsyspharm/mcmicro --in path/to/exemplar-002 --tma --start-at dearray

# If you want to run the illumination profile computation and registration only
nextflow run labsyspharm/mcmicro --in path/to/exemplar-001 --start-at illumination --stop-at registration
```
**Note:** Starting at any step beyond registration requires pre-computed output of the previous steps placed at the correct location in the project directory.
{: .fs-3}

<br>

### Specifying module-specific parameters
The pipeline provides a sensible set of [default parameters for individual modules]({{site.baseurl}}/modules/). To change these use <br> `--ashlar-opts`, `--unmicst-opts`, `--s3seg-opts` and `--quant-opts`. 

For example: ```nextflow run labsyspharm/mcmicro --in /path/to/my-data --ashlar-opts '-m 35 --pyramid' ``` will provide `-m 35 --pyramid` as additional command line arguments to ASHLAR.

*Go to [modules]({{site.baseurl}}/modules/) for a list of options available for each module.*

<br>

### Using YAML parameter files
As the number of custom flags grows, providing them all on the command line can become unwieldy. Instead, parameter values can be stored in a YAML file, which is then provided to Nextflow using `-params-file`. 

*The general rules of thumb for composing YAML files:*
1. Anything that would appear as `--param value` on the command line should be `param: value` in the YAML file.
1. Anything that would appear as `--flag` on the command line should be `flag: true` in the YAML file.

**Note:** The above only applies to double-dashed arguments (which are passed to the pipeline). The single-dash arguments (like `-profile`) cannot be moved to YAML, because they are given to nextflow; the pipeline never sees them.
{: .fs-3}

**For example, consider the following command:**
``` bash
nextflow run labsyspharm/mcmicro --in /data/exemplar-002 --tma --start-at dearray --ashlar-opts '-m 35 --pyramid'
```

All double-dashed arguments can be moved to a YAML file (e.g., **myexperiment.yml**) using the rules above:
``` yaml
in: /data/exemplar-002
tma: true
start-at: dearray
ashlar-opts: -m 35 --pyramid
```

The YAML file can then be fed to the pipeline via
``` bash
nextflow run labsyspharm/mcmicro -params-file myexperiment.yml
```


[Find more information about the YAML syntax here.](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html){:target="_blank"}

[Back to top](./){: .btn .btn-outline} 

---

## Directory Structure
Upon the full successful completion of a pipeline run, the directory structure will follow Fig. 1A in the [MCMICRO manuscript](https://doi.org/10.1038/s41592-021-01308-y){:target="_blank"}:

{: .fs-3 }
{: .fw-300 }
**Note:** *This directory should correspond directly to the Nextflow workflow. For the Galaxy workflow, the intermediaries and output files should be identical, but the organization of the files within directories and the filenames will be different.*

| Schematic | Directory&nbsp;Structure |
| :-: | :-- |
| <img src="{{ site.baseurl }}/images/Fig1.png" alt="MCMICRO" width="400"/> | <code>exemplar-002<br>├── markers.csv<br>├── raw/<br>├── illumination/<br>├── registration/<br>├── dearray/<br>├── probability-maps/<br>├── segmentation/<br>├── quantification/<br>└── qc/<br></code> |

{: .text-center}
The name of the parent directory (e.g., `exemplar-002`) is assumed by the pipeline to be the sample name.


Visual inspection of [quality control](./#quality-control) (`qc/`) files is recommended after completing the run. Depending on the modules used, directories `coreo/`, `unmicst/` and `s3seg/` may contain `.tif` images for inspection. 

[Back to top](./){: .btn .btn-outline} 



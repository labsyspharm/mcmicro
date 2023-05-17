---
layout: default
title: Workflow
parent: Parameters
nav_order: 1
---

# Workflow parameters  
Parameters under the namespace `workflow` regulate the function of the pipeline as a whole. 
{: .fs-5}
{: .fw-400}

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---



By default, the pipeline starts from the registration step ([ASHLAR]({{site.baseurl}}/parameters/core.html#ashlar)), proceeds through [UnMICST]({{site.baseurl}}/parameters/core.html#unmicst), [S3segmenter]({{site.baseurl}}/parameters/core.html#s3segmenter), and stops after executing the quantification [MCQuant]({{site.baseurl}}/parameters/core.html#mcquant) step.
{: .fs-5}
{: .fw-500}


## `start-at` 
Name of the first step to be executed by the pipeline
{: .fs-4}
{: .fw-300}

  * **Valid values:** `illumination`, `registration`, `background` (background only), `dearray` (TMA only), `segmentation`, `watershed`, `quantification`, `downstream`
  * **Default:** `registration`
  * **Example:** 
  
``` yaml
workflow:
  start-at: segmentation
```


## `stop-at`
Name of the final step to be executed by the pipeline
{: .fs-4}
{: .fw-300}

  * **Valid values:** `illumination`, `registration`, `background` (background only), `dearray` (TMA only), `segmentation`, `quantification`, `downstream`
  * **Default:** `quantification`
  * **Example:**

``` yaml
workflow:
  stop-at: downstream
```


### Additional examples: Specifying start and stop modules

Use `start-at` and `stop-at` workflow parameters to execute any contiguous section of the pipeline. Remember, by default the pipeline will run from ASHLAR through MCQuant.
{: .fs-4}
{: .fw-300}

**Example 1: Running illumination correction and registration only**

``` yaml
workflow:
  start-at: illumination
  stop-at: registration
```

**Example 2: Start by dearraying an already-registered TMA image**

``` yaml
workflow:
  tma: true
  start-at: dearray
```

**Note:** Starting at any step beyond registration requires pre-computed output of the previous steps placed at the correct location in the project directory.
{: .fs-3}


## `tma`
  If `true`, MCMICRO treats input data as a TMA. If `false`, the input is assumed to be a whole-slide image
{: .fs-4}
{: .fw-300}

  * **Valid values:** `true`, `false`
  * **Default:** `false`
  * **Example:**

``` yaml
workflow:
  tma: true
```

## `segmentation-channel` 
  One or more channels to use for segmentation, specified using 1-based indexing; values will be forwarded to all segmentation modules
{: .fs-4}
{: .fw-300}

  * **Valid values:** one or more positive integers, each separated with a space
  * **Default:** `1`
  * **Example:**

``` yaml
workflow:
  segmentation-channel: 1 5
```

## `segmentation-recyze` 
  Whether the image should be reduced to the channels specified in `segmentation-channel` prior to being provided to the segmentation modules.
{: .fs-4}
{: .fw-300}

  * **Valid values:** `true`, `false`
  * **Default:** `false`
  * **Example:**

``` yaml
workflow:
  segmentation-channel: 5
  segmentation-recyze: true
```

## `ilastik-model`

  A custom `.ilp` file to be used as the classifier model for ilastik
{: .fs-4}
{: .fw-300}

  * **Valid values:** A full path to any file
  * **Default:** None
  * **Example:** 

``` yaml
workflow:
  ilastik-model: /full/path/to/mymodel.ilp
```

## `segmentation`

  A list of segmentation modules to run
{: .fs-4}
{: .fw-300}

  * **Valid values:** One or more of `unmicst`, `ilastik`, `mesmer`, `cypository`, specified as a YAML list
  * **Default:** `unmicst`
  * **Example:**
  
``` yaml
workflow:
  segmentation: [unmicst, ilastik]
```

## `downstream`

  A list of downstream modules to run
{: .fs-4}
{: .fw-300}

  * **Valid values:** One or more of `naivestates`, `scimap`, `fastpg`, `scanpy`, `flowsom`
  * **Default:** `scimap`
  * **Example:**

``` yaml
workflow:
  downstream: [scanpy, flowsom]
```

## `viz` 

  Whether to generate a vizualization with Auto-Minerva
{: .fs-4}
{: .fw-300}

  * **Valid values:** `true`, `false`
  * **Default:** `false`
  * **Example:** 

``` yaml
workflow:
  viz: true
```

## `qc-files`
  Wheter QC files should be copied, moved or symbolically linked from work directories to the project directory
{: .fs-4}
{: .fw-300}

  * **Valid values:** `copy`, `move`, `symlink`
  * **Default:** `copy`
  * **Example:**

``` yaml
workflow:
  qc-files: move
```

## `background`

  Wheter background subtraction should be performed, and the computed intermediates used in further processing
{: .fs-4}
{: .fw-300}

  * **Valid values:** `true`, `false`
  * **Default:** `false`
  * **Example:**

``` yaml
workflow:
  background: true
```
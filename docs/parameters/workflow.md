---
layout: default
title: Workflow
parent: Parameters
nav_order: 1
---

{: .no_toc }

<details open markdown="block">
  <summary>
    Table of contents
  </summary>
  {: .text-delta }
1. TOC
{:toc}
</details>

---

## Workflow parameters

### `start-at` 

  Name of the first step to be executed by the pipeline
  
  * **Valid values:** `illumination`, `registration`, `background` (background only), `dearray` (TMA only), `segmentation`, `watershed`, `quantification`, `downstream`
  * **Default:** `registration`
  * **Example:** 
  
``` yaml
workflow:
  start-at: segmentation
```

### `stop-at`
  Name of the final step to be executed by the pipeline

  * **Valid values:** `illumination`, `registration`, `background` (background only), `dearray` (TMA only), `segmentation`, `quantification`, `downstream`
  * **Default:** `quantification`
  * **Example:**

``` yaml
workflow:
  stop-at: downstream
```

### `tma`
  If `true`, MCMICRO treats input data as a TMA. If `false`, the input is assumed to be a whole-slide image

  * **Valid values:** `true`, `false`
  * **Default:** `false`
  * **Example:**

``` yaml
workflow:
  tma: true
```

### `segmentation-channel` 
  One or more channels to use for segmentation, specified using 1-based indexing; values will be forwarded to all segmentation modules

  * **Valid values:** one or more positive integers, each separated with a space
  * **Default:** `1`
  * **Example:**

``` yaml
workflow:
  segmentation-channel: 1 5
```

### `segmentation-recyze` 
  Whether the image should be reduced to the channels specified in `segmentation-channel` prior to being provided to the segmentation modules.

  * **Valid values:** `true`, `false`
  * **Default:** `false`
  * **Example:**

``` yaml
workflow:
  segmentation-channel: 5
  segmentation-recyze: true
```

### `ilastik-model`

  A custom `.ilp` file to be used as the classifier model for ilastik

  * **Valid values:** A full path to any file
  * **Default:** None
  * **Example:** 

``` yaml
workflow:
  ilastik-model: /full/path/to/mymodel.ilp
```

### `segmentation`

  A list of segmentation modules to run

  * **Valid values:** One or more of `unmicst`, `ilastik`, `mesmer`, `cypository`, specified as a YAML list
  * **Default:** `unmicst`
  * **Example:**
  
``` yaml
workflow:
  segmentation: [unmicst, ilastik]
```

### `downstream`

  A list of downstream modules to run

  * **Valid values:** One or more of `naivestates`, `scimap`, `fastpg`, `scanpy`, `flowsom`
  * **Default:** `scimap`
  * **Example:**

``` yaml
workflow:
  downstream: [scanpy, flowsom]
```

### `viz` 

  Whether to generate a vizualization with Auto-Minerva

  * **Valid values:** `true`, `false`
  * **Default:** `false`
  * **Example:** 

``` yaml
workflow:
  viz: true
```

### `qc-files`
  Wheter QC files should be copied, moved or symbolically linked from work directories to the project directory

  * **Valid values:** `copy`, `move`, `symlink`
  * **Default:** `copy`
  * **Example:**

``` yaml
workflow:
  qc-files: move
```

### `background`

  Wheter background subtraction should be performed, and the computed intermediates used in further processing

  * **Valid values:** `true`, `false`
  * **Default:** `false`
  * **Example:**

``` yaml
workflow:
  background: true
```
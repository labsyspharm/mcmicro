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

# Workflow parameters

## `start-at` 

  * **Description:** Name of the first step to be exeucted by the pipeline
  * **Valid values:** `illumination`, `registration`, `dearray` (TMA only), `segmentation`, `watershed`, `quantification`, `downstream`
  * **Default:** `registration`
  * **Example:** 
  
``` yaml
workflow:
  start-at: segmentation
```

* `stop-at`
  * **Description:** Name of the final step to be executed by the pipeline
  * **Valid values:** `illumination`, `registration`, `dearray` (TMA only), `segmentation`, `quantification`, `downstream`
  * **Default:** `quantification`
  * **Example:** `stop-at: downstream`
* `tma` 
  * **Description:** If `true`, MCMICRO treats input data as a TMA. If `false`, the input is assumed to be a whole-slide image
  * **Valid values:** `true`, `false`
  * **Default:** `false`
  * **Example:** `tma: true`
* `segmentation-channel` 
  * **Description:** One or more channels to use for segmentation, specified using 1-based indexing; values will be forwarded to all segmentation modules
  * **Valid values:** one or more positive integers, each separated with a space
  * **Default:** `1`
  * **Example:** `segmentation-channel: 1 5`
* `ilastik-model` 
  * **Description:** A custom `.ilp` file to be used as the classifier model for ilastik
  * **Valid values:** A full path to any file
  * **Default:** None
  * **Example:** `ilastik-model: /home/users/me/mymodel.ilp`
* `segmentation`
  * **Description:** A list of segmentation modules to run
  * **Valid values:** One or more of `unmicst`, `ilastik`, `mesmer`, `cypository`, specified as a YAML list
  * **Default:** `unmicst`
  * **Example:** `segmentation: [unmicst, ilastik]`
* `downstream`
  * **Descriont:** A list of downstream modules to run
  * **Valid values:** One or more of `naivestates`, `scimap`, `fastpg`, `scanpy`, `flowsom`
  * **Default:** `scimap`
  * **Example:** `downstream: [scanpy, flowsom]`
* `viz` 
  * **Description:** Whether to generate a vizualization with Auto-Minerva
  * **Valid values:** `true`, `false`
  * **Default:** `false`
  * **Example:** `viz: true`
* `qc-files`
  * **Description:** Wheter QC files should be copied, moved or symbolically linked from work directories to the project directory
  * **Valid values:** `copy`, `move`, `symlink`
  * **Default:** `copy`
  * **Example:** `qc-files: move`

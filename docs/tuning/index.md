---
layout: default
title: Parameter Tuning
nav_order: 25
has_children: true
---

Some modules of the pipeline are non-parameteric (e.g., quantification). Other modules have a very small number of parameters, with default values being appropriate for the vast majority of possible inputs.
The biggest effect on image processing is expected to be from segmentation parameters, where incorrect parameter values can lead to over- or under-segmentation, resulting in problems for downstream analysis.
Here, we provide in-depth guides describing expected output from segmentation-related modules, as well as how the user may go about tuning parameters to obtain the best possible results.


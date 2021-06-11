---
layout: default
title: Image Processing Steps
nav_order: 30
has_children: true
---

# Directory structure
Upon the full successful completion of a pipeline run, the directory structure will follow Fig. 1A in the [mcmicro manuscript](https://www.biorxiv.org/content/10.1101/2021.03.15.435473v1):

| Schematic | Directory&nbsp;Structure |
| :-: | :-- |
| <img src="images/Fig1.png" alt="MCMICRO" width="400"/> | <code>exemplar-002<br>├── markers.csv<br>├── raw/<br>├── illumination/<br>├── registration/<br>├── dearray/<br>├── probability-maps/<br>├── segmentation/<br>├── quantification/<br>└── qc/<br></code> |

The name of the parent directory (e.g., `exemplar-002`) is assumed by the pipeline to be the sample name.


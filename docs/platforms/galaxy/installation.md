---
layout: default
title: Installation
nav_order: 10
parent: Galaxy
---

# Installation

## Install Galaxy

To install [Galaxy](https://galaxyproject.org/): 
```
git clone https://github.com/galaxyproject/galaxy.git
cd galaxy
./run.sh
```

This command will clone the Galaxy Github repository, install all needed dependencies in a python virtual environment, and start up a local galaxy server. Navigate to [http://localhost:8080](http://localhost:8080) to access the server from your browser.


## Install the MCMICRO Tools
Each of the MCMICRO modules can be installed as a [galaxy tool](https://galaxyproject.org/admin/tools/add-tool-from-toolshed-tutorial/) from the [Main Galaxy Toolshed](http://toolshed.g2.bx.psu.edu/). 
- [Basic Illumination](https://toolshed.g2.bx.psu.edu/view/perssond/basic_illumination/fd8dfd64f25e)
- [ASHLAR](https://toolshed.g2.bx.psu.edu/view/perssond/ashlar/b3054f3d42b2)
- [Coreograph](https://toolshed.g2.bx.psu.edu/view/perssond/coreograph/99308601eaa6)
- [UnMicst](https://toolshed.g2.bx.psu.edu/view/perssond/unmicst/6bec4fef6b2e)
- [S3Segmenter](https://toolshed.g2.bx.psu.edu/view/perssond/s3segmenter/37acf42a824b)
- [quantification](https://toolshed.g2.bx.psu.edu/view/perssond/quantification/928db0f952e3)
- [naivestates](https://toolshed.g2.bx.psu.edu/view/perssond/naivestates/a62b0c62270e)

## Upload the MCMICRO Galaxy workflow
Two workflows are currently available for running MCMICRO in Galaxy.
- [MCMICRO Tissue Microarray Workflow](https://github.com/ohsu-comp-bio/cycIF-galaxy/blob/master/workflows/Galaxy-Workflow-MCMICRO_TMA_v1.0.0.ga)
- [MCMICRO Whole Slide Tissue Workflow](https://github.com/ohsu-comp-bio/cycIF-galaxy/blob/master/workflows/Galaxy-Workflow-MCMICRO_Tissue_v1.0.0.ga)

To upload a workflow, naviate to the Workflow page, click Upload, select the workflow file (`.ga`), and Import workflow.
<img src="{{ site.baseurl }}/images/galaxy-wf-upload.png" />

## Need Help?
For more help installing galaxy, try the [Get Galaxy](https://galaxyproject.org/admin/get-galaxy/) docs. Interested in running Galaxy with Docker? Check out [Galaxy Docker Image](https://github.com/bgruening/docker-galaxy-stable) and [Tutorials](https://training.galaxyproject.org/training-material/topics/admin/tutorials/galaxy-docker/slides.html#1).

---
layout: default
title: Galaxy workflow
nav_order: 21
has_children: true
---

# MCMICRO Galaxy Workflow

## Install Galaxy

Install [Galaxy](https://galaxyproject.org/): 
```
git clone https://github.com/galaxyproject/galaxy.git
cd galaxy
./run.sh
```

This command will clone the Galaxy Github repository, install all needed dependencies in a python virtual environment, and start up a local galaxy server. Navigate to http://localhost:8080 to access the server from your browser.


Install the MCMICRO [tools](https://galaxyproject.org/admin/tools/add-tool-from-toolshed-tutorial/) from the [Main Galaxy Toolshed](http://toolshed.g2.bx.psu.edu/). 
- [Basic Illumination](https://toolshed.g2.bx.psu.edu/view/perssond/basic_illumination/fd8dfd64f25e)
- [ASHLAR](https://toolshed.g2.bx.psu.edu/view/perssond/ashlar/b3054f3d42b2)
- [Coreograph](https://toolshed.g2.bx.psu.edu/view/perssond/coreograph/99308601eaa6)
- [UnMicst](https://toolshed.g2.bx.psu.edu/view/perssond/unmicst/6bec4fef6b2e)
- [S3Segmenter](https://toolshed.g2.bx.psu.edu/view/perssond/s3segmenter/37acf42a824b)
- [quantification](https://toolshed.g2.bx.psu.edu/view/perssond/quantification/928db0f952e3)
- [naivestates](https://toolshed.g2.bx.psu.edu/view/perssond/naivestates/a62b0c62270e)

Upload the MCMICRO Galaxy workflow.
- [MCMICRO Tissue Microarray Workflow](https://github.com/ohsu-comp-bio/cycIF-galaxy/blob/master/workflows/Galaxy-Workflow-MCMICRO_TMA_v1.0.0.ga)
- [MCMICRO Whole Slide Tissue Workflow](https://github.com/ohsu-comp-bio/cycIF-galaxy/blob/master/workflows/Galaxy-Workflow-MCMICRO_Tissue_v1.0.0.ga)


## Running MCMICRO Galaxy

The Galaxy workflow provides a sensible set of [default parameters for individual modules](parameter-reference.html). These parameters can be modified and saved in the workflow using the Workflow Editor or can be changed at runtime.
<img src="{{ site.baseurl }}/images/galaxy-wf.png" />

### Import input data

[Upload](https://galaxyproject.org/tutorials/upload/) the input datasets from your local filesystem or export the input datasets from a Data Library to a Galaxy history.
<img src="{{ site.baseurl }}/images/galaxy-inputs.png" />

### Invoke the Workflow

From the Workflow page, select the workflow to run:
<img src="{{ site.baseurl }}/images/galaxy-wf-select.png" />

Select the inputs for the workflow. Change any tool parameters, if desired. Run the workflow.
<img src="{{ site.baseurl }}/images/galaxy-run.png" />

Learn more about the [Galaxy Project](https://galaxyproject.org/) and try out [Tutorials](https://galaxyproject.org/learn/).


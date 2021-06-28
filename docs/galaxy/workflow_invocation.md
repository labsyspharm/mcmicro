---
layout: default
title: Running MCMICRO
nav_order: 20
parent: Galaxy workflow
---

# Running MCMICRO in Galaxy

The Galaxy workflow provides a sensible set of [default parameters for individual modules](parameter-reference.html). These parameters can be modified and saved in the workflow using the Workflow Editor or can be changed at runtime.
<img src="{{ site.baseurl }}/images/galaxy-wf.png" />

## Import input data

[Upload](https://galaxyproject.org/tutorials/upload/) the input datasets from your local filesystem or export the input datasets from a Data Library to a Galaxy history.
<img src="{{ site.baseurl }}/images/galaxy-inputs-select.png" />
<img src="{{ site.baseurl }}/images/galaxyinputs.png" />

## Create a collection
Some workflows require a collection or list of datasets as input. To create a collection list, select the image datasets to include.
<img src="{{ site.baseurl }}/images/galaxy-build-collection.png" />

Order the datasets, name, and create the collection.
<img src="{{ site.baseurl }}/images/galaxy-order-collection.png" />

Now the image datasets will appear in the history as a single collection list.
<img src="{{ site.baseurl }}/images/galaxy-collection-history.png" />

## Invoke the Workflow

From the Workflow page, select the workflow to run:
<img src="{{ site.baseurl }}/images/galaxy-wf-select.png" />

Select the inputs for the workflow. Change any tool parameters, if desired. Run the workflow.
<img src="{{ site.baseurl }}/images/galaxy-run.png" />

The successfully invoked workflow will schedule jobs and populate the history with the results for each tool. 
<img src="{{ site.baseurl }}/images/galaxy-run.png" />

## Need Help?
For help, take a look at the [Galaxy tutorials](https://galaxyproject.org/learn/), [FAQ](https://galaxyproject.org/support/), or ask a question on [GalaxyHelp](https://help.galaxyproject.org/).
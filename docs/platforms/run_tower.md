---
layout: default
title: Nextflow Tower
nav_order: 20
parent: Platforms
---

## What is Nextflow Tower?

[Nextflow Tower](https://seqera.io/tower/) is a web-based platform for managing and monitoring Nextflow pipelines. Tower extends the capabilities of Nextflow by providing a centralized, web-based interface for executing, visualizing, and managing pipelines. With Tower, users can easily track the progress of their pipelines, monitor resource usage, and manage access control. Additionally, Tower provides a comprehensive audit trail, allowing users to track the history of pipeline executions and view the details of each run. Tower is highly scalable, making it well suited for use in large-scale compute environments, such as high-performance computing (HPC) clusters, cloud computing platforms, and multi-user data centers.

If you’re new to Tower, we recommend this 15-minute introduction at a suggested 1.5x playback speed:

<iframe width="560" height="315" src="https://www.youtube.com/embed/zS_hbXQmHbI" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>


Nextflow Tower Enterprise and Nextflow Tower cloud are products of Seqera Labs. If your organization has a deployment of Nextflow Tower, the introduction provided here demonstrate how to run MCMICRO pipelines in Tower on AWS Batch, and the benefits provided.

If you don't have a Tower license, you can still benefit from Nextflow Tower Cloud as a monitoring interface for your local runs.


## Setting up MCMICRO for Nextflow Tower

### Launchpad

To setup MCMICRO in the Tower Launchpad: 
<div style="position: relative; padding-bottom: 55.21472392638037%; height: 0;"><iframe src="https://www.loom.com/embed/d91bda11d10c40ee8c014e13bcd055fe" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe></div>

### Nextflow config

MCMICRO pipelines run on Tower require the `standard` and `tower` config profiles to be added. 
- The [`standard` config](https://github.com/labsyspharm/mcmicro/blob/master/config/nf/docker.config) ensures Docker is enabled. 
- The [`tower` config](https://github.com/labsyspharm/mcmicro/blob/master/config/nf/tower.config) sets minimium compute requirements of 4 CPUs per task attempt, 16 GB of memory per task attempt  with a maximum of 3 task attempts. If a process fails it is resubmitted with double the resources. The maximum resources deployed on a third task attempt will therefore be 12 CPUs and 48 GB memory.

These settings can be updated by adding to the Nextflow config file (under 'Advanced options')

```groovy
process {
   cpus = {4 * task.attempt}
   memory = {16.GB * task.attempt}
   maxRetries = 3
   errorStrategy = 'retry'
}
```

If have GPU instances enabled in your compute environment and wish to take advantage of these in MCMICRO (eg for UnMicst) you will need to add the following line to the Nextflow config file (under 'Advanced options'):
```
process.accelerator = [request:1, type:'GPU']
```

## Running MCMICRO on Nextflow tower

### Staging data

### Launching exemplar-001

### Monitoring runs

### Outputs



## Benchmarking MCMICRO performance

Running MCMICRO on AWS Batch or similar compute environments 

## Launching MCMICRO through the Nextflow Tower CLI


## Monitoring local MCMICRO runs with Nextflow Tower



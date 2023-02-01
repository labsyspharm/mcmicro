---
layout: default
title: Nextflow Tower
nav_order: 20
parent: Platforms
---

## What is Nextflow Tower?

<img src="{{ site.baseurl }}/images/tower-run.jpg" />

[Nextflow Tower](https://seqera.io/tower/) is a web-based platform for managing and monitoring Nextflow pipelines. Tower extends the capabilities of Nextflow by providing a centralized, web-based interface for executing, visualizing, and managing pipelines. With Tower, users can easily track the progress of their pipelines, monitor resource usage, and manage access control. Additionally, Tower provides a comprehensive audit trail, allowing users to track the history of pipeline executions and view the details of each run. Tower is highly scalable, making it well suited for use in large-scale compute environments, such as high-performance computing (HPC) clusters, cloud computing platforms, and multi-user data centers.

If you’re new to Tower, we recommend this 15-minute introduction from nf-core/bytesize at a suggested 1.5x playback speed:

[![nf-core/bytesize episode on Nextflow Tower](https://img.youtube.com/vi/zS_hbXQmHbI/0.jpg)](https://www.youtube.com/watch?v=zS_hbXQmHbI)


Nextflow Tower Enterprise and Nextflow Tower cloud are products of Seqera Labs. If your organization has a deployment of Nextflow Tower, the introduction provided here demonstrate how to run MCMICRO pipelines in Tower on AWS Batch, and the benefits provided.

If you don't have a Tower license, you can still benefit from Nextflow Tower Cloud as a monitoring interface for your local runs.


## Setting up MCMICRO for Nextflow Tower

### Launchpad

Watch the following short (3m 27s) introduction on adding MCMICRO to the Tower Launchpad:

[![MCMCRO Tower Launchpad setup](https://cdn.loom.com/sessions/thumbnails/d91bda11d10c40ee8c014e13bcd055fe-with-play.gif)](https://www.loom.com/share/d91bda11d10c40ee8c014e13bcd055fe)

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



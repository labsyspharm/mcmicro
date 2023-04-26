---
layout: default
title: Nextflow Tower
nav_order: 6
parent: Platforms
---


## What is Nextflow Tower?

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

You will need to stage the data you wish to process with MCMICRO to a cloud bucket that your compute environment will be able to access.

To stage the provided exemplar data you may run the MCMICRO pipeline in Tower:
- Add `exemplar.nf` as the 'Main script` to be run 
- Add `process.container = 'ubuntu'` to the Nextflow config (A container is currently not specified for the processes in `exemplar.nf`)
- Specify `name` (the name of the example dataset to stage) and `path` (the S3 URI where the data should be staged to as pipeline parameters). For example:
    ```
    name: exemplar-001
    path: s3://mc2-mcmicro-project-tower-bucket/examples/exemplar-001/
    ```

### Launching exemplar-001

In the Tower web interface open the launchpad for the pipeline as created above. Or start from the Quick Launch and add pipeline details

First complete the Pipeline Parameters box.
Minimally `in`, A URI to the input directory is required
Provide additional arguments as required

For example to run `exemplar-002` from registration to downstream with scanpy we would add:


```
in: 's3://mc2-mcmicro-project-tower-bucket/testing/output/exemplar-002/'
tma: true
start-at: 'registration'
stop-at: 'downstream'
downstream: ['scanpy']
```
Click ***Launch*** to start the run.


[![Launching MCMICRO on Tower](https://cdn.loom.com/sessions/thumbnails/9229341356274008a8dce2ebade1923c-with-play.gif)](https://www.loom.com/share/9229341356274008a8dce2ebade1923c)


### Monitoring runs

Tower provides a rich web interface for monitoring Nextflow runs including task status and progress, connfiguration settings, aggregated run metrics, and access to execution

### Outputs



## Benchmarking MCMICRO performance

The table below shows example aggregated statistics for MCMICRO runs on AWS Batch compute environments in  Nextflow Tower. 

| Dataset | Start at | Stop at | Processes | Wall time† | CPU time | Estimated cost‡ | Spot/On Demand | GPU |
| --- | --- | ---| --- | --- | --- | --- | --- | --- |
| [exemplar-001](https://mcmicro.org/datasets/#exemplar-data-for-testing-mcmicro)</br>Single core of TMA | registration | quantification | 4 | 14 m 25 s |0.1 CPU hours | $0.003 | Spot | True |
| [exemplar-002](https://mcmicro.org/datasets/#exemplar-data-for-testing-mcmicro)</br>4 core TMA | registration | quantification | 18 |33 m 16 s | 0.9 CPU hours| $0.02 | Spot | True |
| [exemplar-002](https://mcmicro.org/datasets/#exemplar-data-for-testing-mcmicro)</br>4 core TMA | registration | quantification | 18 | 50 m 45 s | 3.7 CPU hours | $0.089 | Spot | False |
| [exemplar-002](https://mcmicro.org/datasets/#exemplar-data-for-testing-mcmicro)</br>4 core TMA | registration | quantification | 18 | 28 m 55 s | 0.9 CPU hours | $0.085 | On Demand | True |
| [exemplar-002](https://mcmicro.org/datasets/#exemplar-data-for-testing-mcmicro)</br>4 core TMA | registration | quantification | 18 |45 m 4 s | 3.2 CPU hours | $0.193  | On Demand | False |
| [EMIT TMA22](https://www.synapse.org/#!Synapse:syn22345748/wiki/609239)</br>123 core TMA </br>(pre-dearrayed) | segmentation | downstream</br>[`fastpg`,</br>`flowsom`,</br>`scanpy`] | 738 | 1 h 25 m 56 s | 17.5 CPU hours | $0.506 | Spot | True |
| [EMIT TMA22](https://www.synapse.org/#!Synapse:syn22345748/wiki/609239)</br>123 core TMA </br>(pre-dearrayed) | segmentation | downstream</br>[`fastpg`,</br>`flowsom`,</br>`scanpy`] | 738 | 31 m 58 s | 108.3 CPU hours| $2.816 | Spot | False |
| [EMIT TMA22](https://www.synapse.org/#!Synapse:syn22345748/wiki/609239)</br>123 core TMA </br>(pre-dearrayed) | segmentation | downstream</br>[`fastpg`,</br>`flowsom`,</br>`scanpy`] | 738 | 1 h 2 m 45 s | 26.1 CPU hours | $6.556 | On Demand | True |
| [EMIT TMA22](https://www.synapse.org/#!Synapse:syn22345748/wiki/609239)</br>123 core TMA </br>(pre-dearrayed) | segmentation | downstream</br>[`fastpg`,</br>`flowsom`,</br>`scanpy`] | 738 | 37 m 52 s  | 167.3 CPU hours | $8.387  | On Demand | False |
| CyCIF Tonsil  | segmentation |quantification  | 3 succeeded</br>2 retried | 2 h 32 m 15 s  | 8.9 CPU hours | $0.201  | On Demand | True |

† Wall time (or total running time) includes time for an instance to be allocated 

‡ The cost is only based on estimated computation usage and does not currently take into account storage or associated network costs.

We can see that Spot instance runs can be around 4 times cheaper than those run in On Demand instances, And that GPU instances reduces run cost by around half due to the faster process times.
A 10-16 times cost reduction can be realised by moving from On Demand with no GPU to Spot instances with GPU enabled.

Increasing resources to 16 CPUs and 32 GB memory does not provide a speed or cost improvement.

Nextflow Tower 22.3 now provides per-process configuration optimization. Optimization was performed by launching MCMICRO `exemplar-002` on a `m5a.4xlarge` EC2 instance (16 CPUs, 64 GB memory, no GPU) and monitoring with Tower 22.3. The following optimization was suggested

```
process {
  withName: 'registration:ashlar' {
    cpus = 2
    memory = 1.GB
  }
  withName: 'dearray:coreograph' {
    cpus = 2
    memory = 2.GB
  }
  withName: 'segmentation:worker' {
    cpus = 4
    memory = 3.GB
  }
  withName: 'segmentation:s3seg' {
    cpus = 4
    memory = 2.GB
  }
  withName: 'quantification:mcquant' {
    cpus = 2
    memory = 1.GB
  }
}
```

This could be further optimized by only specifying GPU instances for process that can use the GPU, and manual inspection of the resource usage graphs to reduce process resource allocations where not fully utilized.

```
process {
  withName: 'registration:ashlar' {
    cpus = 1
    memory = 1.GB
  }
  withName: 'dearray:coreograph' {
    cpus = 1
    memory = 2.GB
  }
  withName: 'dearray:roadie:runTask' {
    cpus = 1
    memory = 1.GB
  }
  withName: 'segmentation:worker' {
    accelerator = [request:1, type:'GPU']
    cpus = 1
    memory = 3.GB
  }
  withName: 'segmentation:s3seg' {
    cpus = 3
    memory = 2.GB
  }
  withName: 'quantification:mcquant' {
    cpus = 1
    memory = 1.GB
  }
}
```


| Dataset | Wall time | CPU time | Estimated cost | Spot/On Demand | GPU | CPUs | Memory | CPU efficiency | Memory efficiency |
| --- | --- | ---| --- | --- | --- | --- | --- | --- | --- |
| [exemplar-002](https://mcmicro.org/datasets/#exemplar-data-for-testing-mcmicro)</br>4 core TMA |33 m 16 s | 0.9 CPU hours| $0.02 | Spot | True | 4 CPUs | 16 GB | 9.8% | 22.27% | 
| [exemplar-002](https://mcmicro.org/datasets/#exemplar-data-for-testing-mcmicro)</br>4 core TMA | 28 m 25 s| 3.4 CPU hours| $0.072 | Spot | True | 16 CPUs | 32 GB | 4.93% | 7.23% |
| [exemplar-002](https://mcmicro.org/datasets/#exemplar-data-for-testing-mcmicro)</br>4 core TMA | 40 m 55 s | 0.7 CPU hours | $0.023 | Spot | True | suggested optimization | suggested optimization | 28.22  | 35.22 |
| [exemplar-002](https://mcmicro.org/datasets/#exemplar-data-for-testing-mcmicro)</br>4 core TMA | 54 m  25 s | 0.5 CPU hours | $0.014 | Spot | True | further optimization | further optimization | 28.22  | 35.22 |


## Monitoring local MCMICRO runs with Nextflow Tower

Nextflow Tower can be used to [monitor locally launched Nextflow runs](https://tower.nf/welcome) by adding setting the `TOWER_ACCESS_TOKEN` and adding `-with-tower` to the `nextflow run` command.

For example

```
$ export TOWER_ACCESS_TOKEN=<YOUR ACCESS TOKEN>
$ nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-001 --path .
$ nextflow run labsyspharm/mcmicro --in exemplar-001/ -with-tower

N E X T F L O W  ~  version 22.04.4z
Launching `https://github.com/labsyspharm/mcmicro` [tender_magritte] DSL2 - revision: 9abb9d65ac [master]
Downloading plugin nf-tower@1.4.0
Monitor the execution with Nextflow Tower using this url https://tower.nf/user/adam-taylor/watch/2ow41Nbe6jZ0vb
executor >  local (4)
[-        ] process > illumination                    -
[01/0b0b11] process > registration:ashlar             [100%] 1 of 1 ✔
[-        ] process > dearray:coreograph              -
[e9/bfa63f] process > segmentation:worker (unmicst-1) [100%] 1 of 1 ✔
[69/47d6c4] process > segmentation:s3seg (1)          [100%] 1 of 1 ✔
[66/d76f58] process > quantification:mcquant (1)      [100%] 1 of 1 ✔
[-        ] process > downstream:worker               -
[-        ] process > viz:roadie:runTask              -
[-        ] process > viz:autominerva                 -
Completed at: 01-Feb-2023 18:57:12
Duration    : 8m 46s
CPU hours   : 0.1
Succeeded   : 4
```
The link to tower.nf provides access to the Tower interface to monitor the run

![https://cdn.loom.com/sessions/thumbnails/657cb8f4ca774d2bb760c386eee1cbfc-with-play.gif](https://cdn.loom.com/sessions/thumbnails/657cb8f4ca774d2bb760c386eee1cbfc-with-play.gif)
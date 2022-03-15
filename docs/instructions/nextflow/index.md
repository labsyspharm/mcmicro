---
layout: default
title: Nextflow workflow
nav_order: 20
parent: How to Use
description: ""
# permalink: /
last_modified_date: 2021-03-28
---

# Quick start

1. [Install](./installation.html) Nextflow and Docker\*. Check with `nextflow run hello` and `docker images` to make sure both are functional.

{: .text-center }
{: .fs-3 }
{: .fw-300 }
\* *Harvard Medical School users using the O2 Compute Cluster should not install Docker - learn more [here](../advanced-topics/run-O2.html).*	

2. [Download]({{ site.baseurl }}/datasets/datasets.html) exemplar data. E.g., `nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-001 --path .` to download to current directory.
3. [Run](./nextflow-running.html) MCMICRO on the exemplars. E.g., `nextflow pull labsyspharm/mcmicro` followed by `nextflow run labsyspharm/mcmicro --in exemplar-001` to execute in current directory. 

On an average workstation, it takes approximately 5-10 minutes to process exemplar-001 from start to finish. Exemplar-002 is substantially larger, and its processing takes 30-40 minutes on an average workstation.


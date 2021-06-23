---
layout: default
title: Documentation
nav_order: 20
description: ""
# permalink: /
last_modified_date: 2021-03-28
---

# Quick start

1. [Install](http://mcmicro.org/installation.html) nextflow and Docker. Check with `nextflow run hello` and `docker images` to make sure both are functional.
3. [Download](http://mcmicro.org/installation.html#exemplar-data) exemplar data. E.g., `nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-001 --path .` to download to current directory.
4. [Run](http://mcmicro.org/running-mcmicro.html) mcmicro on the exemplars. E.g., `nextflow pull labsyspharm/mcmicro` followed by `nextflow run labsyspharm/mcmicro --in exemplar-001` to execute in current directory. 

On an average workstation, it takes approximately 5-10 minutes to process exemplar-001 from start to finish. Exemplar-002 is substantially larger, and its processing takes 30-40 minutes on an average workstation.


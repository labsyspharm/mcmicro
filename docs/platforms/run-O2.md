---
layout: default
title: O2 cluster (HMS only)
nav_order: 14
parent: Platforms
---

# Running mcmicro on the O2 compute cluster

**O2 is a [high-performance cluster](https://harvardmed.atlassian.net/wiki/spaces/O2/overview) at Harvard Medical School (HMS). Non-HMS users can safely ignore this page.**

There are several important caveats to run mcmicro on O2.

1. [Installation]({{ site.baseurl }}/tutorial/installation.html) only requires Nextflow. Docker is not needed, because O2 uses Singularity to execute module containers, and Singularity is already available on O2.

1. Please ensure that Java is available by running `module load java`.

1. If your account is not in the `lsp` group (type `groups` to check), then please run the following command to prepare your environment: `nextflow run labsyspharm/mcmicro/setup/O2ext.nf`

1. When working with [exemplars]({{ site.baseurl }}/datasets/datasets.html), please download your own copy to `/n/scratch3/users/.../$USER/` (where `$USER` is your eCommons ID and `...` is its first letter).

## O2 execution

To run the pipeline on O2, the following additional steps are required:
1. If your account is in the `lsp` group, please add the flag `-profile O2`. Use `-profile O2,WSI` and `-profile O2,TMA` for very large whole-slide images (WSIs) and tissue microarrays (TMAs), respectively. The profiles differ in the amount of resources requested for each module.
1. If your account is not in the `lsp` group, please use `-profile O2ext`. Similarly, use `-profile O2ext,WSI` and `-profile O2ext,TMA` for WSIs and TMAs.
1. To avoid running over on your disk quota, it is also recommended to use `/n/scratch3` for holding the `work/` directory. Furthermore, `/n/scratch3` is faster than `/home` or `/n/groups`, so jobs will complete faster. 

Compose an `sbatch` script that encapsulates resource requests, module loading and the `nextflow` command into a single entity. Create a `submit_mcmicro.sh` file based on the following template:

```
#!/bin/sh
#SBATCH -p short
#SBATCH -J mcmicro              
#SBATCH -o mcmicro-%J.log
#SBATCH -t 0-12:00
#SBATCH --mem=8G
#SBATCH --mail-type=END         # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=user@university.edu   # Email to which notifications will be sent

module purge
module load java
/home/$USER/bin/nextflow run labsyspharm/mcmicro --in /n/scratch3/users/${USER:0:1}/$USER/exemplar-001 -profile O2 -w /n/scratch3/users/${USER:0:1}/$USER/work
```
replacing relevant fields (e.g., `user@university.edu`) with your own values.

The pipeline run can then be kicked off with `sbatch submit_mcmicro.sh`.

### Requesting O2 resources

The default profiles `WSI` and `TMA` establish reasonable defaults for O2 resource requests. These will work for most scenarios, but individual projects may also have custom time and memory requirements. To overwrite the defaults, compose a new config file (e.g., `myproject.config`) specifying the desired custom requirements using [process selectors](https://www.nextflow.io/docs/latest/config.html#process-selectors). For example, to request 128GB of memory and 96 hours in the `medium` queue for ASHLAR, one would specify
```
process{
  withName:ashlar {
    queue  = 'medium'
    time   = '96h'
    memory = '128G'
  }
}
```
Use [existing profiles](https://github.com/labsyspharm/mcmicro/blob/master/config/tma.config) as examples. Once `myproject.config` is composed, it can be provided to a `nextflow run` command using the `-c` flag:

```
nextflow run labsyspharm/mcmicro --in /path/to/exemplar-001 -profile O2 -c myproject.config
```

Note that `-profile` is still needed because it defines additional configurations, such as where to find the container modules. `myproject.config` simply overrides a portion of the fields in the overall profile.

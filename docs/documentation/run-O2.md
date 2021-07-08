---
layout: default
title: O2 compute cluster
nav_order: 71
parent: Platform-specific Steps
---

# Running mcmicro on the O2 compute cluster

**O2 is a [high-performance cluster](https://harvardmed.atlassian.net/wiki/spaces/O2/overview) at Harvard Medical School (HMS). Non-HMS users can safely ignore this page.**

To run mcmicro on O2, your account must be in the `lsp` group to have proper permissions to run the module containers. There are several other important caveats.

1. [Installation](installation.html) only requires Nextflow. Docker is not needed, because O2 uses Singularity to execute module containers.

1. When working with [exemplars]({{ site.baseurl }}/datasets.html), please download your own copy to `/n/scratch3/users/.../$USER/` (where `$USER` is your eCommons ID and `...` is its first letter). A fully processed version is available in `/n/groups/lsp/cycif/exemplars`, but this version is meant to serve as a reference only. The directory permissions are set to read-only, preventing your pipeline run from writing its output there.

## O2 execution

To run the pipeline on O2, four additional steps are required:
1. You must load the necessary O2 modules.
1. All pipeline calls need to have the flag `-profile O2`. Use `-profile O2large` or `-profile O2massive` for large or very large whole-slide images, respectively. Use `-profile O2TMA` for TMAs. The profiles differ in the amount of resources requested for each module.
1. To avoid running over on your disk quota, it is also recommended to use `/n/scratch3` for holding the `work/` directory. Furthermore, `n/scratch3` is faster than `/home` or `/n/groups`, so jobs will complete faster. 
1. Instruct Nextflow to generate an execution report in a central location by adding `-with-report "/n/groups/lsp/mcmicro/reports/$USER-$(date -Is).html"` to your Nextflow command. This will help the staff evaluate resource usage and success/failure rates  .

Compose an `sbatch` script that encapsulates resource requests, module loading and the `nextflow` command into a single entity. Create a `submit_mcmicro.sh` file based on the following template:

```
#!/bin/sh
#SBATCH -p short
#SBATCH -J nextflow_O2              
#SBATCH -o run.o
#SBATCH -e run.e
#SBATCH -t 0-12:00
#SBATCH --mem=8G
#SBATCH --mail-type=END         # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=user@university.edu   # Email to which notifications will be sent

module purge
module load java
/home/$USER/bin/nextflow run labsyspharm/mcmicro --in /n/scratch3/users/${USER:0:1}/$USER/exemplar-001 -profile O2 -w /n/scratch3/users/${USER:0:1}/$USER/work -with-report "/n/groups/lsp/mcmicro/reports/$USER-$(date -Is).html"
```
replacing relevant fields (e.g., `user@university.edu`) with your own values.

The pipeline run can then be kicked off with `sbatch submit_mcmicro.sh`.

### Requesting O2 resources

The default profiles `O2`, `O2large` and `O2massive` establish reasonable defaults for O2 resource requests. These will work for most scenarios, but individual projects may also have custom time and memory requirements. To overwrite the defaults, compose a new config file (e.g., `myproject.config`) specifying the desired custom requirements using [process selectors](https://www.nextflow.io/docs/latest/config.html#process-selectors). For example, to request 128GB of memory and 96 hours in the `medium` queue for ASHLAR, one would specify
```
process{
  withName:ashlar {
    queue  = 'medium'
    time   = '96h'
    memory = '128G'
  }
}
```
Use [existing profiles](https://github.com/labsyspharm/mcmicro/blob/master/config/large.config) as examples. Once `myproject.config` is composed, it can be provided to a `nextflow run` command using the `-c` flag:

```
nextflow run labsyspharm/mcmicro --in /path/to/exemplar-001 -profile O2 -c myproject.config
```

Note that `-profile` is still needed because it defines additional configurations, such as where to find the container modules. `myproject.config` simply overrides a portion of the fields in the overall profile.

---
layout: default
title: Installation
nav_order: 10
parent: Nextflow workflow
---

# Installation

## Install Nextflow

If not already installed, install Java: [https://adoptopenjdk.net/](https://adoptopenjdk.net/)

Install [Nextflow](https://www.nextflow.io/): `curl -s https://get.nextflow.io | bash`

This command will create a `nextflow` executable in the current directory. To simplify usage, consider moving this executable to a directory that is available on `$PATH`. One common place for this is a `bin/` directory in your home folder:

``` bash
mkdir -p ~/bin                                      # Creates a bin directory in the home folder
mv nextflow ~/bin                                   # Moves nextflow to that directory
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc   # Make the directory accessible on $PATH
source ~/.bashrc                                    # Reload the shell configuration
```

Verify that Nextflow is accessible by going to your home directory (`cd ~`) and typing `nextflow` on the command line.

## Install Docker*

Install [Docker](https://docs.docker.com/install/). Ensure that the Docker engine is running by typing `docker images`. If the engine is running, it should return a (possibly empty) list of container images currently downloaded to your system.

{: .text-center }
{: .fs-3 }
{: .fw-300 }
\* *Harvard Medical School users using the O2 Compute Cluster should not install Docker - learn more [here](./advanced-topics/run-O2.html).*	

<br>

Ready to run??
{: .fw-500}
{: .fs-7}
{: .text-grey-dk-250}

Beginners, start with the [tutorial]({{site.baseurl}}/tutorial/tutorial.html){: .btn .btn-outline .btn-arrow }

Experienced users can go to the [Nextflow Reference Sheet](./){: .btn .btn-outline .btn-arrow }
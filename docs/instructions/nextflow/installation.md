---
layout: default
title: Installation
nav_order: 10
parent: Nextflow workflow
---

# Installation

## Install Nextflow

If not already installed, install Java: [https://adoptopenjdk.net/](https://adoptopenjdk.net/){:target="_blank"}
<style>
  code {
    white-space : pre-wrap !important;
    word-break: break-word;
  }
  details > summary {
    color: #00B0E9;
    font-weight: bold;
  }
</style>

<details>

<summary>Expand to see troubleshooting tips related to Java</summary>

<div markdown="1">
> * If nextflow has trouble interacting with your java, we recommend checking the version number with `java --version`  
	
> * Some errors have been occurring with version numbers with four components (i.e. 11.0.14.1). If your version has four components, consider downloading an archived version, such as "11.0.14+9", from [https://adoptium.net/archive.html?variant=openjdk11](https://adoptium.net/archive.html?variant=openjdk11){:target="_blank"} as a temporary solution until this issue is resolved.
	
</div>
</details>

Install [Nextflow](https://www.nextflow.io/){:target="_blank"}: `curl -s https://get.nextflow.io | bash`

>This command will create a `nextflow` executable in the current directory. To simplify usage, consider moving this executable to a directory that is available on `$PATH`. One common place for this is a `bin/` directory in your home folder:

``` bash
mkdir -p ~/bin                                      # Creates a bin directory in the home folder
mv nextflow ~/bin                                   # Moves nextflow to that directory
echo $SHELL                                   	    # Determine what shell is used by your terminal 
```

> If your terminal uses `bash`, the following commands should work as is.  
> Replace `.bashrc` with `.zshrc` in these commands, if your terminal uses `zsh` instead (often the case on Mac OS X).

``` bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc   # Make the directory accessible on $PATH
source ~/.bashrc                                    # Reload the shell configuration
```

Verify that Nextflow is accessible by going to your home directory (`cd ~`) and typing `nextflow` on the command line. This should automatically print the help menu.

## Install Docker*

Install [Docker](https://docs.docker.com/install/){:target="_blank"}. Ensure that the Docker engine is running by typing `docker run hello-world`. If the engine is running, you should see "This message shows that your installation appears to be working correctly." in the output.

{: .text-center }
{: .fs-3 }
{: .fw-300 }
\* *Harvard Medical School users using the O2 Compute Cluster should not install Docker - learn more [here](../advanced-topics/run-O2.html).*	

<br>

Ready to run??
{: .fw-500}
{: .fs-7}
{: .text-grey-dk-250}

Beginners, start with the [tutorial]({{site.baseurl}}/tutorial/tutorial.html){: .btn .btn-outline .btn-arrow }

Experienced users can go to the [MCMICRO Reference Sheet](./){: .btn .btn-outline .btn-arrow }

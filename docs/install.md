# Installation

Install [Nextflow](https://www.nextflow.io/): `curl -s https://get.nextflow.io | bash`

This command will create a `nextflow` executable in the current directory. To simplify usage, consider moving this executable to a directory that is available on `$PATH`. One common place for this is a `bin/` directory in your home folder:

``` bash
mkdir -p ~/bin                                      # Creates a bin directory in the home folder
mv nextflow ~/bin                                   # Moves nextflow to that directory
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc   # Make the directory accessible on $PATH
source ~/.bashrc                                    # Reload the shell configuration
```

Verify that Nextflow is accessible by going to your home directory (`cd ~`) and typing `nextflow` on the command line.

## Additional steps for local installation
* Install [Docker](https://docs.docker.com/install/). Ensure that the Docker engine is running by typing `docker images`. If the engine is running, it should return a (possibly empty) list of container images currently downloaded to your system.
* (Optional) If working with TMAs, you will need MATLAB 2018a or later. MATLAB has to be available on `$PATH`, so it can be executed by typing `matlab` on the command line. Additionally, you will need to install Coreograph locally by running `nextflow run labsyspharm/mcmicro/setup.nf`.

FROM gitpod/workspace-python:latest

# Install Java and OpenCV
RUN sudo apt-get update && \
    sudo apt-get install -y openjdk-13-jre python3-opencv && \
    sudo rm -rf /var/lib/apt/lists/*

# Additional packages for Roadie scripts
RUN pip install \
  threadpoolctl \
  sklearn \
  tifffile \
  zarr \
  scikit-image \
  ome_types \
  palom

# Install Nextflow
RUN curl -s https://get.nextflow.io | bash && \
    sudo mv nextflow /usr/bin

# Download exemplar-001
RUN cd /workspace && \
    nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-001 && \
    rm -rf /workspace/work

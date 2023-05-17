FROM gitpod/workspace-python:2023-02-27-14-39-56

# Install Java and OpenCV
RUN sudo apt-get update && \
    sudo apt-get install -y openjdk-13-jre python3-opencv && \
    sudo rm -rf /var/lib/apt/lists/*

# Additional packages for Roadie scripts
RUN pip install --no-cache-dir \
  threadpoolctl \
  sklearn \
  pandas \
  tifffile \
  zarr \
  scikit-image \
  ome_types \
  palom

# Install Nextflow
RUN curl -s https://get.nextflow.io | bash && \
    sudo mv nextflow /usr/bin

# Download exemplar-001
RUN sudo mkdir -p /data && \
    sudo chown gitpod:gitpod /data && \
    cd /workspace && \
    nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-001 && \
    rm -rf work

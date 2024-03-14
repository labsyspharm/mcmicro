FROM gitpod/workspace-full-vnc:2023-08-09-14-26-44

# Install Java, OpenCV, and QT5
RUN sudo apt-get update && \
    sudo apt-get install -y openjdk-19-jre \
        python3-opencv \
        qtbase5-dev \
        qtchooser \
        qt5-qmake \
        qtbase5-dev-tools && \
    sudo rm -rf /var/lib/apt/lists/*

# Python packages for Napari and Roadie
RUN pip install --no-cache-dir \
  "napari[all]" \
  threadpoolctl \
  scikit-learn \
  pandas \
  tifffile \
  zarr \
  scikit-image \
  ome_types \
  palom

# Let pyjnius find that JRE without the full JDK installed
ENV JAVA_HOME=/usr/lib/jvm/java-19-openjdk-amd64

# Install Nextflow
RUN curl -s https://get.nextflow.io | bash && \
    sudo mv nextflow /usr/bin

# Download exemplar-001
RUN sudo mkdir -p /data && \
    sudo chown gitpod:gitpod /data && \
    cd /workspace && \
    nextflow run labsyspharm/mcmicro/exemplar.nf --name exemplar-001 --path /data && \
    rm -rf work

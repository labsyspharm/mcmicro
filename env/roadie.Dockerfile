FROM python:3.9

RUN apt-get update && \
  apt-get install -y python3-opencv && \
  rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir \
  threadpoolctl \
  sklearn \
  pandas \
  tifffile \
  zarr \
  scikit-image \
  ome_types \
  palom

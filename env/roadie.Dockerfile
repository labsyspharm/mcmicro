FROM python:3.9

RUN apt-get update && \
  apt-get install -y python3-opencv && \
  rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir \
  threadpoolctl \
  scikit-learn \
  pandas \
  tifffile==2023.3.15 \
  zarr \
  scikit-image \
  ome_types>=0.4.2 \
  palom

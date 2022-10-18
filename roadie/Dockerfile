FROM python:3.9

RUN apt-get update && apt-get install -y python3-opencv

RUN python -m pip install \
  threadpoolctl \
  sklearn \
  tifffile \
  zarr \
  scikit-image \
  ome_types \
  palom

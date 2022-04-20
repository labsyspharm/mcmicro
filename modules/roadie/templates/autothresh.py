#!/usr/bin/env python

import tifffile

tiff = tifffile.TiffFile('image.ome.tif')
print("Loaded image with the following dimensions:")
print(tiff.series[0].shape)

#!/usr/bin/env python

import sys
import tifffile
import zarr
import numpy as np
import scipy.stats
import sklearn.mixture

def auto_threshold(img):

    assert img.ndim == 2

    yi, xi = np.floor(np.linspace(0, img.shape, 200, endpoint=False)).astype(int).T
    # Slice one dimension at a time. Should generally use less memory than a meshgrid.
    img = img[yi]
    img = img[:, xi]
    img_log = np.log(img[img > 0])
    gmm = sklearn.mixture.GaussianMixture(3, max_iter=1000, tol=1e-6)
    gmm.fit(img_log.reshape((-1,1)))
    means = gmm.means_[:, 0]
    _, i1, i2 = np.argsort(means)
    mean1, mean2 = means[[i1, i2]]
    std1, std2 = gmm.covariances_[[i1, i2], 0, 0] ** 0.5

    x = np.linspace(mean1, mean2, 50)
    y1 = scipy.stats.norm(mean1, std1).pdf(x) * gmm.weights_[i1]
    y2 = scipy.stats.norm(mean2, std2).pdf(x) * gmm.weights_[i2]

    lmax = mean2 + 2 * std2
    lmin = x[np.argmin(np.abs(y1 - y2))]
    if lmin >= mean2:
        lmin = mean2 - 2 * std2
    vmin = max(np.exp(lmin), img.min(), 0)
    vmax = min(np.exp(lmax), img.max())

    return vmin, vmax

# The Nextflow wrapper will overwrite $input_image with a filename
path = sys.argv[1] if len(sys.argv) >= 2 else "$input_image"

print(f"Opening image: {path}")
tiff = tifffile.TiffFile(path)

# Verify image dimensionality
ndim = tiff.series[0].ndim
if ndim != 3: raise Exception(f"Can't handle {ndim}-dimensional images")

# Get smallest pyramid level that's at least 200 in both dimensions.
level_series = next(
    level for level in reversed(tiff.series[0].levels)
    if all(d >= 200 for d in level.shape[1:])
)
zarray = zarr.open(level_series.aszarr())
print("Image shape: ", zarray.shape)

# Additional information about the value range
scale = np.iinfo(zarray.dtype).max if np.issubdtype(zarray.dtype, np.integer) else 1
signed = not np.issubdtype(zarray.dtype, np.unsignedinteger)

# Auto-threshold channel by channel
out = open("output.csv", "w")
out.write("Channel,vmin,vmax\\n")
for ci in range(zarray.shape[0]):
    print(f"Analyzing channel {ci + 1}")
    img = zarray[ci]
    if signed and img.min() < 0:
        print("  WARNING: Ignoring negative pixel values", file=sys.stderr)
    vmin, vmax = auto_threshold(img)
    vmin /= scale
    vmax /= scale
    out.write(f"{ci},{vmin},{vmax}\\n")

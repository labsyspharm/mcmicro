import json
import numpy as np
import ome_types
import scipy.stats
import sklearn.mixture
import sys
import threadpoolctl
import tifffile
import zarr
import argparse
import os

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


def main(in_path, out_path):

    threadpoolctl.threadpool_limits(1)

    print(f"opening image: {in_path}", file=sys.stderr)
    tiff = tifffile.TiffFile(in_path)
    ndim = tiff.series[0].ndim
    if ndim == 2:
        # FIXME This can be handled easily (promote to 3D array), we just need a
        # test file to make sure we're doing it right.
        raise Exception("Can't handle 2-dimensional images (yet)")
    elif ndim == 3:
        pass
    else:
        raise Exception(f"Can't handle {ndim}-dimensional images")
    # Get smallest pyramid level that's at least 200 in both dimensions.
    level_series = next(
        level for level in reversed(tiff.series[0].levels)
        if all(d >= 200 for d in level.shape[1:])
    )
    zarray = zarr.open(level_series.aszarr())
    signed = not np.issubdtype(zarray.dtype, np.unsignedinteger)

    print(f"reading metadata", file=sys.stderr)
    try:
        ome = ome_types.from_xml(tiff.pages[0].tags[270].value)
        ome_px = ome.images[0].pixels
        pixel_ratio = ome_px.physical_size_x_quantity / ome_px.physical_size_y_quantity
        if not np.isclose(pixel_ratio, 1):
            print(
                "WARNING: Non-square pixels detected. Using only X-size to set scale bar.",
                file=sys.stderr,
            )
        pixels_per_micron = 1 / ome_px.physical_size_x_quantity.to("um").magnitude
        channel_names = [c.name for c in ome_px.channels]
        for i, n in enumerate(channel_names):
            if not n:
                channel_names[i] = f"Channel {i + 1}"
    except:
        print(
            "WARNING: Could not read OME metadata. Story will use generic channel names and\n"
            "    the scale bar will be omitted.",
            file=sys.stderr,
        )
        pixels_per_micron = None
        channel_names = [f"Channel {i + 1}" for i in range(zarray.shape[0])]

    story = {
        "sample_info": {
            "name": "",
            "rotation": 0,
            "text": "",
            "pixels_per_micron": pixels_per_micron,
        },
        "groups": [],
        "waypoints": [],
    }

    color_cycle = 'ffffff', 'ff0000', '00ff00', '0000ff'

    scale = np.iinfo(zarray.dtype).max if np.issubdtype(zarray.dtype, np.integer) else 1
    for gi, idx_start in enumerate(range(0, zarray.shape[0], 4), 1):
        idx_end = min(idx_start + 4, zarray.shape[0])
        channel_numbers = range(idx_start, idx_end)
        channel_defs = []
        for ci, color in zip(channel_numbers, color_cycle):
            print(
                f"analyzing channel {ci + 1}/{zarray.shape[0]}", file=sys.stderr
            )
            img = zarray[ci]
            if signed and img.min() < 0:
                print("  WARNING: Ignoring negative pixel values", file=sys.stderr)
            vmin, vmax = auto_threshold(img)
            vmin /= scale
            vmax /= scale
            channel_defs.append({
                "color": color,
                "id": ci,
                "label": channel_names[ci],
                "min": vmin,
                "max": vmax,
            })
        story["groups"].append({
            "label": f"Group {gi}",
            "channels": channel_defs,
        })

    with open(out_path, 'w') as fout:
        json.dump(story, fout)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--in', type=str, required=True, help="Input Image Path")
    parser.add_argument('--out', type=str, required=False, help="Output JSON Path")
    args = parser.parse_args()

    # Automatically infer the output filename, if not specified
    in_path = vars(args)['in']
    out_path = args.out
    if out_path is None:
        tokens = os.path.basename(in_path).split(os.extsep)
        if len(tokens) < 2:       stem = in_path
        elif tokens[-2] == "ome": stem = os.extsep.join(tokens[0:-2])
        else:                     stem = os.extsep.join(tokens[0:-1])
        out_path = stem + ".json"

    main(in_path, out_path)
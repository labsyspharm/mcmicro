import argparse
import pathlib

import ome_types
import palom.pyramid
import palom.reader


def detect_pixel_size(img_path):
    try:
        metadata = ome_types.from_tiff(img_path)
        pixel_size = metadata.images[0].pixels.physical_size_x
    except Exception as err:
        print(err)
        print()
        print('Pixel size detection using ome-types failed')
        pixel_size = None
    return pixel_size


def _file(path):
    path = pathlib.Path(path)
    if path.is_file(): return path
    else: raise FileNotFoundError(path.resolve())


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--in',
        nargs='+',
        type=_file,
        required=True,
        help="Input Image Paths"
    )
    parser.add_argument('--out', type=str, required=False, help="Output Image Path")
    args = parser.parse_args()

    in_paths = vars(args)['in']
    # Automatically infer the output filename, if not specified
    if args.out is None:
        in_path = in_paths[0]
        stem = in_path.stem
        out_path = in_path.parent / f"{stem}.ome.tif"
    else:
        out_path = pathlib.Path(args.out)
    # pixel data is read into RAM lazily, cannot overwrite input file
    assert out_path not in in_paths

    # Detect pixel size in ome-xml
    pixel_size = detect_pixel_size(in_path)
    if pixel_size is None: pixel_size = 1

    # Use palom to pyramidize the input image
    readers = [palom.reader.OmePyramidReader(in_path) for in_path in in_paths]
    mosaics = [reader.pyramid[0] for reader in readers]
    palom.pyramid.write_pyramid(
        mosaics, out_path, downscale_factor=2, pixel_size=pixel_size
    )

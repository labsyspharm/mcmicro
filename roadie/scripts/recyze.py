import math
import sys
import tifffile
import zarr
import numpy as np
from ome_types import from_tiff, to_xml
from pathlib import Path
import argparse
import os
import uuid

class PyramidWriter:

    def __init__(
            self, _in_path, _out_path, _channels, _nuclear_channels, _membrane_channels, _max_projection, _x, _y, _x2, _y2, _w, _h, scale=2, tile_size=1024, peak_size=1024,
            verbose=False
    ):
        if tile_size % 16 != 0:
            raise ValueError("tile_size must be a multiple of 16")
        self.in_path = Path(_in_path)
        self.in_tiff = tifffile.TiffFile(self.in_path, is_ome=False)
        self.in_data = zarr.open(self.in_tiff.series[0].aszarr())
        self.out_path = Path(_out_path)
        self.metadata = from_tiff(self.in_path)
        self.max_projection = _max_projection

        self.tile_size = tile_size
        self.peak_size = peak_size
        self.scale = scale
        if self.in_data[0].ndim == 3:  # Multi-channel image
            self.single_channel = False
            if _channels:
                if max(_channels) >= self.in_data[0].shape[0]:
                    print("Channel out of range", file=sys.stderr)
                    sys.exit(1)
                else:
                    self.channels = _channels
            else:
                self.channels = np.arange(self.in_data[0].shape[0], dtype=int).tolist()
            if _nuclear_channels:
                if max(_nuclear_channels) >= self.in_data[0].shape[0]:
                    print("Nuclear channel out of range", file=sys.stderr)
                    sys.exit(1)
                else:
                    self.nuclear_channels = _nuclear_channels
            else:
                self.nuclear_channels = []
            if _membrane_channels:
                if max(_membrane_channels) >= self.in_data[0].shape[0]:
                    print("Membrane channel out of range", file=sys.stderr)
                    sys.exit(1)
                else:
                    self.membrane_channels = _membrane_channels
            else:
                self.membrane_channels = []
        else:  # Single Channel image
            self.single_channel = True
            if _channels and max(_channels) > 0:
                print("Channel out of range", file=sys.stderr)
                sys.exit(1)
            if _nuclear_channels and max(_nuclear_channels) > 0:
                print("Nuclear channel out of range", file=sys.stderr)
                sys.exit(1)
            if _membrane_channels and max(_membrane_channels) > 0:
                print("Membrane channel out of range", file=sys.stderr)
                sys.exit(1)
            if _max_projection:
                print("Max projection not possible on single channel image.", file=sys.stderr)
                sys.exit(1)
            self.channels = [0]

        if self.max_projection and len(self.membrane_channels) > 0 and len(self.nuclear_channels) > 0:
            self.channels = [0, 1]
        elif self.max_projection and len(self.nuclear_channels) > 0:
            self.channels = [0]

        xy = _x is not None and _y is not None
        xy2 = _x2 is not None and _y2 is not None
        wh = _w is not None and _h is not None
        if all(v is None for v in (_x, _y, _x2, _y2, _w, _h)):
            _w = self.in_data[0].shape[-1]
            _h = self.in_data[0].shape[-2]
            _x = _y = 0
        elif not xy or not (wh ^ xy2):
            print("Please specify x/y and either x2/y2 or w/h", file=sys.stderr)
            sys.exit(1)
        elif xy2:
            _w = _x2 - _x
            _h = _y2 - _y

        self.num_levels = math.ceil(math.log((max([_h, _w]) / self.peak_size), self.scale)) + 1

        rounded_x = np.floor(_x / (self.scale ** (self.num_levels - 1))).astype(int) * (2 ** (self.num_levels - 1))
        self.x = max([rounded_x, 0])

        rounded_y = np.floor(_y / (self.scale ** (self.num_levels - 1))).astype(int) * (2 ** (self.num_levels - 1))
        self.y = max([rounded_y, 0])

        rounded_width = np.ceil((_w + self.x) / (self.scale ** (self.num_levels - 1))).astype(int) * \
                        (2 ** (self.num_levels - 1)) - self.x
        self.width = min([rounded_width, self.in_data[0].shape[-1]])

        rounded_height = np.ceil((_h + self.y) / (self.scale ** (self.num_levels - 1))).astype(
            int) * (2 ** (self.num_levels - 1)) - self.y
        self.height = min([rounded_height, self.in_data[0].shape[-2]])

        print('Params:', 'x', self.x, 'y', self.y, 'height', self.height, 'width', self.width, 'levels',
              self.num_levels,
              'channels', self.channels, 'nuclear_channels', self.nuclear_channels, 'membrane_channels', self.membrane_channels,
              'max_projection', self.max_projection
              )

        self.verbose = verbose

    @property
    def base_shape(self):
        "Shape of the base level."
        return [self.height, self.width]

    @property
    def num_channels(self):
        return len(self.channels)

    @property
    def level_shapes(self):
        "Shape of all levels."
        factors = self.scale ** np.arange(self.num_levels)
        shapes = np.ceil(np.array(self.base_shape) / factors[:, None])
        return [tuple(map(int, s)) for s in shapes]

    @property
    def level_full_shapes(self):
        "Shape of all levels, including channel dimension."
        return [(self.num_channels, *shape) for shape in self.level_shapes]

    @property
    def tile_shapes(self):
        "Tile shape of all levels."
        level_shapes = np.array(self.level_shapes)
        # The last level where we want to use the standard square tile size.
        tip_level = np.argmax(np.all(level_shapes < self.tile_size, axis=1))
        tile_shapes = [
            (self.tile_size, self.tile_size) if i <= tip_level else None
            for i in range(len(level_shapes))
        ]
        # Remove NONE from list

        return tile_shapes

    def max_projection_channel(self, channels):
        "Compute the maximum projection of the specified channels."
        if not channels:
            channels = self.channels
        maxprojection = np.max(
            self.in_data[0]
            .get_orthogonal_selection((
                channels, 
                slice(self.y,self.y + self.height), 
                slice(self.x,self.x + self.width ))),axis=0)
        return maxprojection

    def base_tiles(self):
        h, w = self.base_shape
        th, tw = self.tile_shapes[0]

        if self.max_projection:
            # If max projection is enabled, generate the maximum projection image
            if self.nuclear_channels:
                nuclear_img = self.max_projection_channel(self.nuclear_channels)
                imgs = [nuclear_img]
                if self.membrane_channels:
                    membrane_img = self.max_projection_channel(self.membrane_channels)
                    imgs.append(membrane_img)
            else:
                imgs = [self.max_projection_channel(self.channels)]
        else:
            imgs = [self.in_data[0][ci, self.y:self.y + self.height, self.x:self.x + self.width] for ci in self.channels]

        for img in imgs:
            for y in range(0, h, th):
                for x in range(0, w, tw):
                    yield img[y:y + th, x:x + tw].copy()
            img = None

    def cropped_subres_image(self, base_img, level):
        scale = 2 ** level
        subres_x1 = int(self.x / scale)
        subres_y1 = int(self.y / scale)
        subres_width = int(self.width / scale)
        subres_height = int(self.height / scale)
        subres_x2 = min([subres_x1 + subres_width, base_img.shape[-1]])
        subres_y2 = min([subres_y1 + subres_height, base_img.shape[-2]])
        return base_img[subres_y1:subres_y2, subres_x1:subres_x2]

    def subres_tiles(self, level):
        print(level, 'level')
        assert level >= 1
        num_channels, h, w = self.level_full_shapes[level]
        tshape = self.tile_shapes[level] or (h, w)

        for c in self.channels:
            if self.single_channel:
                base_img = self.in_data[level]
            else:
                base_img = self.in_data[level][c]
            img = self.cropped_subres_image(base_img, level)
            if self.verbose:
                sys.stdout.write(
                    f"\r        processing channel {c + 1}/{num_channels}"
                )
                sys.stdout.flush()
            th = tshape[0]
            tw = tshape[1]
            for y in range(0, img.shape[0], th):
                for x in range(0, img.shape[1], tw):
                    a = img[y:y + th, x:x + tw]
                    a = a.astype(img.dtype)
                    yield a

    def run(self):
        dtype = self.in_data[0].dtype
        with tifffile.TiffWriter(self.out_path, ome=True, bigtiff=True) as tiff:
            tiff.write(
                data=self.base_tiles(),
                software=self.in_tiff.pages[0].software,
                shape=self.level_full_shapes[0],
                subifds=int(self.num_levels - 1),
                dtype=self.in_tiff.pages[0].dtype,
                resolution=(
                    self.in_tiff.pages[0].tags["XResolution"].value,
                    self.in_tiff.pages[0].tags["YResolution"].value,
                ),
                resolutionunit=self.in_tiff.pages[0].tags["ResolutionUnit"].value,
                tile=self.tile_shapes[0],
                photometric=self.in_tiff.pages[0].photometric,
                compression="adobe_deflate",
                predictor=True,
            )
            if self.verbose:
                print("Generating pyramid")
            for level, (shape, tile_shape) in enumerate(
                    zip(self.level_full_shapes[1:], self.tile_shapes[1:]), 1
            ):
                if self.verbose:
                    print(f"    Level {level} ({shape[2]} x {shape[1]})")
                tiff.write(
                    data=self.subres_tiles(level),
                    shape=shape,
                    subfiletype=1,
                    dtype=dtype,
                    tile=tile_shape,
                    compression="adobe_deflate",
                    predictor=True,
                )
                if self.verbose:
                    print()
            self.metadata.images[0].pixels.channels = [self.metadata.images[0].pixels.channels[i] for i in
                                                       self.channels]
            self.metadata.uuid = uuid.uuid4().urn
            self.metadata.images[0].pixels.size_c = self.num_channels
            self.metadata.images[0].pixels.size_x = self.width
            self.metadata.images[0].pixels.size_y = self.height
            if self.metadata.images[0].pixels.planes:
                temp_planes = []
                for i, channel_id in enumerate(self.channels):
                    temp_plane = self.metadata.images[0].pixels.planes[channel_id]
                    temp_plane.the_c = i
                    temp_planes.append(temp_plane)
                self.metadata.images[0].pixels.planes = temp_planes
            if self.metadata.images[0].pixels.tiff_data_blocks and len(
                    self.metadata.images[0].pixels.tiff_data_blocks) > 0:
                self.metadata.images[0].pixels.tiff_data_blocks[0].plane_count = self.num_channels

            # Write
        tifffile.tiffcomment(self.out_path, to_xml(self.metadata).encode())


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--in', type=str, required=True, help="Input Image Path")
    parser.add_argument('--out', type=str, required=False, help="Output Image Path")
    parser.add_argument('--x', type=int, required=False, default=None, help="Crop X1")
    parser.add_argument('--x2', type=int, required=False, default=None, help="Crop X2")
    parser.add_argument('--y', type=int, required=False, default=None, help="Crop Y1")
    parser.add_argument('--y2', type=int, required=False, default=None, help="Crop Y2")
    parser.add_argument('--w', type=int, required=False, default=None, help="Crop Width")
    parser.add_argument('--h', type=int, required=False, default=None, help="Crop Height")
    parser.add_argument(
        '--channels', type=int, nargs="+", required=False, default=None, metavar="C",
        help="Channels to keep (Default: all)",
    )
    parser.add_argument(
        '--nuclear_channels', type=int, nargs="+", required=False, default=None, metavar="N",
        help="Specifying nuclear channels to keep",
    )
    parser.add_argument(
        '--membrane_channels', type=int, nargs="+", required=False, default=None, metavar="M",
        help="Specifying membrane channels to keep",
    )
    parser.add_argument(
        '--max_projection', action='store_true', help="Use max projection",
    )
    parser.add_argument(
        '--num-threads', type=int, required=False, default=0, metavar="N",
        help="Worker thread count (Default: auto-scale based on number of available CPUs)",
    )
    args = parser.parse_args()

    # Automatically infer the output filename, if not specified
    in_path = vars(args)['in']
    out_path = args.out
    if out_path is None:
        # Tokenize the input filename and insert "_crop"
        #   at the appropriate location
        tokens = os.path.basename(in_path).split(os.extsep)
        if len(tokens) < 2:
            out_path = in_path + "_crop"
        elif tokens[-2] == "ome":
            stem = os.extsep.join(tokens[0:-2]) + "_crop"
            out_path = os.extsep.join([stem] + tokens[-2:])
        else:
            stem = os.extsep.join(tokens[0:-1]) + "_crop"
            out_path = os.extsep.join([stem, tokens[-1]])

    num_threads = args.num_threads
    if num_threads == 0:
        if hasattr(os, "sched_getaffinity"):
            num_threads = len(os.sched_getaffinity(0))
        else:
            num_threads = os.cpu_count()
    tifffile.TIFF.MAXWORKERS = num_threads
    tifffile.TIFF.MAXIOWORKERS = num_threads * 5

    writer = PyramidWriter(in_path, out_path, args.channels, args.nuclear_channels, args.membrane_channels, args.max_projection, args.x, args.y, args.x2, args.y2, args.w, args.h)
    writer.run()

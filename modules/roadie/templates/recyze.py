import math
import sys
import tifffile
import zarr
import numpy as np
from ome_types import from_tiff, to_xml
from pathlib import Path
import re
import time
import argparse


class PyramidWriter:

    def __init__(
            self, in_path, out_path, channel_list, crop=None, scale=2, tile_size=1024, peak_size=1024, verbose=False
    ):
        if tile_size % 16 != 0:
            raise ValueError("tile_size must be a multiple of 16")
        self.in_path = Path(in_path)
        self.in_data = zarr.open(tifffile.TiffFile(self.in_path, is_ome=False).series[0].aszarr())
        self.out_path = Path(out_path)
        self.metadata = from_tiff(self.in_path)
        # Parse channel list, if none given, add every channel to list
        if channel_list is None:
            if self.in_data[0].ndim == 3:
                self.channel_list = np.arange(self.in_data[0].shape[0], dtype=int).tolist()
            elif self.in_data[0].ndim == 2:  # One channel image
                self.channel_list = [0]
        else:
            self.channel_list = [int(e.strip()) for e in channel_list.split(',')]
        self.scale = scale
        if crop is None:
            self.crop = [self.in_data[0].shape[-1], self.in_data[0].shape[-2], 0, 0]
        else:
            self.crop = [int(e) for e in re.match(r"(\d+)x(\d+)\+(\d+)\+(\d)", crop).groups()]
        self.orig_shape = [self.crop[1], self.crop[0]]
        self.tile_size = tile_size
        self.peak_size = peak_size
        self.verbose = verbose

    @property
    def num_levels(self):
        "Number of levels."
        factor = max(self.orig_shape) / self.peak_size
        return math.ceil(math.log(factor, self.scale)) + 1

    @property
    def width(self):
        rounded_width = np.ceil((self.orig_shape[1] + self.x) / (self.scale ** (self.num_levels - 1))).astype(int) * \
                        (2 ** (self.num_levels - 1))
        # ensure cropping dimensions are within original image
        return min([rounded_width, self.in_data[0].shape[-1]])

    @property
    def height(self):
        rounded_height = np.ceil((self.orig_shape[0] + self.x) / (self.scale ** (self.num_levels - 1))).astype(
            int) * \
                         (2 ** (self.num_levels - 1))
        # ensure cropping dimensions are within original image
        return min([rounded_height, self.in_data[0].shape[-2]])

    @property
    def x(self):
        rounded_x = np.floor(self.crop[2] / (self.scale ** (self.num_levels - 1))).astype(int) * \
                    (2 ** (self.num_levels - 1))
        # ensure x is in bounds
        return max([rounded_x, 0])

    @property
    def y(self):
        rounded_y = np.floor(self.crop[3] / (self.scale ** (self.num_levels - 1))).astype(int) * \
                    (2 ** (self.num_levels - 1))
        # ensure y is in bounds
        return max([rounded_y, 0])

    @property
    def base_shape(self):
        "Shape of the base level."
        return [self.height, self.width]

    @property
    def num_channels(self):
        return len(self.channel_list)

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

    def base_tiles(self):
        h, w = self.base_shape
        th, tw = self.tile_shapes[0]

        for ci in self.channel_list:
            if self.verbose:
                print(f"    Channel {ci}:")
            img = self.in_data[0][ci, self.y:self.y + self.height, self.x:self.x + self.width]
            print('Shape', img.shape)
            for y in range(0, h, th):
                for x in range(0, w, tw):
                    # Returning a copy makes the array contiguous, avoiding
                    # a severely unoptimized code path in ndarray.tofile.
                    yield img[y:y + th, x:x + tw].copy()
            # Allow img to be freed immediately to avoid keeping it in
            # memory while the next loop iteration calls assemble_channel.
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

        for c in self.channel_list:
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
        pixel_size = self.metadata.images[0].pixels.physical_size_x
        resolution_cm = 10000 / pixel_size
        software = f"Ashlar v"  # TODO
        metadata = {
            "Creator": software,
            "Pixels": {
                "PhysicalSizeX": pixel_size, "PhysicalSizeXUnit": "\u00b5m",
                "PhysicalSizeY": pixel_size, "PhysicalSizeYUnit": "\u00b5m"
            },
        }
        with tifffile.TiffWriter(self.out_path, ome=True, bigtiff=True) as tiff:
            tiff.write(
                data=self.base_tiles(),
                metadata=metadata,
                software=software.encode("utf-8"),
                shape=self.level_full_shapes[0],
                subifds=int(self.num_levels - 1),
                dtype=dtype,
                tile=self.tile_shapes[0],
                resolution=(resolution_cm, resolution_cm, "centimeter"),
                # FIXME Propagate this from input files (especially RGB).
                photometric="minisblack",
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
                )
                if self.verbose:
                    print()
            # Update Metadata
            # TODO: Is this the correct way to update channels or should i just overwrite names with indices still in order?
            self.metadata.images[0].pixels.channels = [self.metadata.images[0].pixels.channels[i] for i in
                                                       self.channel_list]
            self.metadata.images[0].pixels.size_c = self.num_channels
            self.metadata.images[0].pixels.size_x = self.width
            self.metadata.images[0].pixels.size_y = self.height

            # Plane TBD
            self.metadata.images[0].pixels.planes = self.metadata.images[0].pixels.planes[0:self.num_channels]
            self.metadata.images[0].pixels.tiff_data_blocks[0].plane_count = self.num_channels
            # Write
            tifffile.tiffcomment(self.out_path, to_xml(self.metadata))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    # E.G. 25482x1065+0+0
    parser.add_argument('--crop', type=str, required=False, help="Crop coordinates in form {width}x{height}+{x}+{y}",
                        default=None)
    parser.add_argument('--in_path', type=str, required=True, help="Input Image Path")
    parser.add_argument('--out_path', type=str, required=True, help="Output Image Path")
    parser.add_argument('--channels', type=str, required=False,
                        help="Channels as comma separated list of indices e.g. 1,4,5")

    argument = parser.parse_args()

    writer = PyramidWriter(argument.in_path, argument.out_path, argument.channels, argument.crop)
    writer.run()

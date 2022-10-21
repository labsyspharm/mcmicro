# Tile images and generate 'coordinates.csv' file
import os
import csv
from skimage.io import imread, imsave
from collections import namedtuple
import pandas as pd
import numpy as np

input_path = '/Users/segonzal/Documents/Repositories/imbast/data/primary'
img_input = imread(os.path.join(input_path, os.listdir(input_path)[0]))
tile_size = 500
tile_overlap = 0
channel_map = {'CH0': '0', 'CH1': '1', 'CH2': '2', 'CH3': '3'}

def get_tile_coordinates(tile_size: int, tile_overlap: int) -> None:
    """Compute tile coordinates."""
    tile_coordinates = {}

    RoI = namedtuple('RoI', ['row', 'col', 'nrows', 'ncols'])
    tile_n = 0

    tile_size = tile_size + tile_overlap

    def _get_size(position, tile_size, total_size):
        dist_to_end = total_size - position
        size = tile_size
        size = size if dist_to_end > size else dist_to_end

        return size

    for r in range(0, img_input.shape[0], tile_size):
        nrows = _get_size(r, tile_size, img_input.shape[0])

        for c in range(0, img_input.shape[1], tile_size):
            ncols = _get_size(c, tile_size, img_input.shape[1])

            tile_coordinates[tile_n] = RoI(r, c, nrows, ncols)
            tile_n += 1

    return tile_coordinates

def select_roi(image, roi):
    return image[roi.row:roi.row + roi.nrows,
           roi.col:roi.col + roi.ncols]

def needs_padding(image_tile, tile_size):
    return any([image_tile.shape[i] < tile_size for i in [0, 1]])

def pad_to_size(
        image,
        tile_size
    ) -> np.ndarray:
        """Pad smaller tiles to match standard tile size."""
        # Images must be same size
        # Pad with zeros to default size
        if needs_padding(image, tile_size):
            pad_width = tuple((0, tile_size - image.shape[i]) for i in [0, 1])
            image = np.pad(image, pad_width, 'constant')

        return image


def tile_image_set(in_dir, tile_size, tile_overlap, img_type,
                coordinates, output_dir):
    # File names and coordinates table according to
    # SpaceTx Structured Data
    tile_coordinates = get_tile_coordinates(tile_size, tile_overlap)
    coordinates = []
    for image_name in os.listdir(in_dir):
        image = imread(os.path.join(in_dir, image_name))
        for tile_id in tile_coordinates:
            coords = tile_coordinates[tile_id]
            tile = select_roi(
                image, roi=coords)
            #tile = self._pad_to_size(tile, tile_size)

            r = image_name.split('_')[0][1:]

            c = channel_map[image_name.split('_')[1].split('.')[0]]

            file_name = f'primary-f{tile_id}-r{r}-c{c}-z0.tiff'
            imsave(os.path.join(output_dir, file_name), pad_to_size(tile, tile_size))

            coordinates.append([
                tile_id, r, c, 0,
                coords.col, coords.row, 0,
                coords.col + tile_size, coords.row + tile_size, 0.0001])

    return coordinates

def write_coords_file(coordinates, file_path) -> None:
    coords_df = pd.DataFrame(
        coordinates,
        columns=('fov', 'round', 'ch', 'zplane',
                 'xc_min', 'yc_min', 'zc_min',
                 'xc_max', 'yc_max', 'zc_max'))
    coords_df.to_csv(file_path, index=False)

coords = tile_image_set('/Users/segonzal/Documents/Repositories/imbast/data/primary',
                        500,
                        0,
                        'primary',
                        get_tile_coordinates(tile_size=500, tile_overlap=0),
                        '/Users/segonzal/Downloads')

write_coords_file(coords, '/Users/segonzal/Downloads/coordinates.csv')

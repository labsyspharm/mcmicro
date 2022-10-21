import os
from starfish import data, FieldOfView
import tifffile as tiff
from starfish import Experiment
from starfish.types import Axes
import napari

# Create sample raw dataset for tiling:
exp = data.ISS(use_test_data=False)
fov = exp['fov_000']
primary = fov.get_image(FieldOfView.PRIMARY_IMAGES)

save_dir = '/Users/segonzal/Documents/Repositories/imbast/data/primary'
# Loop through data and save it:
# Save nuclei (will focus for now only on primary images
#tiff.imwrite(os.path.join(save_dir, '') ,fov.get_image('nuclei')

for ch in range(4):
    for r in range(4):
        img = primary.sel({Axes.ROUND: r, Axes.CH: ch}).xarray.squeeze()
        tiff.imwrite(os.path.join(save_dir, 'r' + str(r) + '_' + 'CH' + str(ch) + '.tiff'), img)

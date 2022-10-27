import os
from starfish import data, FieldOfView
import tifffile as tiff
from starfish.types import Axes
from pathlib import Path
from typing import Union


# Create sample raw dataset for tiling:
exp = data.ISS(use_test_data=False)
fov = exp['fov_000']
primary = fov.get_image(FieldOfView.PRIMARY_IMAGES)

# save_dir = '/Users/segonzal/Documents/Repositories/imbast/data/primary'
save_dir = Path(os.getcwd()) / "sample_dataset"
print(save_dir)


def generate_dataset(save_dir: Union[str, Path]):
    save_dir = Path(save_dir)
    for ch in range(4):
        for r in range(4):
            img = primary.sel({Axes.ROUND: r, Axes.CH: ch}).xarray.squeeze()
            tiff.imwrite(save_dir / f"r{r}_CH{ch}.tiff", img)


if __name__ == '__main__':
    generate_dataset(save_dir)

import os
import numpy as np
import starfish
from skimage.io import imread
import argparse
from starfish.image import ApplyTransform, LearnTransform, Filter
from starfish.types import Axes
from starfish import data, FieldOfView
from starfish.spots import FindSpots, DecodeSpots, AssignTargets
from starfish.util.plot import imshow_plane

codebook = data.ISS(use_test_data=True).codebook

def get_args():
    """Get command-line arguments"""

    parser = argparse.ArgumentParser(
        description='Input/output directories for data formatting',
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    parser.add_argument('-i',
                        '--input_dir',
                        default='Tiled',
                        type=str,
                        help='Input root directory')

    return parser.parse_args()


def iss_pipeline(fov, codebook):
    #fov = experiment.fov()
    primary_image = fov.get_image(FieldOfView.PRIMARY_IMAGES)
    anchor = primary_image.sel({Axes.ROUND: 0})
    anchor_dots = anchor.reduce({Axes.CH, Axes.ZPLANE}, func="max")

    learn_translation = LearnTransform.Translation(reference_stack=anchor_dots,
                                                   axes=Axes.ROUND, upsampling=100)

    transforms_list = learn_translation.run(
        primary_image.reduce({Axes.CH, Axes.ZPLANE}, func="max"))

    warp = ApplyTransform.Warp()
    registered = warp.run(primary_image, transforms_list=transforms_list, in_place=False, verbose=True)

    # Filter raw data
    masking_radius = 15
    filt = Filter.WhiteTophat(masking_radius, is_volume=False)
    filtered = filt.run(registered, verbose=True, in_place=False)
    print(filtered)

    bd = FindSpots.BlobDetector(
        min_sigma=1,
        max_sigma=3,
        num_sigma=30,
        threshold=0.01,
        measurement_type='mean'
    )

    # Check if experiment has anchor or not
    # Locate spots in a reference image:
    # Old one: spots = bd.run(reference_image=fov.get_image("anchor_dots"), image_stack=filtered)
    spots = bd.run(reference_image=anchor_dots, image_stack=filtered)

    # decode the pixel traces using the codebook
    decoder = DecodeSpots.PerRoundMaxChannel(codebook=codebook)
    decoded = decoder.run(spots=spots)

    return decoded
#imshow_plane(dots)

# process all the fields of view:
def process_experiment(experiment: starfish.Experiment, cb: starfish.Codebook):
    decoded_intensities = {}
    for i, (name_, fov) in enumerate(experiment.items()):
        print(name_)
        decoded = iss_pipeline(fov, codebook=cb)
        decoded_intensities[name_] = decoded

    return decoded_intensities

def save_fov(fov, dataframe):
    fov_df = dataframe.to_features_dataframe()
    fov_df.to_csv(f'fov_{fov}.csv', index=False)

def main():
    args = get_args()
    exp = starfish.Experiment.from_json(os.path.join(args.input_dir, 'primary', 'experiment.json'))
    results = process_experiment(exp, codebook)
    for fov, data in results.items():
        save_fov(fov, data)


if __name__ == '__main__':
    main()

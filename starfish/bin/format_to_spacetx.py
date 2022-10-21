from slicedimage import ImageFormat
from starfish.experiment.builder import format_structured_dataset
import argparse
import os

# --------------------------------------------------
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

    parser.add_argument('-o',
                        '--output_dir',
                        default='SpaceTx',
                        type=str,
                        help='Output root directory')

    return parser.parse_args()

#--------------------------------------------------
def format_experiment(
        in_dir: str = 'Tiled',
        out_dir: str = 'SpaceTx',
        subdirs: list = ['primary', 'nuclei', 'anchor_dots', 'anchor_nuclei'],
        coordinates_filename: str = 'coordinates.csv'
):
    for subdir in subdirs:
        # in_d = os.path.join(in_dir, subdir)
        in_d = in_dir
        out_d = os.path.join(out_dir, subdir)
        os.makedirs(out_d)

        format_structured_dataset(
            in_d,
            os.path.join(in_d, "coordinates.csv"),
            out_d,
            ImageFormat.TIFF,
        )

#--------------------------------------------------
def main():
    args = get_args()
    format_experiment(
        in_dir=args.input_dir,
        out_dir=args.output_dir
    )


if __name__ == '__main__':
   main()
#  format_experiment('/Users/segonzal/Documents/iss_nextflow/2bCartana_08_Test/Tiled', 'SpaceTx', ['primary'])

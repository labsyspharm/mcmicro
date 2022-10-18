import os
import argparse
import palom.reader
import palom.pyramid

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
        out_path = stem + ".ome.tif"

    # Use palom to pyramidize the input image
    img = palom.reader.OmePyramidReader(in_path)
    palom.pyramid.write_pyramid([img.pyramid[0]], out_path)

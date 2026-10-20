#!/usr/bin/env python3
"""Estimate gigapixels for TIFF/OME-TIFF files.

This script intentionally has no required third-party dependencies so it can run
from a Nextflow config on HPC login/submit nodes. It prints one number: the
largest single-plane pixel count found in the TIFF metadata, divided by 1e9.
"""

from __future__ import annotations

import argparse
import re
import struct
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import BinaryIO


TAG_IMAGE_WIDTH = 256
TAG_IMAGE_LENGTH = 257
TAG_IMAGE_DESCRIPTION = 270

TYPE_SIZES = {
    1: 1,   # BYTE
    2: 1,   # ASCII
    3: 2,   # SHORT
    4: 4,   # LONG
    5: 8,   # RATIONAL
    6: 1,   # SBYTE
    7: 1,   # UNDEFINED
    8: 2,   # SSHORT
    9: 4,   # SLONG
    10: 8,  # SRATIONAL
    11: 4,  # FLOAT
    12: 8,  # DOUBLE
    16: 8,  # LONG8
    17: 8,  # SLONG8
    18: 8,  # IFD8
}


def read_exact(fh: BinaryIO, size: int) -> bytes:
    data = fh.read(size)
    if len(data) != size:
        raise ValueError("Unexpected end of file")
    return data


def unpack_one(fmt: str, data: bytes) -> int:
    return struct.unpack(fmt, data)[0]


def values_from_entry(
    fh: BinaryIO,
    endian: str,
    field_type: int,
    count: int,
    value_or_offset: bytes,
    offset_size: int,
) -> bytes:
    type_size = TYPE_SIZES.get(field_type)
    if not type_size:
        return b""

    total_size = type_size * count
    if total_size <= offset_size:
        return value_or_offset[:total_size]

    offset_fmt = endian + ("Q" if offset_size == 8 else "I")
    offset = unpack_one(offset_fmt, value_or_offset[:offset_size])
    here = fh.tell()
    fh.seek(offset)
    data = read_exact(fh, total_size)
    fh.seek(here)
    return data


def first_numeric_value(endian: str, field_type: int, data: bytes) -> int | None:
    formats = {
        1: "B",
        3: "H",
        4: "I",
        6: "b",
        8: "h",
        9: "i",
        16: "Q",
        17: "q",
        18: "Q",
    }
    fmt = formats.get(field_type)
    if not fmt:
        return None

    size = struct.calcsize(endian + fmt)
    if len(data) < size:
        return None

    return unpack_one(endian + fmt, data[:size])


def parse_ome_xml(description: str) -> list[tuple[int, int]]:
    if "<OME" not in description and "<ome:OME" not in description:
        return []

    # Some ImageDescription values have non-XML preambles; trim to the OME root.
    match = re.search(r"<(?:\w+:)?OME\b", description)
    if match:
        description = description[match.start():]

    try:
        root = ET.fromstring(description)
    except ET.ParseError:
        return []

    dims: list[tuple[int, int]] = []
    for elem in root.iter():
        if elem.tag.split("}")[-1] != "Pixels":
            continue
        try:
            size_x = int(elem.attrib["SizeX"])
            size_y = int(elem.attrib["SizeY"])
        except (KeyError, ValueError):
            continue
        dims.append((size_x, size_y))
    return dims


def tiff_dimensions(path: Path) -> list[tuple[int, int]]:
    dims: list[tuple[int, int]] = []

    with path.open("rb") as fh:
        byte_order = read_exact(fh, 2)
        if byte_order == b"II":
            endian = "<"
        elif byte_order == b"MM":
            endian = ">"
        else:
            raise ValueError("Not a TIFF file")

        magic = unpack_one(endian + "H", read_exact(fh, 2))
        if magic == 42:
            bigtiff = False
            offset_size = 4
            first_ifd = unpack_one(endian + "I", read_exact(fh, 4))
        elif magic == 43:
            bigtiff = True
            offset_size = unpack_one(endian + "H", read_exact(fh, 2))
            zero = unpack_one(endian + "H", read_exact(fh, 2))
            if offset_size != 8 or zero != 0:
                raise ValueError("Unsupported BigTIFF header")
            first_ifd = unpack_one(endian + "Q", read_exact(fh, 8))
        else:
            raise ValueError("Unsupported TIFF magic")

        next_ifd = first_ifd
        seen: set[int] = set()
        while next_ifd and next_ifd not in seen:
            seen.add(next_ifd)
            fh.seek(next_ifd)

            if bigtiff:
                n_entries = unpack_one(endian + "Q", read_exact(fh, 8))
                entry_size = 20
                count_fmt = "Q"
                next_fmt = endian + "Q"
            else:
                n_entries = unpack_one(endian + "H", read_exact(fh, 2))
                entry_size = 12
                count_fmt = "I"
                next_fmt = endian + "I"

            width = None
            height = None
            descriptions: list[str] = []

            for _ in range(n_entries):
                entry = read_exact(fh, entry_size)
                tag, field_type = struct.unpack(endian + "HH", entry[:4])
                count = unpack_one(endian + count_fmt, entry[4:4 + offset_size])
                value = entry[4 + offset_size:4 + offset_size + offset_size]
                data = values_from_entry(fh, endian, field_type, count, value, offset_size)

                if tag == TAG_IMAGE_WIDTH:
                    width = first_numeric_value(endian, field_type, data)
                elif tag == TAG_IMAGE_LENGTH:
                    height = first_numeric_value(endian, field_type, data)
                elif tag == TAG_IMAGE_DESCRIPTION and data:
                    descriptions.append(data.rstrip(b"\x00").decode("utf-8", errors="ignore"))

            for description in descriptions:
                dims.extend(parse_ome_xml(description))

            if width and height:
                dims.append((width, height))

            next_ifd = unpack_one(next_fmt, read_exact(fh, offset_size))

    return dims


def main() -> int:
    parser = argparse.ArgumentParser(description="Print largest TIFF plane size in gigapixels.")
    parser.add_argument("image", type=Path)
    args = parser.parse_args()

    dims = tiff_dimensions(args.image)
    if not dims:
        print("0")
        return 0

    max_pixels = max(width * height for width, height in dims)
    print(max_pixels / 1e9)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(f"0", file=sys.stdout)
        print(f"MGB_ome_tiff_gpx.py: {exc}", file=sys.stderr)
        raise SystemExit(0)

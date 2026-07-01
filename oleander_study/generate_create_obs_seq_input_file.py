#!/usr/bin/env python3
"""
Generate an input file for DART's create_obs_sequence from a climatology-style nc file.

Usage:
    python generate_create_obs_seq_file.py -i <file.nc> -t OBS_TYPE1 [OBS_TYPE2 ...] [-o output_dir]

The input nc file is expected to have:
  - a depth dimension  (depth_transect or depth)
  - a lat dimension    (lat_transect or lat)
  - a lon coordinate   (lon_transect or lon, indexed by the lat dimension)

The output file obs_seq_generated.in can be piped as stdin to create_obs_sequence.
"""

import argparse
import sys
from pathlib import Path

import numpy as np
import xarray as xr


CREATE_OBS_SEQ_INPUT_FILENAME =  "create_obs_sequence.in"
CREATE_OBS_SEQ_OUTPUT_FILENAME = "create_obs_sequence.out"
WHICH_VERT = 3


def detect_coord(ds: xr.Dataset, primary: str, fallback: str) -> str:
    """Return the name of the first matching coordinate/dimension found in ds."""
    for name in (primary, fallback):
        if name in ds.coords or name in ds.dims:
            return name
    raise KeyError(
        f"Could not find coordinate '{primary}' or '{fallback}' in the dataset. "
        f"Available coords/dims: {list(ds.coords) + list(ds.dims)}"
    )


def parse_args(argv=None):
    parser = argparse.ArgumentParser(
        description="Generate a create_obs_sequence input file from a climatology nc file."
    )
    parser.add_argument(
        "-i", "--input",
        required=True,
        metavar="NC_FILE",
        help="Path to the input climatology-style .nc file.",
    )
    parser.add_argument(
        "-t", "--obs_types",
        required=True,
        nargs="+",
        metavar="OBS_TYPE",
        help="One or more DART observation type names (e.g. TEMPERATURE SALINITY).",
    )
    parser.add_argument(
        "-o", "--output_dir",
        default=None,
        metavar="DIR",
        help="Directory where obs_seq_generated.in will be written (default: cwd).",
    )
    return parser.parse_args(argv)


def main(argv=None):
    args = parse_args(argv)

    nc_path = Path(args.input)
    if not nc_path.exists():
        print(f"Error: input file not found: {nc_path}", file=sys.stderr)
        sys.exit(1)

    output_dir = Path(args.output_dir) if args.output_dir else Path.cwd()
    output_dir.mkdir(parents=True, exist_ok=True)
    out_path = output_dir / CREATE_OBS_SEQ_INPUT_FILENAME

    ds = xr.open_dataset(nc_path)

    depth_name = detect_coord(ds, "depth_transect", "depth")
    lat_name   = detect_coord(ds, "lat_transect",   "lat")
    lon_name   = detect_coord(ds, "lon_transect",   "lon")

    depths = ds[depth_name].values
    lats   = ds[lat_name].values
    lons   = ds[lon_name].values  # 1-D, indexed by lat dimension

    # Drop lat/lon pairs where lon is NaN (outside the actual transect coverage)
    valid_mask = ~np.isnan(lons)
    n_skipped = (~valid_mask).sum()
    if n_skipped:
        print(
            f"Warning: skipping {n_skipped} lat point(s) with NaN lon values.",
            file=sys.stderr,
        )
    lats_valid = lats[valid_mask]
    lons_valid = lons[valid_mask] % 360  # map to [0, 360)

    n_depth = len(depths)
    n_lat   = len(lats_valid)
    n_obs_per_type = n_depth * n_lat
    max_num_obs = n_obs_per_type * len(args.obs_types)

    with open(out_path, "w") as f:
        # Header
        f.write(f"{max_num_obs}\n")
        f.write("0\n")   # num_copies
        f.write("0\n")   # num_qc
        f.write("0\n")   # end_it_all sentinel: 0 means obs definitions follow

        # Observation blocks
        counter = 0
        for obs_type in args.obs_types:
            for lat, lon in zip(lats_valid, lons_valid):
                for depth in depths:
                    counter += 1
                    f.write(f"{obs_type}\n")
                    f.write(f"{WHICH_VERT}\n")
                    f.write(f"{depth}\n")
                    f.write(f"{lon}\n")
                    f.write(f"{lat}\n")
                    f.write("2010 1 1 0 0 0\n")   # year month day hour minute seconds (placeholder)
                    f.write("0.0\n")   # error_variance
                    if not counter == max_num_obs:
                        f.write("0\n")     # trailing flag

        # Output filename read by create_obs_sequence at the end
        f.write(f"{CREATE_OBS_SEQ_OUTPUT_FILENAME}\n")

    print(
        f"Wrote {max_num_obs} observation definitions "
        f"({len(args.obs_types)} type(s) × {n_lat} lat × {n_depth} depth) "
        f"to: {out_path}"
    )


if __name__ == "__main__":
    main()

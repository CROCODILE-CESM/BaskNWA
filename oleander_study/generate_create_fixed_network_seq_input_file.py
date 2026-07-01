#!/usr/bin/env python3
"""
Generate an input file for DART's create_fixed_network_seq (Option 1: regular repeating).

Usage:
    python generate_create_fixed_network_seq_input_file.py \\
        -i <file.nc> (-d | -w | -b | -m | --period N) [-c def_file] [-o output_dir]

The input nc file must have a `time` coordinate (datetime64).
Start/end dates are derived from ds.time.min() and ds.time.max() (date only).

Initial observation time per period mode:
  -d  daily     : start_date at noon              (period = 1 day)
  -w  weekly    : start_date + 3 days at noon     (period = 7 days)
  -b  biweekly  : start_date + 7 days at noon     (period = 15 days)
  -m  monthly   : 15th of first eligible month    (period = 30 days)
      --period N: start_date + N//2 days at noon  (period = N days)

The generated file `create_fixed_network_seq.input` can be used as:
    ./create_fixed_network_seq < create_fixed_network_seq.input
"""

import argparse
import sys
from datetime import datetime, timedelta, date
from pathlib import Path

import pandas as pd
import xarray as xr


CFNS_INPUT = "create_fixed_network_seq.in"
DART_OUTPUT_OBS_SEQ = "create_fixed_network_seq.out"
COS_OUTPUT = "create_obs_sequence.out"
COS_PATH = Path(COS_OUTPUT)
DART_OUTPUT_OBS_SEQ_PATH = Path(DART_OUTPUT_OBS_SEQ)

def first_15th_on_or_after(d: date) -> date:
    """Return the 15th of the first calendar month where the 15th >= d."""
    if d.day <= 15:
        return date(d.year, d.month, 15)
    # Move to the next month
    if d.month == 12:
        return date(d.year + 1, 1, 15)
    return date(d.year, d.month + 1, 15)


def compute_initial_and_period(start_date: date, period_days: int, mode: str):
    """Return (initial_datetime, period_days)."""
    if mode == "daily":
        offset = 0
    elif mode == "weekly":
        offset = 3
    elif mode == "biweekly":
        offset = 7
    elif mode == "monthly":
        initial_date = first_15th_on_or_after(start_date)
        return datetime(initial_date.year, initial_date.month, 15, 12, 0, 0), period_days
    else:  # custom --period N
        offset = period_days // 2

    initial_date = start_date + timedelta(days=offset)
    return datetime(initial_date.year, initial_date.month, initial_date.day, 12, 0, 0), period_days


def parse_args(argv=None):
    parser = argparse.ArgumentParser(
        description="Generate a create_fixed_network_seq input file from a climatology nc file."
    )
    parser.add_argument(
        "-i", "--input",
        metavar="NC_FILE",
        help="Path to the input climatology .nc file (must have a time coordinate).",
    )
    parser.add_argument(
        "-c", "--create_obs_seq_output",
        default=COS_OUTPUT,
        metavar="DEF_FILE",
        help=f"Input definition filename read by DART (default: {COS_OUTPUT}).",
    )
    parser.add_argument(
        "-o", "--output_dir",
        default=None,
        metavar="DIR",
        help="Directory where create_fixed_network_seq.input will be written (default: cwd).",
    )

    parser.add_argument(
        "--start",
        default=None,
        metavar="YYYY-MM-DD",
        help="Override the start date derived from the nc file (format: YYYY-MM-DD).",
    )
    parser.add_argument(
        "--end",
        default=None,
        metavar="YYYY-MM-DD",
        help="Override the end date derived from the nc file (format: YYYY-MM-DD).",
    )
    parser.add_argument(
        "-M", "--multiple-files",
        action="store_true",
        help="Output one file per period instead of one file for the whole date range.",
    )

    period_group = parser.add_mutually_exclusive_group(required=True)
    period_group.add_argument(
        "-d", "--daily",
        action="store_true",
        help="Daily period (1 day). Initial obs: start_date at noon.",
    )
    period_group.add_argument(
        "-w", "--weekly",
        action="store_true",
        help="Weekly period (7 days). Initial obs: start_date + 3 days at noon.",
    )
    period_group.add_argument(
        "-b", "--biweekly",
        action="store_true",
        help="Biweekly period (15 days). Initial obs: start_date + 7 days at noon.",
    )
    period_group.add_argument(
        "-m", "--monthly",
        action="store_true",
        help="Monthly period (30 days). Initial obs: 15th of first eligible month at noon.",
    )
    period_group.add_argument(
        "--period",
        type=int,
        metavar="N",
        help="User-defined period in days. Initial obs: start_date + N//2 days at noon.",
    )

    return parser.parse_args(argv)


def write_out(
        out_path,
        create_obs_seq_out,
        n_repl,
        initial_dt,
        period,
        dart_obs_seq_out,
        mode
):
    with open(out_path, "w") as f:
        f.write(f"{create_obs_seq_out}\n")
        f.write("1\n")   # option: regular repeating
        f.write(f"{n_repl}\n")
        f.write(
            f"{initial_dt.year} {initial_dt.month} {initial_dt.day} "
            f"{initial_dt.hour} {initial_dt.minute} {initial_dt.second}\n"
        )
        f.write(f"{period} 0\n")
        f.write(f"{dart_obs_seq_out}\n")

    start_date = pd.Timestamp(initial_dt).date()
    n_days = period*n_repl - 1
    end_date = pd.Timestamp(initial_dt+timedelta(days=n_days)).date()
    print(
        f"Period: {mode} ({period} day(s)) \n"
        f"Dataset: {start_date} → {end_date} \n"
        f"Initial obs: {initial_dt} \n"
        f"Number of replicates: {n_repl} \n"
        f"Written: {out_path}"
    )


def main(argv=None):
    args = parse_args(argv)

    if args.input:
        nc_path = Path(args.input)
        if not nc_path.exists():
            print(f"Error: input file not found: {nc_path}", file=sys.stderr)
            sys.exit(1)
        ds = xr.open_dataset(nc_path)
        if "time" not in ds.coords:
            print("Error: the input nc file has no 'time' coordinate.", file=sys.stderr)
            sys.exit(1)

        start_date = pd.Timestamp(ds.time.min().values).date()
        end_date   = pd.Timestamp(ds.time.max().values).date()

    output_dir = Path(args.output_dir) if args.output_dir else Path.cwd()
    output_dir.mkdir(parents=True, exist_ok=True)
    out_path = output_dir / CFNS_INPUT

    if args.start:
        try:
            start_date = date.fromisoformat(args.start)
        except ValueError:
            print(f"Error: --start value '{args.start}' is not a valid YYYY-MM-DD date.", file=sys.stderr)
            sys.exit(1)
    if args.end:
        try:
            end_date = date.fromisoformat(args.end)
        except ValueError:
            print(f"Error: --end value '{args.end}' is not a valid YYYY-MM-DD date.", file=sys.stderr)
            sys.exit(1)

    if end_date <= start_date:
        print(f"Error: end date ({end_date}) must be after start date ({start_date}).", file=sys.stderr)
        sys.exit(1)

    if args.daily:
        mode, period_days = "daily", 1
    elif args.weekly:
        mode, period_days = "weekly", 7
    elif args.biweekly:
        mode, period_days = "biweekly", 15
    elif args.monthly:
        mode, period_days = "monthly", 30
    else:
        mode, period_days = "custom", args.period

    initial_dt, period_days = compute_initial_and_period(start_date, period_days, mode)

    n_days = (end_date - initial_dt.date()).days
    if n_days < 0:
        print(
            f"Error: initial observation time ({initial_dt.date()}) is after the dataset end date ({end_date}).",
            file=sys.stderr,
        )
        sys.exit(1)
    n_repl = n_days // period_days + 1

    if args.multiple_files:
        for j in range (n_repl):
            initial_dt_file = initial_dt + timedelta(days=period_days*j)
            n_repl_file = 1
            initial_dt_file_str =  initial_dt_file.strftime("%Y%m%d")
            dart_obs_seq_out = DART_OUTPUT_OBS_SEQ_PATH.with_name(
                f"{DART_OUTPUT_OBS_SEQ_PATH.stem}_" + initial_dt_file_str + ".out"
            )
            period_days_file = 1
            out_path_file = out_path.with_name(f"{out_path.stem}_" + initial_dt_file_str + ".in")

            write_out(
                out_path_file,
                args.create_obs_seq_output,
                n_repl_file,
                initial_dt_file,
                period_days_file,
                dart_obs_seq_out,
                mode
            )

    else:
        write_out(
            out_path,
            args.create_obs_seq_output,
            n_repl,
            initial_dt,
            period_days,
            DART_OUTPUT_OBS_SEQ,
            mode
        )
    # print(
    #     f"Period: {mode} ({period_days} day(s)) \n"
    #     f"Dataset: {start_date} → {end_date} \n"
    #     f"Initial obs: {initial_dt} \n"
    #     f"n_repl: {n_repl} \n"
    #     f"Written: {out_path}"
    # )


if __name__ == "__main__":
    main()

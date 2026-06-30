#!/usr/bin/env python3

import argparse
import os
import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed
from convert_crocolake_obs import ObsSequence
import logging
import pandas as pd

logging.basicConfig(
    level=logging.INFO, # Options: DEBUG, INFO, WARNING, ERROR, CRITICAL
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

crocolake_path = '$CROCOLAKE_PATH/0007_PHY_CROCOLAKE-QC-MERGED'

basename = "CL_obs_seq_"
outdir = "./in_CL_2023/"
BASENAME = os.path.expandvars(outdir+basename)
OUTDIR = os.path.expandvars(outdir)
CL_PATH = os.path.expandvars(crocolake_path)

# define horizontal region (LAT0, LAT1, LON0, LON1)
BOX = (5, 54, -98.5, -36)

# define variables to import from CrocoLake
SELECTED_VARS = [
    "DB_NAME",  # ARGO, GLODAP, SprayGliders, OleanderXBT, Saildrones
    "JULD", # this contains timestamp
    "LATITUDE",
    "LONGITUDE",
    "PRES", # This will be automatically converted to depths in meters
    "TEMP",
    "PRES_QC",
    "TEMP_QC",
    "PRES_ERROR",
    "TEMP_ERROR",
    "PSAL",
    "PSAL_QC",
    "PSAL_ERROR"
]

def generate_one_day(date0, SELECTED_VARS, BOX, BASENAME, OUTDIR, CL_PATH):

    # generate output filename
    obs_seq_out = BASENAME + f".{date0:%Y%m%d}.out"
    if os.path.exists(obs_seq_out):
        logging.info(f"File {obs_seq_out} already exists, skipping.")
        return

    LAT0 = BOX[0]
    LAT1 = BOX[1]
    LON0 = BOX[2]
    LON1 = BOX[3]

    date1 = date0 + datetime.timedelta(days=1)
    logger.info(f"Converting obs between {date0} and {date1}")

    # this defines AND filters, i.e. we want to load each observation that has latitude within the given range AND longitude within the given range, etc.
    # to exclude NaNs, impose a range to a variable
    and_filters = (
        ("LATITUDE",'>',LAT0),  ("LATITUDE",'<',LAT1),
        ("LONGITUDE",'>',LON0), ("LONGITUDE",'<',LON1),
        ("PRES",'>',-1e30), ("PRES",'<',1e30),
        ("JULD",">",date0), ("JULD","<",date1)
    )

    # this adds OR conditions to the and_filters, i.e. we want to load all observations that statisfy the AND conditions above, AND that have finite salinity OR temperature values
    db_filters = [
        list(and_filters) + [("PSAL", ">", -1e30), ("PSAL", "<", 1e30)],
        list(and_filters) + [("TEMP", ">", -1e30), ("TEMP", "<", 1e30)],
    ]

    # generate obs_seq.in file
    obsSeq = ObsSequence(
        CL_PATH,
        SELECTED_VARS,
        db_filters,
        obs_seq_out=obs_seq_out,
        loose=True
    )
    obsSeq.write_obs_seq()
    return

def main():

    parser = argparse.ArgumentParser(description='Script to generate 1 day of CrocoLake in obs sequence format.')
    parser.add_argument(
        '-r', '--refdate', type=datetime.date.fromisoformat,
        help="Date to which ndays is added (in YYYY-MM-DD format, e.g. 2023-12-31)",
        required=True
    )
    parser.add_argument(
        '-n', '--ndays', type=int,
        help="The day to generate, as the n-th day from refdate (integer, n=0 is the refdate)",
        required=True
    )
    args = parser.parse_args()

    logger.info(f"refdate: {args.refdate}")
    logger.info(f"ndays:   {args.ndays}")
    
    if not os.path.exists(OUTDIR):
        os.makedirs(OUTDIR, exist_ok=True)

    # we loop to generate one file per day
    date0 = pd.Timestamp(args.refdate)
    date0 += datetime.timedelta(days=args.ndays)
    logger.info(f"date0:   {date0}")

    try:
        generate_one_day(
            date0,
            SELECTED_VARS,
            BOX,
            BASENAME,
            OUTDIR,
            CL_PATH
        )

    except Exception:
        logger.exception(f"Failed for {date0:%Y%m%d}")
        return False

    logger.info("All done!")
    return

if __name__ == "__main__":
    main()

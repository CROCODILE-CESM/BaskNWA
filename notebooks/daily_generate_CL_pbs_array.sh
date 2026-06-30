#!/usr/bin/env sh
#PBS -N CL_2023_array
#PBS -A P93300012
#PBS -q casper
#### Each array sub-job will be assigned 10 GB of memory
#PBS -l select=1:mem=10GB
#PBS -l walltime=00:10:00
### Request 365 sub-jobs with array indices spanning 0-364
#PBS -j oe
#PBS -J 0-364

module purge
module load conda
cd /glade/work/emilanese/BaskNWA/notebooks/
conda activate NWA-model2obs
echo "PBS_ARRAY_INDEX" ${PBS_ARRAY_INDEX}
python generate_CL_obs_seq_daily.py -r 2023-01-01 -n ${PBS_ARRAY_INDEX}

#!/bin/bash
# These are the PBS Directives
#PBS -N m2o_NWA23_tr
#PBS -q casper
#PBS -A P93300012
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=34:mem=354gb:cpu_type=cascadelake

# Environment Management
module purge
module load ncarenv/24.12
module load cuda/12.3.2
module load openmpi/5.0.6
module load hdf5/1.12.3
module load intel/2025.3.2
module load ucx/1.17.0
module load ncarcompilers/1.0.0
module load netcdf/4.9.2
module load conda

JOBDIR=/glade/work/emilanese/BaskNWA/oleander_study
cd $JOBDIR

conda activate NWA-model2obs
python3 m2o_NWA2023_transect.py

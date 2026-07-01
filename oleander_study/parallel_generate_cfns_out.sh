#!/usr/bin/env sh
#PBS -N cfns_in_2023_array
#PBS -A P93300012
#PBS -q casper
#### Each array sub-job will be assigned 10 GB of memory
#PBS -l select=1:mem=5GB
#PBS -l walltime=00:10:00
### Request 365 sub-jobs with array indices spanning 0-364
#PBS -j oe
#PBS -J 0-364

module purge
module load conda
cd /glade/work/emilanese/BaskNWA/oleander_study
conda activate NWA-model2obs

files=(/glade/work/emilanese/BaskNWA/oleander_study/cfns_in/create_fixed_network_seq_2023*.in)
current_file="${files[$PBS_ARRAY_INDEX]}"
echo "Array Task Index: ${PBS_ARRAY_INDEX}"
echo "Processing File:  ${current_file}"

$DART_ROOT_PATH/models/MOM6/work/create_fixed_network_seq < "$current_file"

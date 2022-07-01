#!/bin/bash -l
#SBATCH -N 1
#SBATCH -n 4
#SBATCH -t 5:0:0
##SBATCH --mem 128G 
#SBATCH --gres=gpu:1
#SBATCH --job-name=water

module purge
module load anaconda3
conda activate /scratch/gpfs/yifanl/usr/licensed/anaconda3/2020.7/dp211

ln -s ../train_energy_model/frozen_model.pb frozen_model.pb

lmp -v TEMP 273 -v PRES 1.0 -in in.lammps > thermo.log
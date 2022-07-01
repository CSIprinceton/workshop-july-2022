#!/bin/bash
# Begin LSF Directives
#BSUB -P chp115
#BSUB -W 2:00
#BSUB -q debug
#BSUB -nnodes 1
#BSUB -J 64
#BSUB -o test.%J
#BSUB -e test.%J
#BSUB -alloc_flags gpudefault
#$$$#BSUB -alloc_flags "gpumps smt1"

export OMP_NUM_THREADS=1
date
module list

module unload darshan-runtime
module load cuda/10.1.243
module load ibm-wml-ce/1.6.2-3 
module load gcc/7.5.0
module load spectrum-mpi/10.3.1.2-20200121
module list

export OMP_NUM_THREADS=1
export TF_CPP_MIN_LOG_LEVEL=3

lmp_mpi=/ccs/home/chunyi/software/t1/lammps-stable_29Sep2021_update3/src/lmp_mpi
$lmp_mpi  -echo screen -in in.lammps >> output  

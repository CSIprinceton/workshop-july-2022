#!/bin/bash -l
#SBATCH --nodes 1
#SBATCH --tasks-per-node=20
#SBATCH --time=1:00:00          # total run time limit (HH:MM:SS)
#SBATCH --job-name="wannier" 



hostname
date

module load intel intel-mpi intel-mkl
PW=/tigress/bingjiay/softwares/QE_6.7/qe-6.7/bin/pw.x
W90=/home/pinchenx/data.gpfs/softwares/wannier90-3.1.0/wannier90.x
PWW90=/tigress/bingjiay/softwares/QE_6.7/qe-6.7/bin/pw2wannier90.x
kmesh=/home/pinchenx/data.gpfs/softwares/wannier90-3.1.0/utility/kmesh.pl

srun $PW -input scf.in > scf.out  
if test $? -eq 0; then 
    date > success.scf
else
    date > failed.scf
    exit 1
fi

srun $PW -input nscf.in > nscf.out 
if test $? -eq 0; then 
    date > success.nscf
else
    date > failed.nscf
    exit 1
fi

# generate .nnkp as the input of QE pw2wannier90
srun $W90 -pp water

# produce the matrices .mmn, .amn, .eig…
srun $PWW90 < water.pw2wan > pw2wan.out

#minimize the spread, calculate wannier function
srun $W90 water
if test $? -eq 0; then 
    date > success.wan
    rm *.amn
    rm *.chk
    rm *.mmn
else
    date > failed.wan
fi

date

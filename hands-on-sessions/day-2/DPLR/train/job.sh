#!/bin/sh
#PBS -l walltime=46:00:00
#PBS -N train
#PBS -q large
#PBS -l nodes=1

cd $PBS_O_WORKDIR
export OMP_NUM_THREADS=16
#module load cuda/10.1
#module load cudnn/7.4.2.24-cuda10.0

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/tun04379/scratch/software/miniconda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/tun04379/scratch/software/miniconda/etc/profile.d/conda.sh" ]; then
        . "/home/tun04379/scratch/software/miniconda/etc/profile.d/conda.sh"
    else
        export PATH="/home/tun04379/scratch/software/miniconda/bin:$PATH"
    fi
fi
unset __conda_setup
 #<<< conda initialize <<<

conda activate deepmd

dp train  input.json > train.out

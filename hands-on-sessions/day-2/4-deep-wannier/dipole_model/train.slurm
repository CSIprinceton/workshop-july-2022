#!/bin/bash
#SBATCH --job-name=myjob         # create a short name for your job
#SBATCH --nodes=1                # node count
#SBATCH --ntasks=1               # total number of tasks across all nodes
#SBATCH --cpus-per-task=1        # cpu-cores per task (>1 if multi-threaded tasks)
#SBATCH --time=23:00:00          # total run time limit (HH:MM:SS)
#SBATCH --gres=gpu:1
 

module purge
module load anaconda3
conda activate /scratch/gpfs/yifanl/usr/licensed/anaconda3/2020.7/dp211

dp train input.json  
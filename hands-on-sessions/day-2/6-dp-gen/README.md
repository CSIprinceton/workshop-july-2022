
Instruction for day 1 of the tutorial
===
#### July 13 @ Princeton CSI center
##### Tutors: Yixiao Chen (Princeton PACM), Marcos Calegari Andrade (Princeton CHEM), Linfeng Zhang (Princeton PACM)

# Aim and plan
The aim of this 2-hour hands-on session is to show you how to use DP-GEN at the basic level.

We will use the example of a single methane molecule and go through the whole DP-GEN process that 1) uses DeePMD-kit for training; 2) uses LAMMPS to explore the configuration space; and 3) uses QE to do ab initio calculations and prepare the training data. The output will be a uniformly accurate Deep Potential model for the methane molecule.

# Learning outcomes
Once this tutorial is completed, students will be able to:

+ get familar with the basic input and output files, the code structure, and the features of DeePMD-kit, LAMMPS, Quantum Espresso, and DP-GEN
+ write a simple DP-GEN input file and use it to generate models for other systems

# Quick start
For those who are using the virtual machine, there is a very fast way to start running DP-GEN. I'm assuming you have already cloned this repo or downloaded the [`dpgen-handson-restart.tgz`](./dpgen-handson-restart.tgz) file, also you are in the folder of this tarball. If not, use the following command to download it.
```bash
wget https://github.com/CSIprinceton/workshop-july-2020/raw/master/tutorial/Day-1/dpgen-handson-restart.tgz
```

To run the DP-GEN example, simply do the following:

1. unzip the file and go into the folder
   ```bash
   tar -zxvf dpgen-handson-restart.tgz
   cd dpgen-handson-restart
   ```
2. excute the script (Note here we use `.`(or `source`) to keep the environment. Make sure you have a **white space** between the dot `.` and `run.sh`)
   ```bash
   . run.sh
   ```

The whole procedure can take 2 hours to finish. So I suggest you start running it right now.

The `run.sh` script has only two lines.
```bash
source ./env.sh
nohup dpgen run param.json machine.json 1> out.log 2>&1 &
```
The first line source the `env.sh` file which set up the path variables and python environment. The second line runs DP-GEN and redirect its output. You can check the status of DP-GEN process by viewing the `out.log` or `dpgen.log` file.

## Environment preparation
If you are using the virtual machine, we have put everything you need in `$PATH` and prepared the environment in `env.sh`. Otherwise, you have to modify the `env.sh` to make sure the following:
- [DeePMD-kit][5] is installed in your current python envrionment. This can be easily done if you are using anaconda. 
- LAMMPS is compiled with DeePMD and installed in your PATH as `lmp`. This can also be simplified by conda. 
  To install the CPU version for DeePMD-kit and LAMMPS:
  ```bash
  conda install deepmd-kit=*=*cpu lammps-dp=*=*cpu -c deepmodeling
  ```
  To install the GPU version containing CUDA 10.0:
  ```bash
  conda install deepmd-kit=*=*gpu lammps-dp=*=*gpu -c deepmodeling
  ```
- [DP-GEN][6] is also installed in your current python environment and available as `dpgen` in your PATH.
  This can be installed via conda our pip. For conda,
  ```bash
  conda install -c conda-forge dpgen
  ```
- Quantum ESPRESSO (QE) is installed with `pw.x` available in your PATH.

The PATH settings are just for convenience of this tutorial. In later uses, one do not need to add all of these in PATH, but can specify the locations of the corresponding files in `machine.json`. One can check the one in `dpgen-previous-examples.tgz` for reference.

# Files provided
We provide three tarballs in this repo, while in this tutorial we would only use `dpgen-handson-restart.tgz`. The content of these tarballs are explained below.

- `dpgen-handson-raw.tgz` This is a minimal version that is runnable on the virtual machine (or any machine has the environment set up correctly).
- `dpgen-handson-restart.tgz` This is almost the same with the raw version, only that we have run the first training step for you, to save some time. It also exhibits the restart function of DP-GEN.
- `dpgen-previous-example.tgz` This is not runnable as it depends on the specific environment on our cluster (also the `params.json` is outdated). But one can check its `machine.json` for some real world settings of DP-GEN. Also one can check its `iter.00000*` folders for a previous running result. A tutorial note corresponding to this example can be found [here](https://hackmd.io/vO2fq6YsQ4ek5mYPDUbZGw).


# More resources
- **DeePMD-kit and DP-GEN**:
  - **papers**: See [DeePMD-PRL][1] for the original version of Deep Potential Molecular Dynamics. See ([DeepPot-SE-NIPS][2]) for the smooth version, which has gained more popularity. See [DeePCG-JCP][3] about how to develop coarse-grained models based on a similar approach. See [DPGEN-PRM][4] about the active learning procedure for the generation of reliable Deep Potential models.
  - **codes**: All codes are available on Github (https://github.com/deepmodeling). They are open source under the `GNU LGPLv3.0` liscense. In particular, the devel branch of the [deepmd-kit][5] and the [dpgen][6] repos are extremely active. 
  - **Q&A, discussion, and more information:** we recently lauched a website (http://bbs.deepmd.org/), hoping to better serve the community that uses deep learning tools for molecular simulation. It is still young. Any feedbacks are appreciated. We encourage the students to register and ask questions on the Q&A page.

[1]: https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.120.143001
[2]:http://papers.nips.cc/paper/7696-end-to-end-symmetry-preserving-inter-atomic-potential-energy-model-for-finite-and-extended-systems
[3]:https://aip.scitation.org/doi/full/10.1063/1.5027645
[4]:https://journals.aps.org/prmaterials/abstract/10.1103/PhysRevMaterials.3.023804
[5]:https://github.com/deepmodeling/deepmd-kit
[6]:https://github.com/deepmodeling/dpgen


# The DP-GEN example
We will explain step-by-step the input and output files and results of the `dpgen` code. We refer to additional slides for the second part of the tutorial.

## General Introduction 
`dpgen` does a series of iterations. In each iteration, there are three steps, `00.train`,  `01.model_devi` and ` 02.fp`.

+ 00.train: `dpgen` will train several (default 4) models based on exisiting training data. The only difference between these models is the random seed for the initialization of network parameters. **DeePMD-kit will be used for this step.**

+ 01.model_devi : model_devi for model deviation. `dpgen` will use models obtained from 00.train and run MD to explore the configuration space. For different structures, larger deviation (especially of forces) between the models created in 00.train indicates worse accuracy of the models. Using this criterion, a few structures will be selected and put into next stage `02.fp` for accurate calculations based on first-principle methods. **LAMMPS will be used for this step.**

+ 02.fp : Selected structures will be calculated by first-principle methods. `dpgen` will obtain some new data and put them together with initial data and data generated in previous iterations. After that a new training will be set up and `dpgen` will enter the next iteration. **QE will be used for this step.**

## Setups 
### Initial data for training and MD
We prepared two sets of data to kick off the DP-GEN process:
+ A set of initial training data. We prepared it here: `CH4.init.data/02.md/sys-0004-0001/deepmd`
+ A set of initial snapshots for the exploration stage. We prepared it here: `CH4.init.data/01.scale_pert/sys-0004-0001/scale-1.000/`

The snapshots for training and MD come from a direct MD simulation of CH4 at 50 K.

### DP-GEN Input files
You take a look by typing `dpgen run -h`. The following text and more information should appear on the screen:

```
usage: dpgen run [-h] PARAM MACHINE

positional arguments:
  PARAM       parameter file, json/yaml format
  MACHINE     machine file, json/yaml format

optional arguments:
  -h, --help  show this help message and exit
 ```

In the following parts, we will show you how to write `param.json` and `machine.json`.

### Writing `param.json`
This is where you define your job details, irrespective with the machine environments. We refer you to the [doc](https://github.com/deepmodeling/dpgen#run-main-process-of-generator) in DP-GEN repo for detailed explaination.

You can check the one we are using by 
```bash
cat param.json
```
In particular, the parameters we used in training the model (`default_training_param`) is relatively robust (expect for the learning rate part and stop batch, which should be much longer) and can be used as a starting point when you want to train your own model on your own systems. One can of course tune them to get better results. Among them, the learning rate part are the ones that you may feel like to tweak first.

### Writing `machine.json`

When switching into a new machine, you may modifying the `machine.json`, according to your own settings.
Once you have finished, the `machine.json` can be re-used for any DP-GEN tasks without any extra efforts. 

The one we are using is for local running within your `shell`. You can check it by
```bash
cat machine.json
```
There is also a `slurm` example in the `dpgen-previous-example.tgz` tarball. 

Again, we refer you to DP-GEN [doc](https://github.com/deepmodeling/dpgen#set-up-machine) for detailed explainations.


## Start Generator
### Basics
As explained previously, the core line in `run.sh` is the following (ignoring the `nohup` command that is used to keep the process alive even if you disconnect.)
```bash
dpgen run param.json machine.json 1> out.log 2>&1 &
```
`dpgen` identifies the current stage by a record file, `record.dpgen`, which will be created and upgraded by codes. Each line contains two number: the first is index of iteration, and the second ,ranging from 0 to 8 , records which stage in each iteration is currently running. Every time it starts, `dpgen` would first examine the existence of this file, and try to restart from it. This is the case in our tutorial, as we are restarting after step `0 2`. On the otherhand, if `record.dpgen` does not exist, dpgen would start from the begining.


For example, 0,1,2 in the second number correspond to `make_train`, `run_train`, `post_train`. `dpgen` will write scripts in `make_train`, run tasks by specific machine in `run_train` and collect results in `post_train`. The record for `model_devi` and `fp` stage follows similar rules.

If the process of `dpgen` unfortunately stops by some reason, `dpgen` will automatically recover the main process by `record.dpgen`. You may also change it manually for your purpose, such as removing the last iterations and recovering from one checkpoint.

You will also see a series of folders `iter.*`. They correspond to the first number in `record.dpgen` and contain our main results that `dpgen` generates. In each folder, there're 3 sub-folders `00.train`, `01.model_devi` and `02.fp`, corresponding with 3 stages previously introduced.

| Index of iterations  | Stage in each iteration  | Process 
| :--------------- | :--------------------- | :-------------------------------------- |
| 0 | 0 | make_train
| 0 | 1 | run_train
| 0 | 2 | post_train
| 0 | 3 | make_model_devi
| 0 | 4 | run_model_devi
| 0 | 5 | post_model_devi
| 0 | 6 | make_fp
| 0 | 7 | run_fp
| 0 | 8 | post_fp

### Details of each iteration 

Now let's have a detailed look at each step of `dpgen`.
#### 00.train
First we check the (already prepared) training results in the first iteration.
```bash
cd iter.000000/00.train
ls
```
You'll see
```
000    002    data.init    graph.000.pb	graph.002.pb    
001    003    data.iters   graph.001.pb	graph.003.pb
```

Here `graph.00x.pb` , linked to `00x/frozen.pb`, is the model `deepmd-kit` generates.

Enter one folder, you will find:

`frozen_model.pb    input.json    lcurve.out`

+ `input.json` is the settings for `deepmd-kit` for current task.

+ `lcurve.out` records the training accuracy of energies and forces.

Let's check one of them to see the training results.
```bash
cd 001
head -n 2 lcurve.out  && tail -n 2  lcurve.out
```

You will see 
```
# batch      l2_tst    l2_trn    l2_e_tst  l2_e_trn    l2_f_tst  l2_f_trn         lr
      0    7.57e+01  7.24e+01    7.69e+00  7.71e+00    2.39e+00  2.29e+00    1.0e-03
  39000    8.36e-03  1.21e-02    5.83e-05  9.43e-05    8.10e-03  1.17e-02    6.4e-08
  40000    8.31e-03  1.21e-02    5.53e-05  1.49e-04    8.11e-03  1.18e-02    5.0e-08
```
The total number of batches here corresponds to our settings of `stop_batch` in `param.json`. 
The meaning of each column is indicated at first line. Column 2-7 stands total loss, loss of energy and loss of force for testing and training set, respectively. The last column is the learning rate. Here energies are given in eV and forces in eV/A. You can also use `gnuplot` to check how these losses converge. The one we care most is again column 6, the test loss of forces. (Enter `q` to quit gnuplot after you finished viewing it.)
```
gnuplot
set logscale xy
p 'lcurve.out' u 1:6 w l
```

Also, please note that this is only a tutorial example and the CH4 molecule is extremely simple, so that we can reach \~10 meV/A accuracy on forces within 40000 batches. In general usage, one may need to train millions of steps for a more complex system to reach similar accuracy (or even unreachable). A common strategy for longer training is to make the learning rate decay slower too, so that the final learning rate still falls into the range of 1e-7\~1e-8. 

Let's step forward.

#### 01.model_devi
From now on we are dealing with the results generated on your own machine. Everyone may see different results.

Go back and enter 
```bash
cd ../../../iter.000000/01.model_devi
``` 

You will see ten `task.*` folders ranging from `task.000.000000` to  `task.000.000009`.

You may randomly select one of them, like 
```bash
cd task.000.000006
ls
``` 
you will see
```
conf.lmp    input.lammps    model_devi.log	model_devi.out
```
+ `conf.lmp` serves as the initial point of MD.
+ `input.lammps` is the input file for LAMMPS, automatically generated by `dpgen`.
+ `model_devi.out` records the model deviation of concerned labels, energy and force, in MD. It serves as the criterion for selecting which structures and doing Ab-initio calculations. 

By `head model_devi.out`, you will see:
```
#       step         max_devi_e         min_devi_e         avg_devi_e         max_devi_f         min_devi_f         avg_devi_f
           0       9.343707e-01       2.288385e-01       3.738665e-01       8.401729e-03       6.477382e-03       7.289600e-03
          10       9.371803e-01       2.274761e-01       3.749860e-01       1.348967e-02       5.478629e-03       1.160542e-02
          20       9.424105e-01       2.288360e-01       3.771461e-01       2.169293e-02       8.194449e-03       1.773667e-02
          30       9.489608e-01       2.292192e-01       3.798002e-01       1.405901e-02       5.863203e-03       1.192985e-02
          40       9.525256e-01       2.271607e-01       3.812842e-01       5.866476e-03       4.941065e-03       5.518061e-03
```

`max_devi_f` is the error indicator that we use. This is the maxinum of the deviation of forces among all atoms. Here we focus on the deviation of atomic forces, as they directly relate to the dynamics. For configurations that can be well predicted by the potential model, this deviation value should be of same order as force loss of testing set during training (column 6 in `lcurve.out`). The model deviation also serves as a lower bound estimator of the accuracy of our prediction. The idea of DP-GEN is to select those points with large deviation and add them back into the new training set.

#### 02.fp

Now let's go back and enter to `fp` folder. 
```bash
cd ../../../iter.000000/02.fp
ls
```
You will see:

```
candidate.shuffled.000.out   rest_accurate.shuffled.000.out   rest_failed.shuffled.000.out
data.000    task.000.0000??
```

+ `candidate.shuffle.000.out`: records which structures will be seleted from last step `01.model_devi`. There are always far more candidates than the maximum `fp_task_max` you expect to calculate at one time. In this condition, `dpgen` will randomly choose up to `fp_task_max` strucures and form the folder `task.*.0000*`.
+ `rest_accurate.shuffle.000.out`: record the other structures where our model's is accurate enough (`max_devi_f` is less than `model_devi_f_trust_lo`) so there is no need to calculate them any more.
+ `rest_failed.shuffle.000.out`: similar to above, but these structures are too inacurate (larger than `model_devi_f_trust_hi`).This indicates there might be some error in the exploration procedure that the structure is too far away from expected ones.
+ `data.000`: After Ab-initio calculations, `dpgen` will collect these data and convert them into the format `deepmd-kit` needs. In the next iteration'.

## Results
Let's return to the home folder of dpgen and check the results.
```bash
cd ../../
wc -l iter.000000/02.fp/*out
```
we will see 
```
  557 iter.000000/02.fp/candidate.shuffled.000.out
  453 iter.000000/02.fp/rest_accurate.shuffled.000.out
    0 iter.000000/02.fp/rest_failed.shuffled.000.out
 1010 total
```

This means there are 557 out of 1010 structures in the fisrt iteration which could be candidates for DFT calculations. 

In `param.json`, we set `fp_task_max` to 30. So 30 structures are actually selected for DFT calculations.

However, in the second iteration `iter.000001`, when doing 
```bash
wc -l iter.000001/02.fp/*out
```

you may find
```
    29 iter.000001/02.fp/candidate.shuffled.001.out
  2981 iter.000001/02.fp/rest_accurate.shuffled.001.out
     0 iter.000001/02.fp/rest_failed.shuffled.001.out
  3010 total
```
*It's ok if you find these files do not exist. That means `dpgen` is still doing its job. Just take a rest and wait for a short time. It should take no longer than one hour for each iteration.*

It shows that there remain only 29 candidates. Notice that the number of MD steps we set in `iter.000001` is 3 times longer than in `iter.000000`.

The last iteration `iter.000002` will only contain `00.train` and will return 4 DP models of good qualities for CH4 at 50K.

Now, we have successfully generate a "uniformly" accurate potential energy model for CH4 at 50K. To have a model that works for larger temperature (and pressure ) range, one can keep adding iterations in `params.json` with different temperature and pressure conditions. A truly uniformly accurate model can be obtained after sufficiently many iterations.

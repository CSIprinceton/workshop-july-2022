# Molecular dynamics driven by deep potentials

Hands-on sessions - Day 1 - July 7, 2022

Molecular dynamics driven by deep potentials and learning the potential energy surface using DeePMD

## Aims

The aim of this tutorial is twofold. In part 1 of this hands-on session we will show how to run molecular dynamics (MD) simulations driven by deep potentials (machine learning potentials based on ab initio quantum mechanical calculations). Emphasis is made on the physics that are captured by these models and are absent in empirical potentials. During the second part of this tutorial we will learn the basics of training a potential using energies and forces obtained from DFT calculations.

## Objectives

The objectives of this tutorial session are:
- Learn to perform MD simulations driven by deep potentials using LAMMPS and the DeePMD-kit
- Understand the LAMMPS input file, in particular the lines relevant to use deep potentials
- Interpret and understand results of the MD simulations in the light of the physical phenomena captured by these models
- Understand that deep potentials are reactive, flexible, and polarizable
- Learn to train a model that reproduces an ab initio potential energy surface
- Use of the commands ```dp train``` and ```dp test``` of the DeePMD-kit
- Understand that regions of configuration space that are not well represented in the training set are not well described by the trained model

## Prerequisites

It is assumed that the student is familiar with the linux command line. A working executable of LAMMPS and the DeePMD-kit is required.

## Part 1: Molecular dynamics simulations 

**This part needs about 1.5 hours to finish.**

In this part of the tutorial we will show how to calculate the structural and dynamic properties of liquid water and ice using DeePMD and LAMMPS.

Let's explore the LAMMPS input file ```liquid_water/300K/in.lmp```.
During the tutorial we will briefly describe all lines.
We will focus on the lines that determine the potential driving the dynamics:
```
pair_style deepmd ../../frozen_model_compressed.pb
pair_coeff * *
```
The first line specifies that we will use a deepmd model that is found in ```../../frozen_model_compressed.pb```.
We have obtained this model from the DP library described in tutorial session 1 ([link](https://dplibrary.deepmd.net/#/project_details?project_id=202206.001) to model).
This model was carefully trained to reproduce the potential energy surface of the SCAN DFT exchange and correlation functional in a broad range of temperatures and pressures conditions.
You can find further information about the model in [this paper](https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.126.236001).
The second line determines the species that are affected by this model. It must always be set to all vs all and is done with ```* *```.

### Liquid water at ambient conditions

Now let's run a simulation.
We will simulate liquid water at constant temperature 300 K and constant pressure 1 bar (NPT ensemble).
cd to the folder ```liquid_water/300K``` and run:
```
conda activate deepmd
lmp -in in.lmp
```
This simulation consists of 432 atoms, and should take a few minutes to finish.
On our machine with the V100 GPU, it takes about **5 minutes** to run 100000 steps. Since our timestep is 0.5 fs, we generate a 50-ps-long trajectory. 
We have computed the **radial distribution function** (RDF) on-the-fly in LAMMPS using these lines:
```
compute myRDF all rdf 100 1 1 1 2 2 2
fix 2 all ave/time 100 1 100 c_myRDF[*] file h2o.rdf mode vector ave running
```
We can watch the file `h2o.rdf` by `using head -n 10 h2o.rdf`:
```
# Time-averaged data for fix 2
# TimeStep Number-of-rows
# Row c_myRDF[1] c_myRDF[2] c_myRDF[3] c_myRDF[4] c_myRDF[5] c_myRDF[6] c_myRDF[7]
0 100
1 0.03 0 0 0 0 0 0
2 0.09 0 0 0 0 0 0
3 0.15 0 0 0 0 0 0
4 0.21 0 0 0 0 0 0
5 0.27 0 0 0 0 0 0
6 0.33 0 0 0 0 0 0
```
You need to check the [LAMMPS documentation](https://docs.lammps.org/compute_rdf.html) to find out what these colume are.
Obtain the final, averaged radial distribution functions using:
```
tail -n 101 h2o.rdf > myrdf.txt
``` 
Now plot the partial distributions functions O-O, O-H, and H-H that are found in ```myrdf.txt```.
For instance, plot column 2 vs 3, 2 vs 5, and 2 vs 7 to get the O-O, O-H, and H-H partial distributions functions, respectively.
A simple way to plot these functions is using ```gnuplot``` and, for instance, the command,
```
gnuplot --persist -e 'plot "myrdf.txt" u 2:3 w l'
```
Interpret and discuss the meaning of these functions.

> **_TIP:_** An example of plots obtained using matplolib and jupyter notebooks can be found in ```H2O_RDF.ipynb```.
> You can run the jupyter notebook on the virtual machine and open it in your local browser.
> In order to do this, first execute on the remote machine:
> ```
> nohup jupyter notebook --port=2333 &
> ```
> and then run in your local machine:
> ```
> ssh -N -f -L localhost:2333:localhost:2333 -p <port> <username>@<remote-machine-address>
> ```
> At the end of the ```nohup.out``` file you will find a link that you can copy and then paste into your browser.

Let's now turn to study the **diffusion coefficient** of oxigen and hydrogen.
During the previous MD run we computed the mean squared displacement and we used it to compute the diffusion coefficient (D) using Einstein's formula,

$$ D=\frac{1}{6}\frac{\mathrm{d}}{\mathrm{d}t}\langle\frac{1}{N}\sum_{i=1}^{N}(\mathbf{r}_i(t)-\mathbf{r}_i(0))^2\rangle . $$

These are the relevant lines in the LAMMPS input file:
```
compute msd_O Oatoms msd
compute msd_H Hatoms msd
fix store_msd_O all vector 10 c_msd_O[4]
fix store_msd_H all vector 10 c_msd_H[4]
variable fitslope_O equal slope(f_store_msd_O)/6/(10*dt)
variable fitslope_H equal slope(f_store_msd_H)/6/(10*dt)
fix 3 all ave/time 100 1 100 c_msd_O[4] c_msd_H[4] v_fitslope_O v_fitslope_H file diffusion.txt
```
The output can be found in the file ```diffusion.txt```.
Plot the MSD as a function of time, and the estimated diffusion coefficient vs time. You can use the jupyter notebook `liquid_water/300K/H2O_Diffusion.ipynb` to plot the MSD and diffusion coefficients.
An alternative approach to the calculation of the diffusion coefficient is described in the Jupyter Notebook ```liquid_water/optional_nve_diffusion/H2O_Diffusion.ipynb```.

The last task of this section is to **visualize the trajectory** using [Ovito](https://www.ovito.org/).
If needed, copy the LAMMPS dump and data files to your local computer using, for instance,
```
scp -P <port> <username>@<remote-machine-address>:~/workshop-july-2022/hands-on-sessions/day-1/2-molecular-dynamics-deepmd/liquid_water/300K/water* .
```
Note that on MacOS, if you need to use `*` in the `scp` command, you need to put the directory in quotes:
```
scp -P <port> "<username>@<remote-machine-address>:~/workshop-july-2022/hands-on-sessions/day-1/2-molecular-dynamics-deepmd/liquid_water/300K/water*" .
```
Now open the data file using ```ovito water.lammps-data```.
To load the trajectory use the modifier ```Load trajectory``` and choose the file ```water.lammps-dump-text```.
You can visualize the trajectory and test modifiers such as ```Create bonds``` and ```Smooth trajectory``` with window size 10.

Discuss the physics of this model in the light of the results obtained for the radial distribution functions, diffusion coefficient, and the visualization.
What are the differences with empirical models?

### Superionic ice

We will now study the transition from molecular ice VII, to superionic ice VII'', and to an ionic fluid.
Snapshots of these phases are shown below.

<p float="left">
  <img src="https://github.com/CSIprinceton/workshop-july-2022/raw/main/hands-on-sessions/day-1/2-molecular-dynamics-deepmd/images/ice-vii.png" width="250">
  <img src="https://github.com/CSIprinceton/workshop-july-2022/raw/main/hands-on-sessions/day-1/2-molecular-dynamics-deepmd/images/ice-viipp.png" width="250">
  <img src="https://github.com/CSIprinceton/workshop-july-2022/raw/main/hands-on-sessions/day-1/2-molecular-dynamics-deepmd/images/ionic-fluid.png" width="250">
</p>

You can run the simulations in ```superionic/900K```, ```superionic/1300K```, and ```superionic/1800K``` that correspond to these three phases, respectively.
As in the exercise above, first run the MD simulations in each folder.
All the three tasks consist of 1296 atoms, and each of them takes about **10 minutes** to run.
Then plot the radial distribution functions, the diffusion coefficient, and visualize the trajectories.
What are the main differences between these three phases?
What phenomena are captured by ab initio machine learning models that empirical potentials do not describe?

## Part 2: Learning the potential energy surface

**This part takes about 40 minutes to finish.**

In the previous section, we learned to run MD simulations using deep potentials.
Let's now see the tools available to create our own ab initio machine learning models.
Most models are trained in an iterative fashion using an active (or [concurrent](https://arxiv.org/abs/1910.12690)) learning approach.

<p align="center">
  <img src="https://github.com/CSIprinceton/workshop-july-2022/raw/main/hands-on-sessions/day-1/2-molecular-dynamics-deepmd/images/active_learning.png" width="350">
</p>

There are different options to obtain the configurations to start training the model:
- Extracting configuration from an ab initio molecular dynamics simulation
- Creating perturbations of the atomic coordinates starting from the equilibrium positions of a crystal structure
- Extracting configurations from an MD simulation driven by an empirical model or an available ab initio machine learning model (possibly trained at a different level of theory)

We will assume that appropriate training data has been obtained.
More on this topic will be covered in [tutorial session 6](https://github.com/CSIprinceton/workshop-july-2022/tree/main/hands-on-sessions/day-2/6-dp-gen).
Data for liquid water and ice Ih is provided in folders ```training/TrainingData/liquid-water-?``` and ```training/TrainingData/ice-and-liquid```.
These folders contain the following files:
```
coord.raw
box.raw
energy.raw
force.raw
type.raw
```
The appropriate format of these files is described in the [manual](https://docs.deepmodeling.com/projects/deepmd/en/master/data/system.html).
These files can be converted into a data type supported by the DeePMD-kit using the ```raw_to_set.sh``` script (see [manual](https://docs.deepmodeling.com/projects/deepmd/en/master/data/data-conv.html) for details).

Let's use this data for **training** a model that describes liquid water and ice Ih.
An appropriate input file for training is provided in ```training/Train```.
The input file is named ```input.json``` and we will describe the meaning of the different lines during the tutorial.
The training procedure can be started with the commands:
```
conda activate deepmd
dp train input.json
```
Information about the training procedure is found in the file ```lcurve.out``` and this is an excerpt of this file:
```
#  step      rmse_trn    rmse_e_trn    rmse_f_trn         lr
      0      2.56e+01      1.62e-01      8.10e-01    2.0e-03
   2000      4.17e+00      1.16e-02      1.32e-01    2.0e-03
   4000      3.55e+00      5.75e-02      1.12e-01    2.0e-03
   6000      2.85e+00      1.25e-02      1.05e-01    1.5e-03
   8000      2.87e+00      8.20e-03      1.06e-01    1.5e-03
  10000      2.64e+00      9.35e-03      1.13e-01    1.1e-03
```
The columns show the total root mean squared training error, the energy root mean squared error, the forces root mean squared error,and the learning rate.
It is useful to plot steps vs error to monitor the progress of the training.
Typical errors are around 1 meV/atom for the energy and 0.1 eV/A for the forces.

Once the training is complete, we can **freeze** the model using ```dp freeze```.
This will create a deep potential file ```frozen_model.pb``` that can be used for inference (running MD or simply computing energies/forces).
It is useful to **compress** the model using ```dp compress -i frozen_model.pb -t input.json```.
This will create a model ```frozen_model_compressed.pb``` that can perform inference significantly faster than ```frozen_model.pb```.

We can analyze the performance of our model in several ways.
One is calculating the root mean squared error in the forces and energy using
```
dp test -m <path/to/model>
```
This command has to be executed in a folder where a deepmd system can be found, for instance, ```training/TrainingData/ice-and-liquid```.
Do errors have the correct order of magnitude? 

We can also analyze the **correlation** between the energies obtained with DFT and inferred using the model.
This task can be easily accomplished using the following Python code snippet,
```
import dpdata
import numpy as np
from deepmd.infer import DeepPot

dp = DeepPot('frozen_model.pb')
system = dpdata.LabeledSystem('training/TrainingData/ice-and-liquid', fmt = 'deepmd/raw')
e, f, v = dp.eval(system['coords'], system['cells'], system['atom_types'])
energy_model = e.reshape([-1])
energy_dft=np.genfromtxt("training/TrainingData/ice-and-liquid/energy.raw")
```
Plot and analyze the correlation between ```energy_model``` and ```energy_dft```.
An example is provided in ```training/Test/script_correlation.py```.
Is the correlation between these quantities linear? Why is this so?

It is also frequent to plot the **distribution of errors** ```energy_model-energy_dft```.
Construct a histogram of this quantity (see example in ```training/Test/script_errors.py```).
What common probability distribution does this histogram resemble?
What is the spread of this distribution?

Another way to characterize the errors is using the idea of a committee of models.
This technique is of the utmost importance to characterize the **generalization error** of the models.
We will use this idea in the context of active learning in [tutorial session 6](https://github.com/CSIprinceton/workshop-july-2022/tree/main/hands-on-sessions/day-2/6-dp-gen).
Using the DeePMD-kit we can calculate the generalization error in the forces using the root mean square error (RMSE) between N models trained on the same data but different random seeds.
This is done using the following lammps input,
```
pair_style deepmd frozen_model_1.pb frozen_model_2.pb frozen_model_3.pb frozen_model_4.pb out_file md.out out_freq 10
pair_coeff * *
```
that will print the average, minimum, and maximum error to the file ```md.out```.
Run an MD simulation of liquid water at ambient conditions, and a simulation of ice VII''.
An example is provided in ```training/CommitteeError```.
Why is the error larger for ice VII'' than for liquid water?


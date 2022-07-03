# Deep Modeling for Molecular Simulation
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
- Understand the json input file of ```dp train```
- Understand that regions of configuration space that are not well represented in the training set are not well described by the trained model

## Prerequisites

It is assumed that the student is familiar with the linux command line. A working executable of LAMMPS and the DeePMD-kit.

## Part 1: Molecular dynamics simulations 

In this part of the tutorial we will show how to calculate the structural and dynamic properties of liquid water and ice using DeePMD and LAMMPS.

Let's explore the LAMMPS input file ```liquid_water/RDF/in.lmp```.
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
cd to the folder ```liquid_water/RDF``` and run:
```
conda activate deepmd
lmp -in in.lmp
```
This simulation should take a few minutes to finish.
We have computed the **radial distribution function** (RDF) on-the-fly in LAMMPS using these lines:
```
compute myRDF all rdf 100 1 1 1 2 2 2
fix 2 all ave/time 100 1 100 c_myRDF[*] file h2o.rdf mode vector ave running
```
You can find more information in [LAMMPS documentation](https://docs.lammps.org/compute_rdf.html).
Obtain the final, averaged radial distribution functions using:
```
tail -n 101 h2o.rdf > myrdf.txt
``` 
Now plot the partial distributions functions O-O, O-H, and H-H that are found in ```myrdf.txt```.
For instance, plot column 2 vs 3, 2 vs 5, and 2 vs 7 to get the O-O, O-H, and H-H partial distributions functions, respectively.
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
During the previous MD run we computed the mean squared displacement and we used it to compute the diffusion coefficient using Einstein's formula,

$$ D=\frac{1}{6}\frac{\mathrm{d}}{\mathrm{d}t}\langle\frac{1}{N}\sum_{i=1}^{N}(\mathbf{r}_i(t)-\mathbf{r}_i(0))^2\rangle $$

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
Plot the MSD as a function of time, and the estimated diffusion coefficient vs time.
An alternative approach to the calculation of the diffusion coefficient is described in the Jupyter Notebook ```liquid_water/Diffusion/H2O_Diffusion.ipynb```.

The last task of this section is to **visualize the trajectory** using [Ovito](https://www.ovito.org/).
If needed, copy the LAMMPS dump and data files to your local computer using, for instance,
```
scp -P <port> <username>@<remote-machine-address>:~/workshop-july-2022/hands-on-sessions/day-1/2-molecular-dynamics-deepmd/liquid_water/RDF/water* .
```
Now open the data file using ```ovito water.lammps-data```.
To load the trajectory use the modifier ```Load trajectory``` and choose the file ```water.lammps-dump-text```.
You can visualize the trajectory and test modifiers such as ```Create bonds``` and ```Smooth trajectory``` with window size 10.

Discuss the physics of this model in the light of the results obtained for the radial distribution functions, diffusion coefficient, and the visualization.
What are the differences with empirical models?

### Superionic ice

We will now study the transition from molecular ice VII, to superionic ice VII'', and to an ionic fluid.
You can run the simulations in ```superionic/900K```, ```superionic/1300K```, and ```superionic/1800K``` that correspond to these three phases, respectively.
As in the exercise above, first run the MD simulations in each folder.
Then plot the radial distribution functions, the diffusion coefficient, and visualize the trajectories.
What are the main differences between these three phases?
What phenomena are captured by ab initio machine learning models that empirical potentials do not describe?

## Part 2: Learning the potential energy surface

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

Now let's run a simulation.
We will simulate liquid water at 300 K and 1 bar.
cd to the folder ```liquid_water/RDF`` and run:
```
conda activate deepmd
lmp -in in.lmp
```
This simulation should take a few minutes to finish.
We have computed the radial distribution function on-the-fly in LAMMPS.
Now plot the partial distributions functions O-O, O-H, and H-H that are found in ```h2o.rdf```.

An example of plots obtained using matplolib and jupyter notebooks is found in ```H2O_RDF.ipynb```.
You can run the jupyter notebook on the virtual machine and open it in your local browser.
In order to do this, first execute on the remote machine:
```
nohup jupyter notebook --port=2333 &
```
and then run in your local machine:
```
ssh -N -f -L localhost:2333:localhost:2333 -p <port> <username>@<remote-machine-address>
```
At the end of this file you will find a link that you can copy and then paste into your browser.

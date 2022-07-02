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

In this part of the tutorial we will show how to calculate the structural and dynamic properties of liquid water using DeePMD and LAMMPS.

Let's explore the LAMMPS input file ```liquid_water/Diffusion/in.lmp```.
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

### Commands to Run the Simulation
```
conda activate deepmd
lmp -in in.lmp
```

### Use Jupyter Notebook to Process the Data
Run jupyter notebook on the machine:
```
nohup jupyter notebook --port=2333 &
```
Connect to it on your own computer:
```
ssh -N -f -L localhost:2333:localhost:2333 -p 4981 deepmdlabadmin@lab-b85f64a2-5e4b-4761-a76d-29e88aeb151a.eastus.cloudapp.azure.com
```
Use `vi nohup.out` to open it, use `Shift + G` to go to the last line of the file, and copy the address to the jupyter notebook. Then paste it into your browser.

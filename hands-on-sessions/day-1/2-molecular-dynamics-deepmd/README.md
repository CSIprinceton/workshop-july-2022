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

In this part of the tutorial we will show how to calculate the structural and dynamic properties of liquid water using DeePMD and LAMMPS. The 

We can use `ls` to see the files provided in this directory:
```
README.md                  frozen_model_compressed.pb liquid_water               superionic
```
- `frozen_model_compressed.pb` is the machine learning force field for trained from DFT data with the PBE functional.
- `superionic` contains the following 2 folders:
```
Diffusion RDF
```
- `liquid_water` also contains the 2 folders:
```
Diffusion RDF
```

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

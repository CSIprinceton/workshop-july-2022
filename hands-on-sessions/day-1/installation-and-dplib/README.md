# Deep Modeling for Molecular Simulation
Hands-on sessions - Day 1 - July 7, 2022

Installation of DeePMD-kit, visualization software and accessing the DP library

## Aims

DeePMD-kit is a package written in Python/C++ that implements deep learning algoritms for molecular simulation.
In particular, it is able to learn the potential energy surface, dipole moments, and polarizability from appropriate training sets based on electronic structure calculations.
The aim of this tutorial is to describe the available installation methods for DeePMD-kit and explore the DP library, a repository of models built using DeePMD-kit.

## Objectives

The objectives of this tutorial session are:
- Learn the available installation methods for DeePMD-kit and understand which one is appropriate for your laptop computer or HPC cluster.
- Illustrate the installation methods
- Describe common issues and how to solve them
- Install the visualization software Ovito and Xcrysden in order to use them in the tutorials
- Make the student aware of the existence of the DP library
- Promote new contributions to the DP library

## Prerequisites

It is assumed that the student is familiar with the linux command line and previous experience with conda and software compilation in linux is recommended.

## Installation of DeePMD-kit

The installation methods are thoroughly discussed in the deepmd-kit [manual](https://docs.deepmodeling.com/projects/deepmd/en/stable/install/index.html).
Here, we will discuss the different options in detail.
In most cases the easy install procedure based on the conda package manager is the best option and you can also use it in HPC facilities (clusters).

### Easy install using conda

This easy install procedure uses the conda package manager.
Anaconda is often available in computer clusters, sometimes through [Environment Modules](https://modules.readthedocs.io/en/latest/).
Assuming that conda is not installed, lets go through the installation steps for anaconda or miniconda.
Miniconda is a minimal installer and is therefore recommended.
You can obtain miniconda by downloading the appropriate file from this [website](https://docs.conda.io/en/latest/miniconda.html).
Assuming that you are using a linux command line in a standard x86-64 architecture, you can run:
```
chmod +x Miniconda3-py38_4.12.0-Linux-x86_64.sh
./Miniconda3-py38_4.12.0-Linux-x86_64.sh
```
and follow the instructions within that script.

Now that conda is installed, the deepmd-kit is simply installed with the command:
```
conda create -n deepmd deepmd-kit=*=*cpu libdeepmd=*=*cpu lammps-dp -c https://conda.deepmodeling.org
```
This command creates a conda environment ```deepmd``` and installs all the dependencies that are needed.
See the [manual](https://docs.deepmodeling.com/projects/deepmd/en/stable/install/easy-install.html#install-with-conda) for alternatives and for a suitable command to install a GPU version.

You can then enable the environment by running:
```
conda activate deepmd
```
and test that the ```dp``` (DeePMD-kit) and the ```lmp_mpi``` (LAMMPS) executables are available. 
If that works, congratulations! You are ready to do molecular dynamics simulations driven by ab initio machine learning potentials and much more!

### More complicated scenarios

In some situations, for instance when one needs to compile software in special computer architectures, the easy install procedure will not work because appropriate conda packages are not available.

#### Docker
One alternative is using a docker container.
You can find instruction to install docker [here](https://docs.docker.com/engine/install/).
In Ubuntu linux you can use:
```
sudo apt update
sudo apt install docker.io
```
Next you can get the image with:
```
docker pull ghcr.io/deepmodeling/deepmd-kit:2.0.0_cuda10.1_gpu
```
See also other available images in the DeePMD-kit [manual](https://docs.deepmodeling.com/projects/deepmd/en/stable/install/easy-install.html#install-with-docker).
The docker image can be run with the command:
```
docker run -it ghcr.io/deepmodeling/deepmd-kit:2.0.0_cuda10.1_gpu
```
and you can test that the executables ```dp``` and ```lmp``` are available. 

#### Installation from scratch


## Installation of visualization software

### Ovito

### Xcrysden

## Navigating the DP library

## Authors

This tutorial has been written mostly by Pablo Piaggi (ppiaggi at princeton.edu)

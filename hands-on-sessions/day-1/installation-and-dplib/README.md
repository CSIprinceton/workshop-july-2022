# Deep Modeling for Molecular Simulation
### Hands-on sessions - Day 1
### Installation of DeePMD-kit and accessing the DP library

## Aims

DeePMD-kit is a package written in Python/C++ that implements deep learning algoritms for molecular simulation.
In particular, it is able to learn the potential energy surface, dipole moments, and polarizability from appropriate training sets based on electronic structure calculations.
The aim of this tutorial is to describe the available installation methods for DeePMD-kit and explore the DP library, a repository of models built using DeePMD-kit.

## Objectives

The objectives of this tutorial session are:
- Learn the available installation methods for DeePMD-kit and understand which one is appropriate for your laptop computer or HPC cluster.
- Illustrate the installation methods
- Describe common issues and how to solve them
- Make the student aware of the existence of the DP library
- Promote new contributions to the DP library

## Prerequisites

It is assumed that the student is familiar with the linux command line and previous experience with conda and software compilation in linux is recommended.

## Installation of DeePMD-kit

The installation methods are thoroughly discussed in the deepmd-kit [manual](https://docs.deepmodeling.com/projects/deepmd/en/stable/install/index.html).
Here, we will discuss the different options in detail.
In most cases the easy install procedure that uses the conda package manager is the best option.

### Easy install using conda

First, lets install anaconda or miniconda.
Miniconda is a minimal installer and is therefore recommended.
You can install miniconda by downloading the appropriate installer from this [website](https://docs.conda.io/en/latest/miniconda.html).
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



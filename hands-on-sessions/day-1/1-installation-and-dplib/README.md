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

### Easy install 

#### Conda

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
conda create -n deepmd deepmd-kit=*=*cpu libdeepmd=*=*cpu lammps -c https://conda.deepmodeling.com
```
This command creates a conda environment ```deepmd``` and installs all the dependencies that are needed.
See the [manual](https://docs.deepmodeling.com/projects/deepmd/en/stable/install/easy-install.html#install-with-conda) for alternatives and for a suitable command to install a GPU version.

You can then enable the environment by running:
```
conda activate deepmd
```
and test that the ```dp``` (DeePMD-kit) and the ```lmp``` (LAMMPS) executables are available. 
If that works, congratulations! You are ready to do molecular dynamics simulations driven by ab initio machine learning potentials and much more!

#### Docker

An alternative to conda is using a docker container.
You can find instructions to install docker [here](https://docs.docker.com/engine/install/).
In Ubuntu linux you can use:
```
sudo apt update
sudo apt install docker.io
```
Next you can get the image with:
```
docker pull ghcr.io/deepmodeling/deepmd-kit:2.1.3_cuda10.2_gpu
```
See also other available images in the DeePMD-kit [manual](https://docs.deepmodeling.com/projects/deepmd/en/stable/install/easy-install.html#install-with-docker).
The docker image can be run with the command:
```
docker run -it ghcr.io/deepmodeling/deepmd-kit:2.1.3_cuda10.2_gpu
```
and you can test that the executables ```dp``` and ```lmp``` are available. 

### More complicated scenarios

#### Installation from scratch

In some situations, for instance when one needs to compile software in special computer architectures, the easy install procedure will not work because appropriate conda packages or a suitable docker image are not available.
In other instances, one might need optional LAMMPS packages that were not included in the conda package, or we may be interested in making modifications to the DeePMD-kit or LAMMPS source code.
In this case we will have no option but to compile from scratch.
We will have to get our hands dirty but it will be worthwhile! Patience and lots of coffee! (or your favorite caffeinated drink)

The instructions are described well in the DeePMD-kit [manual](https://docs.deepmodeling.com/projects/deepmd/en/stable/install/install-from-source.html).
The main issue is that DeePMD-kit has tensorflow as a dependency and its compilation is non trivial and time consuming.

## Installation of visualization software

### Ovito

We will use the Ovito visualization software to analyze the simulations in other tutorial sessions during the workshop.
Lets install it in your laptop or desktop computer!
The procedure is quite simple and you can find it [here](https://www.ovito.org/).

If you are using **linux** you can download a tarball file using this [link](https://www.ovito.org/download/3106/).
Then untar the file, cd to the appropriate folder and run,
```
tar -xf ovito-basic-3.7.6-x86_64.tar.xz
cd ovito-basic-3.7.6-x86_64/bin
./ovito
```

In **Windows**, just download the executable [here](https://www.ovito.org/) and follow the instructions in your screen.

During the workshop we will give a brief overview of Ovito's usage.

### Xcrysden

We will use Xcrysden to visualize the input and ouput files of Quantum ESPRESSO.
The installation instructions can be found [here](http://www.xcrysden.org/Download.html).
In Ubuntu linux (or in general, in debian-based distributions) the instructions are as follows:
```
apt install tk libglu1-mesa libtogl2 libfftw3-3 libxmu6 imagemagick openbabel libgfortran5
wget http://www.xcrysden.org/download/xcrysden-1.6.2-linux_x86_64-shared.tar.gz
tar -xf xcrysden-1.6.2-linux_x86_64-shared.tar.gz
cd xcrysden-1.6.2-bin-shared/bin
./xcrys
```

## Installation of Quantum ESPRESSO

In the [hands-on session 3](https://github.com/CSIprinceton/workshop-july-2022/tree/main/hands-on-sessions/day-1/3-quantum-espresso) we will illustrate basic concepts about DFT calculations using [Quantum ESPRESSO](https://www.quantum-espresso.org/). 
The basic installation steps for version 6.4.1 are,
```
wget https://github.com/QEF/q-e/archive/qe-6.4.1.tar.gz
tar -xf qe-6.4.1.tar.gz
cd q-e-qe-6.4.1
./configure
make -j 4 all
```

## Navigating the DP library

The DP library is a repository of Deep Potentials (DPs), i.e. potentials built with the DeePMD-kit.
You can access it using this link [dplibrary.deepmd.net](https://dplibrary.deepmd.net/#/).
We suggest that you play around and see the potentials that are available.

## Authors

This tutorial has been written mostly by Pablo Piaggi (ppiaggi at princeton.edu)

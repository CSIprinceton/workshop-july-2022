# Basics of DFT Calculations with Quantum-ESPRESSO

Hands-on sessions - Day 1 - July 7, 2022

Fundamentals of using Quantum-ESPRESSO for plane-wave DFT calculations of energies and forces in periodic systems.

## Objectives

This tutorial will demonstrate basic usage of the PW module of Quantum-ESPRESSO, a leading open-source software for electronic structure, focusing on the practical significances of key computational parameters and using crystalline Si as an example. This is intended as a practical tutorial for those who have not performed DFT calculations with QE in the past and will not cover the underlying physics and chemistry concepts. This exercise will cover how to benchmark and conduct ground state DFT simulations of periodic systems and extract results of relevance to the training of deep neural network potentials.

## Outline

This tutorial will accomplish the following:
- Necessary files and scripts for running QE calculations
- Anatomy of the QE input file + the physical and practical significance of various parameters
- Submitting QE jobs
- Benchmarking DFT parameters: an incomplete guide 
- Relationship between input file and atomic/crystal structure
- Parsing and understanding QE output
- Additional considerations + links: LibXC for SCAN/hybrid functionals, QE on GPUs

## Prerequisites

It is assumed that the participant has a general understanding of quantum mechanical calculations and proficiency with the linux command line. Additional experience with plane-wave basis sets, crystal structure, and other solid-state physics concepts will also be helpful. This tutorial is furthermore written for Workshop participants who will have access to virtual machines which have QE v6.4.1 compiled. Instructions for downloading and compiling QE can be found at https://github.com/QEF/q-e.

## Getting Started with Quantum-ESPRESSO

Running jobs with the PWSCF module of QE requires at minimum: 

1) the pw.x executable and its corresponding environment
2) an input file
3) pseudopotentials in UPF format 

Different types of pseudopotentials and their underlying physics are beyond the scope of this tutorial, but there are many publically available pseudopotential libraries. This tutorial will utilize a [ONCV pseudopotentials](http://quantum-simulation.org/potentials/sg15_oncv/upf/ "ONCV psp library") optimized for PBE calcultions.

As mentioned previously, the pw.x executable and environment will be readily available to participants of the tutorial.

Now we will begin by dissecting the QE input file using bulk Si as an example.

### Input file basics

The all-in-one guide for PWscf keywords is [here](https://www.quantum-espresso.org/Doc/INPUT_PW.html). This tutorial will address many of the most basic specifications.

Let's take a look at the file `si.in` located in this head directory, starting with the `&control` namelist:

```
 &control
   restart_mode = 'from_scratch',
   calculation  = 'scf',
   prefix       = 'si',
   outdir       = './',
   pseudo_dir = './',
   tprnfor = .true.,
 /
```
Start by noting the formatting of namelists; the `&` starts the namelist and the `/` terminates it. Keywords are separated by commas (and for our convenience but not necessarily, line breaks). `restart_mode = 'from_scratch',` implies that we are starting a calcualtion from scratch rather than restarting. `calculation  = 'scf',` entails that we are running a single-point self-consistent field (SCF) energy calculation. The prefix keyword sets the nomenclature for all output files. The `outdir` and `pseudo_dir` keywords specify the desired location of the outputs and pseudopotentials, respectively. In both cases, that will be the present directory `./`. Lastly, and importantly for DPMD applications `tprnfor = .true.,` will ensure that the atom-centered forces will be printed in the QE output.











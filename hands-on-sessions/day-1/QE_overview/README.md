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

Running jobs with the PWSCF module of QE requires at minimum: 1) the pw.x executable, 2) an input file, and 3) pseudopotentials in UPF format. Types of pseudopotentials and their underlying physics are beyond the scope of this tutorial, but there are many publically available pseudopotential libraries. This tutorial will utilize [ONCV pseudopotentials](http://quantum-simulation.org/potentials/sg15_oncv/upf/ "ONCV psps") optimized for PBE calcultions

Code:
```
Command line things
```


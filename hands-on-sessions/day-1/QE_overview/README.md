# Basics of DFT Calculations with Quantum-ESPRESSO

Hands-on sessions - Day 1 - July 7, 2022

Fundamentals of using Quantum-ESPRESSO for plane-wave DFT calculations of energies and forces in periodic systems.

## Objectives

This tutorial will demonstrate basic usage of the PW module of Quantum-ESPRESSO, focusing on the practical significances of key computational parameters and using crystalline Si as an example. This is intended to be a practical tutorial for those who have not performed DFT calculations with QE in the past and will not cover the underlying physics and chemistry concepts. This exercise will cover how to benchmark and conduct ground state DFT simulations of periodic systems and extract results of relevance to the training of deep neural network potentials. Specifically, this tutorial will explicate the importance of using sufficiently converged electronic structure methods for reliably obtaining the energies and atom-centered forces.

## Outline

This tutorial will accomplish the following:
- Overview of the necessary scripts and inputs for performing QE calculations
- Anatomy of the QE input file + the physical and practical significance of various parameters
  - Incomplete guide to benchmarking DFT protocol 
  - Relationship between input file and crystal/molecular structure
- Submitting QE jobs
- Parsing and understanding QE output
- Additional considerations + links: LibXC for SCAN and other functionals, QE on GPUs

## Prerequisites

It is assumed that the participant has a general understanding of quantum mechanical calculations and proficiency with the linux command line. Additional experience with plane-wave basis sets, crystal structure, and other solid-state physics concepts will also be helpful. However, this is intended as a practical guide for those who have not used QE or performed DFT calculations previously. This tutorial is furthermore written for Workshop participants who will have access to virtual machines which have QE v??? compiled. Instructions for downloading and compiling QE can be found at https://github.com/QEF/q-e.

## Quantum-ESPRESSO

### Subhed

Code:
```
Command line things
```


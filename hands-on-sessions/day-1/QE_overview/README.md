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
- Additional considerations + links

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

### Input file anatomy

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

Next, let's look at the `&system` namelist:

```
 &system
    ibrav=2,
    celldm(1) = 10.20,
    nat=2,
    ntyp=1,
    ecutwfc=12.0
    input_dft='pbe'
 /
```
`ibrav=2` indicates that our system has cubic FCC structure and symmetry, with `celldm(1)` defining the relevant lattice vector in au (bohr). QE's algorithms exploit crystal symmetries to accelerate calculations. Xcrysden can be used to visualize QE input and output files directly. With the corresponding symmetry, you can visualize both the conventional and primitive unit cells.

![image](https://user-images.githubusercontent.com/59068990/176943208-9a82fdb4-4c79-4393-872e-769a85220924.png)

NB: Crystal structure is beyond the scope of this tutorial, however, it is worth mentioning that non-crystalline (i.e. liquid, gaseous, interfacial) systems will use the `ibrav=0` option, in which the 3 x 3 lattice parameters must be specified explicitly. For an orthorhombic cell, all the off-diagonal elements would be zero. 

Straightforwardly, `nat` refers to the number of atoms and `ntyp` is the number of types of atoms. `ecutwfc` refers to the cutoff energy of the basis set planewaves. The higher this value, the more planewaves that are used, resulting in a slower, but more accurate calculation. We will explore the benchmarking of this value shortly. Lastly, `input_dft` indicates the DFT functional to be used in the calculation. The default value of this is the functional associated with the pseudopotential, so we wouldn't need to explicitly state this value in our case since we are using PBE, but it is included here to demonstrate where one would indicate the usage of e.g. SCAN functional.

Next is `%electrons`:

```
 &electrons
    conv_thr    = 1.D-6,
    mixing_beta = 0.5D0,
    startingwfc = 'atomic+random',
    startingpot = 'atomic',
 /
```

`conv_thr` is the energy convergence threshold for the SCF calculation. For the purposes of this tutorial we will leave it at the default. Lower values may be justifiable for larger systems further from equilibrium and/or to have an initial converged solution on which to improve. The `mixing_beta` parameter is an internal one related to the step-to-step perturbation of the trial wavefunction. We will not modify it in this tutorial but it is worth mentioning that smaller values typically yield slower but more stable paths to convergence. The `startingwfc` and `startingpot` are the initial wavefuncitons and potentials, respectively. We will not be modifying these keywords in this tutorial.

Lastly we come to the cards associated with the structure and k-points:

```
ATOMIC_SPECIES
 Si  28.086  Si_ONCV_PBE-1.0.upf
ATOMIC_POSITIONS (alat)
 Si 0.00 0.00 0.00
 Si 0.25 0.25 0.25
K_POINTS automatic
 1 1 1 1 1 1
```
Note that these cards have different syntax than the above namelists. `ATOMIC_SPECIES` indicates our only species, Si, along with its atomic mass and the name of the corresponding pseudopotential file.

`ATOMIC_POSITIONS` is formatted in a familiar way: the type of atom and its 3D coordinates. In this input file we are exploiting the cubic symmetry so the positions are in units of the lattice vector, denoted by `alat`. This can be modified to `Angstrom` for non-symmetric systems. The two Si atoms are positioned at the typical FCC cubic sites.

Last, `K_POINTS` refers to the sampling of the Brillouin Zone performed in the calculation. The technical details here are beyond the scope of this tutorial but we will investigate the need to benchmark this value. 

### Running QE jobs

With all of our necessary components ready we can run a simple QE job. In the tutorial virtual machines you may run these from the command line, but for best practices we will use a submit script `sub.sh`.

*TBD once I have access to VMs*

### Benchmarking DFT protocol

It is critical that one benchmarks their DFT protocol, especially given that the accuracy of the DFT calculation is ultimately what a DP will achieve with sufficient training. Here we will demonstrate how to benchmark two of the most important aspects of QE DFT: `ecutwfc` and the k-points.

K-points:

![image](https://user-images.githubusercontent.com/59068990/176946171-a06cdcdb-c34d-4718-a096-965bf16a94d3.png)

*Add time to convergences

Ecutwfc:

![image](https://user-images.githubusercontent.com/59068990/176946588-de150d9f-2462-4ac8-b4f5-3d4e0c88a07c.png)

*Add time to convergence

### Parsing QE Output

*Add Si @ different geometries and show atomic forces

### Additional considerations and links

*LibXC, QE for GPUs, etc.


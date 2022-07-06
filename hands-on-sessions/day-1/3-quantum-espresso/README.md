# Basics of DFT Calculations with Quantum-ESPRESSO

Hands-on sessions - Day 1 - July 7, 2022

Fundamentals of using Quantum-ESPRESSO for plane-wave DFT calculations of extended systems.

## Objectives

This tutorial will demonstrate basic usage of the PW module of Quantum-ESPRESSO, a leading open-source software for electronic structure, focusing on the practical significances of key computational parameters and using crystalline Si as an example. This is intended as a practical tutorial for those who have not performed DFT calculations with QE in the past and will not cover the underlying physics and chemistry concepts. This exercise will cover how to benchmark and conduct ground state DFT simulations of periodic systems and extract results of relevance to the training of deep neural network potentials.

## Outline

This tutorial will cover the following:
- Necessary files and scripts for running QE calculations
- Anatomy of the QE input file 
- Submitting QE jobs in serial and parallel
- Parsing and understanding QE output
- Exercises:
  - Benchmarking DFT parameters
  - Geometry relaxation

## Prerequisites

It is assumed that the participant has a general understanding of quantum mechanical calculations and proficiency with the linux command line. Additional experience with plane-wave basis sets, crystal structure, and other solid-state physics concepts will also be helpful. This tutorial is furthermore written for Workshop participants who will have access to virtual machines which have QE v6.4.1 compiled. Instructions for downloading and compiling QE can be found at https://github.com/QEF/q-e.

## Running a DFT Calculation with QE

Running jobs with the PWSCF module of QE requires at minimum: 

1) The `pw.x` executable and its corresponding environment
2) Pseudopotentials in UPF format 
3) An input file

As mentioned previously, the `pw.x` executable and environment are readily available to participants with access to the VM. You can find the executable in the VM at `~/QE/q-e-qe-6.4.1/bin/pw.x`. Otherwise, follow the instructions for downloading and compiling QE on your machine.

> Those using the VMs with the `deepmd` conda environment loaded can simply call `pw.x` without the path. This tutorial was designed to work in the absence of this environment. If `deepmd` is loaded it is recommended that you remove it with `conda deactivate`.

Different types of pseudopotentials and their underlying physics are beyond the scope of this tutorial, but there are many publically available pseudopotential libraries. This tutorial will utilize an [ONCV pseudopotential](http://quantum-simulation.org/potentials/sg15_oncv/upf/ "ONCV psp library") for Si optimized for PBE calcultions. To retrieve this pseudopotential do the following:

```
wget http://quantum-simulation.org/potentials/sg15_oncv/upf/Si_ONCV_PBE-1.0.upf
```

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
    ecutwfc=24.0
    input_dft='pbe'
 /
```
`ibrav=2` indicates that our system has cubic FCC structure and symmetry, with `celldm(1)` defining the relevant lattice vector in au (bohr). QE's algorithms exploit crystal symmetries to accelerate calculations. `Xcrysden` can be used to visualize QE input and output files directly. With the corresponding symmetry, you can visualize both the conventional and primitive unit cells. On a machine with `Xcrysden` loaded, go to the directory of `si.in` and do: 

```
xcrysden --pwi si.in
```

![image](https://user-images.githubusercontent.com/59068990/176943208-9a82fdb4-4c79-4393-872e-769a85220924.png)

NB: Crystal structure is beyond the scope of this tutorial, however, it is worth mentioning that non-crystalline (i.e. liquid, gaseous, interfacial) systems will use the `ibrav=0` option, in which the 3 x 3 lattice parameters must be specified explicitly. For an orthorhombic cell, all the off-diagonal elements would be zero. 

Straightforwardly, `nat` refers to the number of atoms and `ntyp` is the number of types of atoms. `ecutwfc` refers to the cutoff energy of the basis set planewaves. The higher this value, the more planewaves that are used, resulting in a slower, but more accurate calculation. We will explore the benchmarking of this value shortly. Lastly, `input_dft` indicates the DFT functional to be used in the calculation. The default value of this is the functional associated with the pseudopotential, so we wouldn't need to explicitly state this value in our case since we are using PBE, but it is included here to demonstrate where one would indicate the usage of e.g. SCAN functional.

Next is `&electrons`:

```
 &electrons
    conv_thr    = 1.D-6,
    mixing_beta = 0.5D0,
    startingwfc = 'atomic+random',
    startingpot = 'atomic',
 /
```

`conv_thr` is the energy convergence threshold for the SCF calculation. For the purposes of this tutorial we will leave it at the default. Lower values may be justifiable for larger systems further from equilibrium and/or to have an initial converged solution on which to improve. The `mixing_beta` parameter is an internal one related to the step-to-step perturbation of the trial wavefunction. We will not modify it in this tutorial but it is worth mentioning that smaller values typically yield slower but more stable paths to convergence. The `startingwfc` and `startingpot` are the initial wavefuncitons and potentials, respectively. We will not be modifying these keywords in this tutorial.

Lastly we come to the cards (note that these are not namelists and have different syntax) associated with the structure and k-points:

```
ATOMIC_SPECIES
 Si  28.086  Si_ONCV_PBE-1.0.upf
ATOMIC_POSITIONS (alat)
 Si 0.00 0.00 0.00
 Si 0.25 0.25 0.25
K_POINTS automatic
 4 4 4 1 1 1
```
`ATOMIC_SPECIES` indicates the only species, Si, along with its atomic mass and the name of the corresponding pseudopotential file.

`ATOMIC_POSITIONS` is formatted in a familiar way: the type of atom and its 3D coordinates. In this input file we are exploiting the cubic symmetry so the positions are in units of the lattice vector, denoted by `alat`. This can be modified to `Angstrom` for non-symmetric systems. The two Si atoms form the basis of the cubic diamond crystal structure.

Last, `K_POINTS` refers to the sampling of the Brillouin Zone performed in the calculation. The technical details here are beyond the scope of this tutorial but we will investigate the need to benchmark this value. 

### Running QE jobs

With all of our necessary components ready we can run a simple QE job. In the tutorial virtual machines we will run these from the command line and with shell scripts, however, on larger computing clusters and for longer jobs it is likely that you would prepare a submit script according to the cluster's scheduler (e.g. Slurm/PBS).

Let's start by simply running the calculation using `si.in` here in the top directory by doing:

```
~/QE/q-e-qe-6.4.1/bin/pw.x < si.in
```

The `<` following the path to the executable should precede the input file. Running the job this way prints the output to terminal. This isn't very practical. Let's re-run the job and write to an output file `si.log`:

```
~/QE/q-e-qe-6.4.1/bin/pw.x < si.in > si.log
```

Now you will see the same output written to `si.log`. 

### Parsing QE output

So, what happened when we ran the job? In brief, QE iteratively converged the eigenvectors and eigenvalues of the Si system starting from some initial guess. 

To see the total energy of the SCF calculation, open up the log file and find the character `!`. The lines following this total energy will document its constituent terms, say how many iterations were required for convergence, and also print the forces on each atom. For Si at equilibrium, the forces will be zero.

```
 !    total energy              =     -15.76056206 Ry
      Harris-Foulkes estimate   =     -15.76056209 Ry
      estimated scf accuracy    <       0.00000026 Ry
 
      The total energy is the sum of the following terms:
 
      one-electron contribution =       4.89078263 Ry
      hartree contribution      =       1.08353893 Ry
      xc contribution           =      -4.83512504 Ry
      ewald contribution        =     -16.89975858 Ry
 
      convergence has been achieved in   5 iterations
 
      Forces acting on atoms (cartesian axes, Ry/au):
 
      atom    1 type  1   force =    -0.00000000    0.00000000   -0.00000000
      atom    2 type  1   force =     0.00000000   -0.00000000    0.00000000
 
      Total force =     0.000000     Total SCF correction =     0.000000

```

Let's also look at the progression of the calculation to convergence with:

```
grep "total energy              =" si.log
```

You should see the energy decrease monotonically to the final energy. 

We can also see how long the calculation took by looking in the last few lines of the output:

```
PWSCF        :      0.23s CPU      0.91s WALL
```

### Running QE jobs in parallel with `mpirun` 

> `mpirun` is not compatible with the `deepmd` conda environment activated. Do `conda deactivate` if it is or proceed to the exercises and modify the shell scripts accordingly.

Now let's try running the job on multiple CPUs. Let's move to the folder `ncpu`, where you will see a shell script `run_parallel.sh`. Let's look at this script:

```
cp ../Si_ONCV_PBE-1.0.upf .

for i in 1 2 3 4 ;
  do
  mpirun -np $i ~/QE/q-e-qe-6.4.1/bin/pw.x < si.in > si${i}.log
  done
```

Here we are invoking `mpirun` using `-np` to designate the number of processors (CPUs) with which to run the calculation. We will use 1-4 CPUs here with the same input file `si.in` and write different output files `si?.log`. 

Run the script with `./run_parallel.sh`. What differences exist between our job outputs having used different numbers of processors? First, let's check the energies:

```
grep ! si?.log
```

The energies should be the same up to at least the first few decimal places. Now let's look at the CPU times:

```
grep "PWSCF        :" si?.log
```

You should see that CPU and WALL times decrease with each additional processor used, even for our tiny system. Terrific!

## Exercises: Benchmarking and Geometry

### Benchmarking DFT protocol

It is critical that one benchmarks their DFT protocol, especially given that the accuracy of the DFT calculation is ultimately what a machine-learned potential will achieve with sufficient training. Here we will demonstrate how to benchmark two of the most important aspects of QE DFT: `ecutwfc` and the number of k-points.

1. `Ecutwfc`:

In plane-wave DFT calculations, one should use a plane-wave energy cutoff that is sufficiently high such that the computed energy for a sample system is stable with respect to this cutoff.

Move to the directory `ecut`. Therein you will find a shell script, `run_ecut.sh`. This script will write copies of `../si.in` here with modified values of `ecutwfc` and run the calculations. In other words, we are exploring how the number of plane-waves (basis set size) affects the energy and time to solution. Run this script doing `./run_ecut.sh`.

Let's first look at what our input files look like with `grep ecutwfc si??.in`. They represent a range of energy cutoffs from 12-36 Ry. Next, let's look at the computed energies with

```
grep ! si??.log
```

Notice that the energy decreases with increasing `ecutwfc`, with diminishing returns at higher and higher values. A properly benchmarked calculation would use a `ecutwfc` from beyond the point at which the energy doesn't change much. Feel free to plot your computed energies vs. `ecutwfc` as shown here.

![image](https://user-images.githubusercontent.com/59068990/176946588-de150d9f-2462-4ac8-b4f5-3d4e0c88a07c.png)

> Plotting with gnuplot on the VM: If you are connecting to the VM from a machine with X11, ssh with -X or -Y. Then you can use gnuplot on the VM. To quickly plot the energy vs `ecutwfc` run the following snippet as a shell script:

> ```
> for i in 12 18 24 30 36 ; 
>   do
>   en=`grep ! "si${i}.log" | awk '{print $5}'`
>   echo "$i $en" >> ens.dat
>   done
> ```
> Then you can plot this data file with:
> 
> ```
> gnuplot
> p 'ens.dat' w l title "E (Ry)" 
> ```

It should also be noted that using a larger `ecutwfc` slows down the time to convergence. Do 
```
grep "PWSCF        :" si??.log
```
to see the calculation times.

2. K-points:

Similarly, one should converge the energy with respect to the number of k-points sampled in a periodic system. This may not be applicable to liquid systems with large system sizes. But, for an extended solid it is critical.

Move to the directory `kpoints`. Therein you will find a shell script, `run_kp.sh`. This script will write copies of `../si.in` here with modified values of in the `K_POINTS` card and run the calculations. Run this script doing `./run_kp.sh`.

Let's first look at what our input files look like with 
```
grep -A 1 K_POINTS si???.in
```
We have computed the energy using a range of k-point meshes from 1x1x1 to 6x6x6. For partially periodic systems (e.g. solid interfaces) one may use higher k-point samplings in the periodic dimensions. Now, look at the computed energies with

```
grep ! si???.log
```

Notice that the energy decreases a lot initially with larger k-point samplings and then seems to converge beyond 3x3x3. As with `ecutwfc`, we would want to use a k-point sampling within the converged region. If you can, try modifying the parsing and plotting instructions from the `ecutwfc` section to plot the energy vs. k-point grid size.

![image](https://user-images.githubusercontent.com/59068990/176946171-a06cdcdb-c34d-4718-a096-965bf16a94d3.png)

Once again, the more accurage/stable calculations will take a bit longer. Look at the computation times with:

```
grep "PWSCF        :" si???.log
```

### Geometry relaxation

Let's see what happens when we perturb the structure of our Si unit cell. Go to the `geom` directory and run the shell script `run_geom.sh`. This will write a new `si.in` file with the position of the 2nd Si atom moved out of equilibrium. Grep out the total energy from `si.log` and compare it to that from `../si.log`. It should be much higher.

There should also now be non-zero forces on our atoms. Look directly in the output or do

```
grep -B 5 "Total force" si.log
```

and you will see the forces on each atom and the total force.

Now let's relax the structure back to equilibrium. First open up `si-relax.in`. You will notice a few differences between this input file and the SCF input file. First, in the `&control` namelist,

```
calculation  = 'relax',
```

indicates that this is a relax calculation, not simply an SCF. Also,

```
forc_conv_thr = 1.0D-4
```
is added to the `&control` namelist. This is the force convergence threshold for the calculation. Finally, a relax calculation requires the inclusion of a `&ions` namelist. 

```
 &ions
    ion_dynamics = 'bfgs'
 /
```
Various other parameters in this namelist are beyond the scope of this tutorial. BFGS is the default relaxation algorithm. Otherwise note the non-equilibrium position of the Si atoms as we had in the SCF calculation.

To run the relax calculation, do:

```
mpirun -np 4 ~/QE/q-e-qe-6.4.1/bin/pw.x < si-relax.in > si-relax.log
```

In a relax calculation, an electronic SCF is converged for every ionic step towards lowering the forces below the threshold. Let's look at the convergence of the electronic energies and reduction of theforces over the course of the relax calculation. 

Energies:

```
grep ! si-relax.log
```

Forces:

```
grep "Total force" si-relax.log
```

Feel free to plot the progressions of the total energy and force as done below (left and right, respectively):

![image](https://user-images.githubusercontent.com/59068990/177489923-ac148e5d-7864-484f-9cb2-c63f36a794eb.png)

Now, look at the final coordinates for the two Si atoms. Open the `si-relax.log` file and find the last instance of `ATOMIC_POSITIONS`. You will notice that both Si moved according to the forces on them, so one Si atom is no longer at (0,0,0). Nonetheless, the forces are relaxed below the threshold and we can consider this the equilibrium structure for our computational protocol. 

You can use `Xcrysden` to visualize the relaxation as an animation. On a machine with `xcrysden` loaded and the log file:

```
xcrysden --pwo si-relax.log
```

Select to display all coordinates as an animation. You can also measure the Si-Si distance at the beginning of the calculation vs. at the end by using the `Distance` tool on the bottom of the `xcrysden` GUI, selecting the two atoms, then clicking `Done`.

### Additional considerations and links

- [LibXC](https://gitlab.com/libxc/libxc/-/releases) is the library QE uses for meta-GGA, hybrid, etc. functionals. Much of the pioneering DPMD work on water was trained with the SCAN functional, which requires LibXC to run in QE.
- QE has recently released NVidia [GPU-compatible versions](https://gitlab.com/QEF/q-e-gpu/-/tree/gpu-develop). The applications which GPUs currently accelerate are still an area of research.

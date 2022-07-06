# Deep Modeling with Long-Range Electrostatic Interactions (DPLR)
Hands-on sessions - Day 2 - July 8, 2022

## Overview
The DP models lack explicit long-range interactions and fail to describe properties that derive from the Coulombic tail of the forces. To overcome this limitation, DPLR extends the DP model by including the long-range electrostatic interactions, which improved the accuracy and predictive power of DP. 

DPLR approximates the long-range electrostatic interaction between ions (nuclei + core electrons) and valence electrons with that of distributions of spherical Gaussian charges located at ionic and electronic sites. The latter are rigorously defined in terms of the centers of the maximally localized Wannier distributions, whose dependence on the local atomic environment is modeled accurately by a deep neural network. In the DP long-range (DPLR) model, the electrostatic energy of the Gaussian charge system is added to short-range interactions that are represented as in the standard DP model. More details of the DPLR method can be found in [J. Chem. Phys. 156, 124107 (2022)]. 

## Objectives
The objectives of this tutorial session are:

1. Train a DPLR model
2. Compare the energy predicted by DP and DPLR using water dimer as an example
3. Run a DPLR molecular dynamics simulation of bulk liquid water

The data used in this tutorial are adapted from DP Library https://dplibrary.deepmd.net/#/project_details?project_id=202202.001 [Reference: J. Chem. Phys. 156, 124107 (2022)]

## Prerequisites
It is assumed that the participant is familiar with DP after the hands-on sessions on the first day of this workshop. This tutorial focus on explaining the difference between DP and DPLR. 

## Exercise1： Training
Now, let's start training a DPLR model. First, go to the training folder
~~~bash
cd workshop-july-2022/5-deep-potential-long-range/1-train
~~~
`ls` you will see the files in this folder.`dipole.pb` is the DeepWannier model which is used for predicting the Wannier Centroid. `input.json` is the input training file.  

`cat input.json` to read this file. You will find that the training of the DPLR model is very similar to the training of a standard short-range DP models. Compared to DP, DPLR has an additional block "modifier" as shown below.

~~~json
"modifier": {
    "type":             "dipole_charge",
    "model_name":       "dipole.pb",
    "model_charge_map": [-8],
    "sys_charge_map":   [6, 1],
    "ewald_h":          1.0,
    "ewald_beta":       0.40
},
~~~
`model_name` specifies which DeepWannier model is used to predict the position of Wannier Centroids. Here we use the DeepWannier model `dipole.pb`, which is obtained from our last tutorial section. 

`model_charge_map` gives the amount of charge assigned to Wannier Centroids (WCs). Our training system is water. Each water molecule has four maximally localized Wannier centers (MLWCs), so the charge of the one Wannier Centroid is `-2*4=-8`.

`sys_charge_map` provides the nuclear charge of oxygen and hydrogen atoms, which are 6 and 1, respectively.

`ewald_beta` (unit Å$^{−1}$ ) gives the spread parameter that controls the spread of Gaussian charges, and `ewald_h` (unit Å) assigns the grid size of Fourier transform.

Then, we start training by submitting the job
~~~bash
conda activate deepmd
dp train input.json
~~~
The training takes about 20 hours using one GPU. In this tutorial, we don't have time to wait for the results. So, after some steps of training, you can use `Ctrl+c` to kill the job. Then you can freeze the model using `dp freeze -o model.pb` But this model haven't been converged, it's just an example. We will provide you with converged model in the following exercises.

## Exercise2： Comparing DP with DPLR
This example is aimed to illustrate the improvement of DPLR with respect to DP. We will predict the potential energy of the water dimer as a function of the separation distance between the two water molecules using DPLR, and compare it with the results predicted by DP and DFT, which reproduce Fig.5 of [J. Chem. Phys. 156, 124107 (2022)] as shown below.

<img src="fig\1.png" alt="1" style="zoom: 15%;" />

First, let's go to the water-dimer folder
~~~bash
cd workshop-july-2022/5-deep-potential-long-range/2-water-dimer
~~~
`ls` you will see the two folders `data` and `predict`
The folder `data` has the water-dimer configurations with the separation distance between the two water molecules from 2.69 to 10.00 Å. It also has the DFT calculation results. 

Now, we predict the energy of water dimers using our DPLR model `model.pb` and DeepWannier model `dipole.pb`
~~~bash
cd dplr
python3 predict.py
~~~
You will get a file `dplr.data.out`. Then, `cat dplr.data.out` you will see the following data
~~~
#   dist  DPLR_e    DFT_e
    2.69 -0.195926 -0.190687
    2.84 -0.222302 -0.221751
    2.98 -0.217886 -0.220117
    3.13 -0.194677 -0.202997
    3.38 -0.145807 -0.163624
    3.64 -0.101351 -0.124708
    4.10 -0.058995 -0.074725
    4.60 -0.038695 -0.043215
    5.10 -0.028436 -0.025782
    5.60 -0.021328 -0.015929
    6.00 -0.016154 -0.011075
    7.00 -0.007137 -0.004670
    8.00 -0.003041 -0.001925
    9.00 -0.001005 -0.000635
   10.00  0.000000  0.000000
~~~
The first column is the separation distance between the two water molecules. The second column is the potential energy predicted by DPLR. The third column is the potential energy predicted by DFT, which is extracted from the `data` folder.

In the folder `workshop-july-2022/5-deep-potential-long-range/2-water-dimer/predict/dp`, the file `dp.data.out` is the results predicted by DP.

Now, let's plot these results in one picture for comparison using Jupyter Notebook. 

Execute on the **remote machine**:

~~~bash
cd workshop-july-2022/5-deep-potential-long-range/2-water-dimer/predict
nohup jupyter notebook --port=2345 &
~~~
and then run in your **local machine**:

```
ssh -N -f -L localhost:2345:localhost:2345 -p <port> <username>@<remote-machine-address>
```

At the end of the `nohup.out` file you will find a link that you can copy and then paste into your browser.

You will get a figure similar to Fig.5 of [J. Chem. Phys. 156, 124107 (2022)]. We can see the energy predicted by DPLR is closer to the DFT results compared to DP due to explicitly including long-range electrostatic energies.

## Exercise3： DPLR molecular dynamics simulation

Now, let's conduct a DPLR molecular dynamics simulation using bulk liquid water as an example. 

First, let's go to the simulation folder
~~~bash
cd workshop-july-2022/5-deep-potential-long-range/3-md
~~~
In this folder,`in.lammps` is our LAMMPS input file, `conf.lmp` is the initial configuration file, `model.pb` is our DPLR model.

Now let's have a detailed look at the initial configuration file`conf.lmp`. This initial configuration is bulk water, which has 64 water molecules. For clarity, in this README file, we use a system that only has one water molecule as an example, which is as follows.

~~~
4 atoms
3 atom types
1 bonds
1 bond types

0.00000000         10.00000000   xlo xhi
0.00000000         10.00000000   ylo yhi
0.00000000         10.00000000   zlo zhi
0.00000000          0.00000000          0.00000000  xy xz yz

Masses

1  15.99940
2   1.00794
3  15.99940

Atoms # 1--atom index, 2--molecule index, 3--atom type, 4--atom charge, 5,6,7--x,y,z coordinate

1 1 1  6   5.000    5.000    5.000  # oxygen atom
2 1 2  1   5.816    5.577    5.000  # hydrogen atom
3 1 2  1   4.184    5.577    5.000  # hydrogen atom
4 1 3 -8   5.000    5.000    5.000  # virtual atom

Bonds

1 1 1 4
~~~

One water molecule has three atoms, one oxygen atom and two hydrogen atoms. However, you can see this configuration file has four atoms. The additional atom is the virtual atom. DPLR molecular dynamics simulation approximates the long-range electrostatic interaction between ions (nuclei + core electrons) and valence electrons with that of distributions of spherical Gaussian charges located at **ionic** and **electronic** sites. The position of **electronic** site is defined in terms of the centers of the maximally localized Wannier distributions, which is predicted by the DeepWannier model in the simulation. Therefore, in the initial configuration file, for each water molecule, we need to add a virtual atom to represent the **electronic** site. The coordinate of this virtual atom should be set the same as its corresponding real atom (in this example, it is the oxygen atom). After the simulation starts, the coordinates of the virtual atom will be updated to the coordinates of the Wannier Centroids automatically by the Code. Moreover, a virtual bond is established between the oxygens and the Wannier Centroids to indicate they are associated together. 

Then, let's see the LAMMPS input file `in.lammps`

~~~bash
# groups of real and virtual atoms
group           real_atom type 1 2
group           virtual_atom type 3

# bond between real and its corresponding virtual site should be given
# to setup a map between real and virtual atoms. However, no real
# bonded interaction is applied, thus bond_sytle "zero" is used.
pair_style      deepmd ./model.pb
pair_coeff      * *
bond_style      zero
bond_coeff      *
special_bonds   lj/coul 1 1 1 angle no
~~~
Type 1 and 2 (O and H) are real_atoms, while type 3 (Wannier Centroids) are virtual_atoms. The model file model.pb stores both the DeepWannier and DPLR models, so the position of Wannier Centroids and the energy can be inferred from it. A virtual bond type is specified by bond_style zero. The special_bonds command switches off the interactions between the real atom and virtual atom.

~~~bash
# kspace_style "pppm/dplr" should be used. in addition the
# gewald(1/distance) should be set the same as that used in
# training. Currently only ik differentiation is supported.
kspace_style    pppm/dplr 1e-5
kspace_modify   gewald ${BETA} diff ik mesh ${KMESH} ${KMESH} ${KMESH}
~~~
The long-range part is calculated by the kspace support of LAMMPS. The kspace_style pppm/dplr is required. The spread parameter set by variable `BETA` should be set the same as that used in training. The `KMESH` should be set dense enough so the long-range calculation is converged.

~~~bash
# "fix dplr" set the position of the virtual atom, and spread the
# electrostatic interaction asserting on the virtual atom to the real
# atoms. "type_associate" associates the real atom type the its
# corresponding virtual atom type. "bond_type" gives the type of the
# bond between the real and virtual atoms.
fix             0 all dplr model ../train/model.pb type_associate 1 3 bond_type 1
fix_modify      0 virial yes
~~~
The `fix` command `dplr` calculates the position of Wannier Centroids by the DeepWannier model and back-propagates the long-range interaction on virtual atoms to real toms.

~~~bash
# compute the temperature of real atoms, excluding virtual atom contribution
compute         real_temp real_atom temp
compute         real_press all pressure real_temp
#velocity        all create 330 18234589
fix             1 all npt temp 330 330  0.05 iso 1.0 1.0 0.5
fix_modify      1 temp real_temp press real_press
~~~
The temperature of the system should be computed from the real atoms. The kinetic contribution in the pressure tensor is also computed from the real atoms. The thermostat is applied to only real atoms. 

Finally, we run the simulation by submitting the job using `lmp -in in.lammps`. You will get `water.dump` (trajectory file) and `log.lammps`.


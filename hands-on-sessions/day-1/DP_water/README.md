# Molecular Dynamics Simulation of Liquid Water Under Ambient Conditions

## Introduction
In this tutorial, we will introduce how to calculate the structural and dynamic properties of liquid water using DeePMD and LAMMPS. The 

## Files Prepared
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

## Commands to Run the Simulation
```
conda activate deepmd
lmp -in in.lmp
```

## Use Jupyter Notebook to Process the Data
Run jupyter notebook on the machine:
```
nohup jupyter notebook --port=2333 &
```
Connect to it on your own computer:
```
ssh -N -f -L localhost:2333:localhost:2333 -p 4981 deepmdlabadmin@lab-b85f64a2-5e4b-4761-a76d-29e88aeb151a.eastus.cloudapp.azure.com
```
Use `vi nohup.out` to open it, use `Shift + G` to go to the last line of the file, and copy the address to the jupyter notebook. Then paste it into your browser.
import dpdata
import numpy as np
from deepmd.infer import DeepPot
import matplotlib.pyplot as plt

dp = DeepPot('frozen_model.pb')

system = dpdata.LabeledSystem('../TrainingData/ice-and-liquid', fmt = 'deepmd/raw')
e, f, v = dp.eval(system['coords'], system['cells'], system['atom_types'])
energy_model = e.reshape([-1]) 
energy_dft=np.genfromtxt("../TrainingData/ice-and-liquid/energy.raw")
number_of_molecules=96
plt.scatter(energy_model/number_of_molecules,energy_dft/number_of_molecules)

system = dpdata.LabeledSystem('../TrainingData/liquid-water-1', fmt = 'deepmd/raw')
e, f, v = dp.eval(system['coords'], system['cells'], system['atom_types'])
energy_model = e.reshape([-1]) 
energy_dft=np.genfromtxt("../TrainingData/liquid-water-1/energy.raw")
number_of_molecules=64
plt.scatter(energy_model/number_of_molecules,energy_dft/number_of_molecules)

system = dpdata.LabeledSystem('../TrainingData/liquid-water-2', fmt = 'deepmd/raw')
e, f, v = dp.eval(system['coords'], system['cells'], system['atom_types'])
energy_model = e.reshape([-1]) 
energy_dft=np.genfromtxt("../TrainingData/liquid-water-2/energy.raw")
number_of_molecules=288
plt.scatter(energy_model/number_of_molecules,energy_dft/number_of_molecules)

plt.show()


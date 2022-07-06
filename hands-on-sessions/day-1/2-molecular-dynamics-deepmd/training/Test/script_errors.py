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
plt.hist((energy_model-energy_dft)/number_of_molecules)

plt.show()


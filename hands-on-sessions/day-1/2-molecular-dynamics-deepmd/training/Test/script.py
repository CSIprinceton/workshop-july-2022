import dpdata
import numpy as np
from deepmd.infer import DeepPot
dp = DeepPot('../Train/frozen_model.pb')
system = dpdata.LabeledSystem('../TrainingData/liquid-water-2', fmt = 'deepmd/raw')
e, f, v = dp.eval(system['coords'], system['cells'], system['atom_types'])
energy_model = e.reshape([-1]) 
energy_dft=np.genfromtxt("../TrainingData/liquid-water-2/energy.raw")

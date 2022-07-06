import numpy as np
import ase 
import ase.io
from matplotlib import pyplot as plt
from deepmd.infer import DeepDipole # use it to load your model
 
def get_dipole_moments(ase_atoms, dipole_model):
    dipole_all = []
    for atoms in ase_atoms:
        atypes = np.array(atoms.get_atomic_numbers()) - 1
        dipole = dipole_model.eval(atoms.get_positions(),atoms.get_cell(),atom_types=atypes)
        dipole_all.append(dipole)
    dipole_all = np.concatenate(dipole_all, 0)
    return dipole_all

## Load Deep Dipole model
dipole_model = DeepDipole('./dipole_model/frozen_model.pb')
## Load MD trajectories
liq_configs = ase.io.read( './liquid_dipole/water.lammpstrj',format = 'lammps-dump-text',index=':')
print('loaded {} liquid configurations'.format(len(liq_configs) ))

## Evaluate dipole moments
liq_dipole_moments_vec = get_dipole_moments(liq_configs, dipole_model)
## Convert wannier centroid displacement to electric dipole : Angstrom -> Debye
liq_dipole_moments_vec *= 8 / 0.20819 
liq_dipole_moments = np.linalg.norm(liq_dipole_moments_vec, axis=-1).flatten() 

#### Plot Histogram
fig,ax = plt.subplots( figsize = (4, 3))
ax.hist(liq_dipole_moments, bins=50, alpha = 0.5, label=r'$\mu(liq)={:.2f}D$'.format(liq_dipole_moments.mean()))
ax.set_xlabel(r'$\mu [Debye]$')
ax.set_ylabel('Histogram')
ax.legend()
fig.tight_layout()
plt.savefig('dipole_moment.png')

import ase
import ase.io


atoms = ase.io.read('water.wout',format='wout')
ase.io.write('all.lammps', atoms, format='espresso-in')
print(atoms)
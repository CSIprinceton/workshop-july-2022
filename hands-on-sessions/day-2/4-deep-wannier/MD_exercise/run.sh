#conda activate deepmd
ln -s ../train_energy_model/frozen_model.pb frozen_model.pb

lmp -v TEMP 330 -v PRES 1.0 -in in.lammps > thermo.log

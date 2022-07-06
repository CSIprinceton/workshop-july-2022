#Convert raw files to poscar format
#A supercell of an appropriate size is made

import numpy as np
from os import system

pos=np.genfromtxt('coord.raw')
box=np.genfromtxt('box.raw')
typ=np.genfromtxt('type.raw',dtype='int')

nframes=pos.shape[0]
natoms=np.size(typ)
ntype=np.unique(typ).size
my_dict = {0: 'H', 1: 'C'}
indat = np.array( [my_dict[i] for i in typ] )

pos=pos.reshape(nframes,natoms,3)
box=box.reshape(nframes,3,3)

for frame in range(nframes):

  system("mkdir ./{:05d} 2> /dev/null".format(frame+1))

  with open("./{:05d}/01.in".format(frame+1), "w") as lmp:
    lmp.write('&control\n')
    lmp.write('  calculation=\'scf\'\n')
    lmp.write('  prefix=\'water\'\n')
    lmp.write('  pseudo_dir=\'../pseudo\'\n')
    lmp.write('  outdir=\'./out\'\n')
    lmp.write('  restart_mode=\'from_scratch\'\n')
    lmp.write('  nstep=20000\n')
    lmp.write('  disk_io=\'none\'\n')
    lmp.write('  max_seconds=10000\n')
    lmp.write('  tprnfor=.true.\n')
    lmp.write('  tstress=.true.\n')
    lmp.write('/\n')
    lmp.write('&system\n')
    lmp.write('  ibrav=1\n')
    lmp.write('  a=10\n')
    lmp.write('  nat={}\n'.format(natoms))
    lmp.write('  ntyp={},\n'.format(ntype))
    lmp.write('  ecutwfc=110\n')
    lmp.write('  input_dft=\'PBE\'\n')
    lmp.write('/\n')
    lmp.write('&electrons\n')
    lmp.write('  electron_maxstep = 1000\n')
    lmp.write('  mixing_beta = 0.5\n')
    lmp.write('/\n')
    lmp.write('&ions\n')
    lmp.write('/\n')
    lmp.write('&cell\n')
    lmp.write('/\n')
    lmp.write('ATOMIC_SPECIES\n')
    if any(typ==0):
      lmp.write('H   1.0  H.tm.pbe.UPF \n')
    if any(typ==1):
      lmp.write('C   1.0  C.tm.pbe.UPF \n')
    #lmp.write('CELL_PARAMETERS {angstrom}\n')
    #lmp.write('{} {} {} \n'.format(box[frame,0,0],box[frame,0,1],box[frame,0,2]))
    #lmp.write('{} {} {} \n'.format(box[frame,1,0],box[frame,1,1],box[frame,1,2]))
    #lmp.write('{} {} {} \n'.format(box[frame,2,0],box[frame,2,1],box[frame,2,2]))
    lmp.write('ATOMIC_POSITIONS {angstrom}\n')
    for iat in range(natoms):
      lmp.write('{} {} {} {}\n'.format(indat[iat],pos[frame][iat][0],pos[frame][iat][1], pos[frame][iat][2]))

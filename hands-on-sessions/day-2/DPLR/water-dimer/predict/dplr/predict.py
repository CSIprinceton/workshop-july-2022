#!/usr/bin/env python3

import os,deepmd,glob,dpdata
import numpy as np

from deepmd.infer import DeepPot

dp = DeepPot('model.pb')

data_subdir = ['data']
sel_idx = slice(0,1)


for ii in data_subdir:
    data_dir = os.path.join('../../', ii)
    dist = glob.glob(os.path.join(data_dir, 'dist.*'))
    dist.sort()
    all_res = []
    for jj in dist:
        basename = os.path.basename(jj)
        dist_v = float(basename.split('.')[1] + '.' + basename.split('.')[2])
        system = dpdata.LabeledSystem(os.path.join(jj, '00', 'OUTCAR'))
        if system.get_nframes() == 0:
            print(f'# failed system {jj}')
            continue
        sub_sys = system[sel_idx]
        e, f, v = dp.eval(sub_sys['coords'], sub_sys['cells'], sub_sys['atom_types'])
        e = e.reshape([-1])
        ref_e = sub_sys['energies'].reshape([-1])
        all_res.append([dist_v, e, ref_e])

    all_res = np.array(all_res)
    nframes = all_res.shape[0]
    with open(f'dplr.{ii}.out', 'w') as fp:
        fp.write(f'# dist  DPLR_e  DFT_e\n')
        for ii in range(nframes):
            fp.write('%8.2f %9.6f %9.6f \n' %
                     (all_res[ii][0], all_res[ii][1]-all_res[-1][1], all_res[ii][2]-all_res[-1][2] 
                  )
            )

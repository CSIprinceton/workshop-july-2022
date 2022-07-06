cp ../Si_ONCV_PBE-1.0.upf .

cp ../si.in .
sed -i "s/0.25 0.25 0.25/0.23 0.26 0.24/g" si.in
mpirun -np 4 ~/QE/q-e-qe-6.4.1/bin/pw.x < si.in > si.log


cp ../Si_ONCV_PBE-1.0.upf .

for i in 1 2 3 4 ;
  do
  mpirun -np $i ~/QE/q-e-qe-6.4.1/bin/pw.x < si.in > si${i}.log
  done

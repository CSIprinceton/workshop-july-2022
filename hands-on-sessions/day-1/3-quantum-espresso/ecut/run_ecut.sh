cp ../Si_ONCV_PBE-1.0.upf .

for i in 12 18 24 30 36 ;
  do
  cp ../si.in ./si${i}.in
  sed -i "s/ecutwfc=24.0/ecutwfc=${i}.0/g" si${i}.in
  mpirun -np 4 ~/QE/q-e-qe-6.4.1/bin/pw.x < si${i}.in > si${i}.log
  done


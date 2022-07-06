cp ../Si_ONCV_PBE-1.0.upf .

for i in 1 2 3 4 5 6 ;
  do
  cp ../si.in ./si${i}${i}${i}.in
  sed -i "s/4 4 4 1 1 1/$i $i $i 1 1 1/g" si${i}${i}${i}.in
  mpirun -np 4 ~/QE/q-e-qe-6.4.1/bin/pw.x < si${i}${i}${i}.in > si${i}${i}${i}.log
  done


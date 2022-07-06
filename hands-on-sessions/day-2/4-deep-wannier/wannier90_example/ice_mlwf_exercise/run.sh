 
PW=~/QE/q-e-qe-6.4.1/bin/pw.x
W90=~/wannier90/wannier90-3.1.0/wannier90.x
PWW90=~/QE/q-e-qe-6.4.1/bin/pw2wannier90.x
kmesh=~/wannier90/wannier90-3.1.0/utility/kmesh.pl

## run a SCF DFT calculation
mpirun $PW -input scf.in > scf.out  

## run a non-SCF DFT calculation for getting complete information on orbitals
mpirun $PW -input nscf.in > nscf.out
 
# generate .nnkp as the input of the postprocessing code pw2wannier90
$W90 -pp water

# produce the matrices needed for maximally localized wannierization .mmn, .amn, .eig…
mpirun $PWW90 < water.pw2wan > pw2wan.out

#minimize the spread, calculate wannier function
mpirun $W90 water
 
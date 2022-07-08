pconv="1"
econv="13.6056980659"
fconv="25.71095"
autoangs="0.529177"

function print_cell () {

  cell=`awk -v"autoangs=$autoangs" '
        /celldm\(1\)=/ {alat=$2*autoangs} 
        /a\(1\) =/ {a11=$4; a12=$5; a13=$6}
        /a\(2\) =/ {a21=$4; a22=$5; a23=$6}
        /a\(3\) =/ {a31=$4; a32=$5; a33=$6}
        END {printf "%12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f\n", 
                 a11*alat,a12*alat,a13*alat, 
                 a21*alat,a22*alat,a23*alat, 
                 a31*alat,a32*alat,a33*alat}' $1`

  echo $cell

}

rm *.raw 2> /dev/null

ntotal=200
natoms=5

for i in `seq -f "%05g" $ntotal`
do
  if grep -q ! ../$i/01.out
  then

    tail -n $natoms ../$i/01.in | awk -v"a=$pconv" '{printf "%12.8f %12.8f %12.8f ", $2*a, $3*a, $4*a }' >> coord.raw
    grep -A $((natoms+1)) 'Forces acting' ../$i/01.out | tail -n $natoms | awk -v"a=$fconv" '/atom/ && /force =/ {printf "%12.8f %12.8f %12.8f ", $7*a, $8*a, $9*a }' >> force.raw
    grep ! ../$i/01.out | awk -v"a=$econv" 'END{printf "%15.8f\n", $5*a}' >> energy.raw
    print_cell ../$i/01.out >> box.raw

    echo "" >> force.raw
    echo "" >> coord.raw
  
  fi
done



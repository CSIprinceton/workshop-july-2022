set xrange [2:10]
set yrange [-0.25:0.05] 
set xlabel 'd (angstrom)'
set ylabel 'E (eV)'
plot "dplr/dplr.data.out" u 1:3 w l lw 2 lc rgb "black" tit "DFT","dp/dp.data.out" u 1:2 w l lw 2 lc rgb "red" tit "DP", "dplr/dplr.data.out" u 1:2 w l lw 2 lc rgb "blue" tit "DPLR"

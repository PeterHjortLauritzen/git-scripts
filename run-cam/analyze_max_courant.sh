#!/bin/tcsh
if ( "$#argv" != 1) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 file with data"
  exit
endif
set n = 1
set file = "$argv[$n]" 

if (! -e $file) then
  echo "log file $file does not exist. Abort"
  exit
endif
if (! -e plot.gp) then
  rm plot.gp
endif
echo "set grid" > plot.gp
echo "plot\" >> plot.gp


set j = 10
set max = 20
while ( $j <= $max )
  if ( -e tmp.dat) then
    rm tmp.dat
  endif

  echo $j
  if ( $j < 10) then
    set string = "k,gamma=            $j"
  else
    set string = "k,gamma=           $j"
  endif
  echo "grepping for $string"
  grep "$string" $file  > tmp.dat
  echo $string
  sed -i 's/k,gamma=           //g' tmp.dat
  mv tmp.dat gamma_max.$j.dat
  if ( $j < $max) then
    echo " "'"'gamma_max.$j.dat'"'" u 2 w l, \" >> plot.gp
  else
    echo " "'"'gamma_max.$j.dat'"'" u 2 w l" >> plot.gp
  endif
#sed -n 's/k,gamma= 1/ /g' tmp.dat
   #  sed   gamma_max.$j.dat
  echo $j
#plot "gamma_max.1.dat" u 2 w l
  unset string
  @ j+=1
end
unset cases
unset j

`gnuplot -persist plot.gp`

#!/bin/tcsh
if ( "$#argv" != 2) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 logfile file with data"
  echo "  -arg 2 number of levels to analyze"
  exit
endif
set n = 1
set file = "$argv[$n]" 
set n = 2
set numlev = "$argv[$n]" 

if (`hostname` == "hobart.cgd.ucar.edu") then
  echo "You are on Hobart"
  set data_dir = "/scratch/cluster/$USER/"
  setenv ncl_dir  "/home/$USER/git-scripts/ncl_scripts"
  echo "NCL directory is"$ncl_dir
else if (`hostname` == "izumi.unified.ucar.edu") then
  echo "You are on Izumi"
  set data_dir = "/scratch/cluster/$USER/"
  setenv ncl_dir  "/home/$USER/git-scripts/ncl_scripts"
  echo "NCL directory is"$ncl_dir
else
  module load ncl
  set data_dir = "/glade/scratch/$USER/"
  setenv ncl_dir "/glade/u/home/$USER/git-scripts/ncl_scripts"
endif

echo "plot \\" > courant.gp
@ lev = 1
while ($lev <= $numlev) 
  if ($lev < 10) then
    grep "k,gamma=            $lev" $file > courant.level$lev.dat
  else if ($lev < 100) then
    grep "k,gamma=           $lev" $file > courant.level$lev.dat
  else if ($lev < 1000) then
    grep "k,gamma=          $lev" $file > courant.level$lev.dat
  endif
  if ($lev == $numlev) then  
    echo "'courant.level$lev.dat' u 3 w lp ps 0.5" >> courant.gp
  else
    echo "'courant.level$lev.dat' u 3 w lp ps 0.5, \\" >> courant.gp
  endif
  @ lev += 1  
end


#echo "plot 'courant.all.level1.dat' u 3 w lp" > courant.gp
gnuplot -persitst courant.gp
#ncl 'fname="'$file'"' 'vname1="'$vname1'"' 'vname2="'$vname2'"' 'nstep_start="'$nstep_start'"' 'nstep_stop="'$nstep_stop'"' 'latlon="'$latlon'"' 'resolution="'$resolution'"' $ncl_dir/mixing.ncl



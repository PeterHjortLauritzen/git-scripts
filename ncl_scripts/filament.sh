#!/bin/tcsh
if ( "$#argv" != 4) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 file with data"
  echo "  -arg 2 variable name (e.g., PRECT, PS)"
  echo "  -arg 3 nstep"
  echo "  -arg 4 FV,SE,F3"    
  exit
endif
set n = 1
set file = "$argv[$n]" 
set n = 2
set vname = "$argv[$n]"
set n = 3
set nstep = "$argv[$n]"
set n = 4
set dcore = "$argv[$n]" 

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
#
# NCL script to compute lf - data output to ASCII file
#
ncl 'fname="'$file'"' 'vname="'$vname'"' 'nstep='$nstep 'dcore="'$dcore'"' $ncl_dir/filament.ncl
if (-e filament.gp) then
  rm filament.gp
endif
#
# Make Gnuplot script
#
echo "set terminal postscript eps enhanced color "'"Helvetica"'" 26" >> filament.gp
echo "set out "'"filament.eps"'""                                    >> filament.gp
echo "set title "'"Filament diagnostic"'" "                          >> filament.gp
echo "set xlabel "'"{/Symbol t}"'""                                  >> filament.gp
echo "set ylabel "'"l_f"'""                                          >> filament.gp
echo "set grid"                                                      >> filament.gp
echo "set xtics ("'"0.0"'" 0.0,"'" "'"0.1,"'"0.2"'" 0.2,"'" "'" 0.3,"'"0.4"'" 0.4,"'" "'" 0.5,"'"0.6"'" 0.6,"'" "'" 0.7,"'"0.8"'" 0.8,"'" "'" 0.9,"'"1.0"'" 1.0)" >> filament.gp 
#echo "set key 0.64,52.13 spacing 1.1 width -2.0 height 1 box " >> filament.gp
echo "plot "'"filament-ref.dat"'" w l lt -1 lw 3 notitle,"'"filament.dat"'" w lp lt 1 lw 2 title "'"1.5{/Symbol \260}"'" " >> filament.gp
if (-e filament-ref.dat) then
  rm filament-ref.dat
endif
echo "0.1 100.0" >> filament-ref.dat
echo "1.0 100.0" >> filament-ref.dat
gnuplot filament.gp
if (-e filament.eps) then
  echo "Script has created filement.eps file"
else
  echo "Something went wront: filament.eps was not created" 
endif
#gv filament.eps

#!/bin/tcsh
if ( "$#argv" != 7) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 file with data"
  echo "  -arg 2 variable name 1"
  echo "  -arg 3 variable name 2"
  echo "  -arg 4 time step index start"
  echo "         (if < 0 animate over all time-steps)"
  echo "  -arg 5 time step index stop"
  echo "         (if start and stop index are the same "
  echo "          then no animation will be generated)"
  echo "  -arg 6 lat-lon logical"
  echo "  -arg 7 resolution"    
  exit
endif
set n = 1
set file = "$argv[$n]" 
set n = 2
set vname1 = "$argv[$n]"
set n = 3
set vname2 = "$argv[$n]"
set n = 4
set nstep_start = "$argv[$n]"
set n = 5
set nstep_stop = "$argv[$n]"
set n = 6
set latlon = "$argv[$n]"
set n = 7
set resolution = "$argv[$n]" 

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
ncl 'fname="'$file'"' 'vname1="'$vname1'"' 'vname2="'$vname2'"' 'nstep_start="'$nstep_start'"' 'nstep_stop="'$nstep_stop'"' 'latlon="'$latlon'"' 'resolution="'$resolution'"' $ncl_dir/mixing.ncl



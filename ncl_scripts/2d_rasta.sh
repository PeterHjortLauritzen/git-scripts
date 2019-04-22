#!/bin/tcsh
if ( "$#argv" != 7) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 file with data"
  echo "  -arg 2 variable name"
  echo "  -arg 3 time step index"
  echo "  -arg 4 lat-lon logical"
  echo "  -arg 5 resolution"
  echo "  -arg 6 3D data or not"
  echo "  -arg 6 level"        
  exit
endif
set n = 1
set file = "$argv[$n]" 
set n = 2
set vname = "$argv[$n]"
set n = 3
set ntime = "$argv[$n]"
set n = 4
set latlon = "$argv[$n]"
set n = 5
set resolution = "$argv[$n]"
set n = 6
set threeD = "$argv[$n]"
set n = 7
set ilev = "$argv[$n]" 

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
ncl 'fname="'$file'"' 'vname="'$vname'"' 'ntime="'$ntime'"'  'latlon="'$latlon'"' 'resolution="'$resolution'"' 'threeD="'$threeD'"' 'ilev="'$ilev'"' $ncl_dir/2d_rasta.ncl



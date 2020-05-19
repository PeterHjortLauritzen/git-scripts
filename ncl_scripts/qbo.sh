#!/bin/tcsh
if ( "$#argv" != 2) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 file with data"
  echo "  -arg 2 variable name (e.g., PRECT, PS)"
  exit
endif
set n = 1
set file = "$argv[$n]" 
set n = 2
set vname = "$argv[$n]" 

if (`hostname` == "hobart.cgd.ucar.edu") then
  set data_dir = "/scratch/cluster/$USER/"
  set ncl_dir = "/home/$USER/git-scripts/ncl_scripts"
  echo "You are on Hobart"
  echo "NCL directory is"$ncl_dir
else
  set data_dir = "/glade/scratch/$USER/"
  setenv ncl_dir "/glade/u/home/$USER/git-scripts/ncl_scripts"
endif

ncl 'fname="'$file'"' 'vname="'$vname'"'  $ncl_dir/qbo.ncl

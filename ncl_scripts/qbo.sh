#!/bin/tcsh
if ( "$#argv" != 4) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 file with data"
  echo "  -arg 2 variable name (e.g., PRECT, PS)"
  echo "  -arg 3 leftString"
  echo "  -arg 4 rightString"
  exit
endif
set n = 1
set file = "$argv[$n]" 
set n = 2
set vname = "$argv[$n]" 

set n = 3
set leftstring = "$argv[$n]" 
set n = 4
set rightstring = "$argv[$n]" 

if (`hostname` == "hobart.cgd.ucar.edu") then
  set data_dir = "/scratch/cluster/$USER/"
  set ncl_dir = "/home/$USER/git-scripts/ncl_scripts"
  echo "You are on Hobart"
  echo "NCL directory is"$ncl_dir
else
  set data_dir = "/glade/scratch/$USER/"
  setenv ncl_dir "/glade/u/home/$USER/git-scripts/ncl_scripts"
endif

ncl 'fname="'$file'"' 'vname="'$vname'"' 'leftstring="'$leftstring'"' 'rightstring="'$rightstring'"'  $ncl_dir/qbo.ncl

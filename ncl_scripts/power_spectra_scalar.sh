#!/bin/tcsh
if ( "$#argv" != 2) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 file name"
  echo "  -arg 1 variable name"
  exit
endif
set n = 1
set file = "$argv[$n]"
set n = 2
set vname = "$argv[$n]"
if (`hostname` == "hobart.cgd.ucar.edu") then
  setenv my_ncl_dir  "/home/$USER/git-scripts/ncl_scripts"
else
  setenv my_ncl_dir  "/glade/u/home/$USER/git-scripts/ncl_scripts"
endif
#
# DO NOT EDIT BELOW
#
ncl 'fname="'$file'"' 'vname="'$vname'"'  $my_ncl_dir/power_spectra_scalar.ncl

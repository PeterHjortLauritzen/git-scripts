#!/bin/tcsh
#
# This is a driver script for tke.ncl
#
echo "$NCAR_HOST"
if ("$NCAR_HOST" == "cheyenne") then
  echo "Known computer"
  set ncl_dir = "/glade/u/home/pel/git-scripts/ncl_scripts/tke"
  set scratch_dir = "/glade/scratch/pel/"
endif

if ( "$#argv" == 1) then
  set n = 1
  set case = "$argv[$n]" 
  echo "Plotting on one TKE from run directory"
  ncl 'dir="'$scratch_dir/$case'/run"' 'case="'$case'"' $ncl_dir/plot-tke.ncl
endif
if ("$#argv" == 0) then
  echo "Plotting all files in in 'ls *.tke_250hPa.nc' in the current directory"
  ncl 'dir="'$scratch_dir/$case'/run"' 'case="'$case'"' $ncl_dir/plot-tke.ncl
endif
if ("$#argv" > 1) then
  echo "wrong number of arguments specified:"
  echo " "
  echo "If 1 argument specify run case and the TKE spectrum for that run,"
  echo "following the CESM file structure, will be plotted"
  echo " "
  echo "If no arguments then all files in 'ls *.tke_250hPa.nc' in the current directory"
  echo "will be plotted"
  exit
endif

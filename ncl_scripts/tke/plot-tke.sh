#!/bin/tcsh
#
# This is a driver script for tke.ncl
#
if (`hostname` == "hobart.cgd.ucar.edu") then
  set scratch_dir = "/scratch/cluster/$USER"
  set ncl_dir  = "/home/$USER/git-scripts/ncl_scripts/tke"
else
  set scratch_dir = "/glade/scratch/$USER"
  set ncl_dir = "/glade/u/home/$USER/git-scripts/ncl_scripts/tke"
endif

#if ( "$#argv" == 1) then
#  set n = 1
#  set case = "$argv[$n]" 
#  echo "Plotting on one TKE from run directory"
#  ncl 'dir="'$scratch_dir/$case'/run"' 'case="'$case'"' 'ls_option=False' $ncl_dir/plot-tke.ncl
#endif
#if ("$#argv" == 0) then
  echo "Plotting all files in in 'ls *.tke_200hPa.nc' in the current directory"
  ncl 'dir="'$PWD'"' 'ls_option=True' $ncl_dir/plot-tke.ncl
#endif
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

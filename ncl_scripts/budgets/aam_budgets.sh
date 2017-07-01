#!/bin/tcsh
if ( "$#argv" != 1) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 file with axial angular momentum diagnostics (averaged)"
  exit
endif
set n = 1
set file = "$argv[$n]" 
if (`hostname` == "hobart.cgd.ucar.edu") then
  set data_dir = "/scratch/cluster/pel/"
  set ncl_dir = "/home/pel/git-scripts/ncl_scripts/budgets"
else
  set data_dir = "/glade/scratch/pel/"
  set ncl_dir = "/glade/u/home/pel/git-scripts/ncl_scripts/budgets"
endif
echo $file
ncl 'dir="'$PWD'"' 'fname="'$file'"' $ncl_dir/aam_budgets.ncl

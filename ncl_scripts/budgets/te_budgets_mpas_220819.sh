#!/bin/tcsh
if ( "$#argv" != 1) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 file with energy diagnostics (averaged)"
  exit
endif
set n = 1
set file = "$argv[$n]" 

set ncl_dir = "/glade/u/home/pel/git-scripts/ncl_scripts/budgets/"

echo $file

if (! -e nuopc.runconfig) then
  echo "This script expects nuopc.runconfig to get physics time-step"
  exit
endif
grep "atm_cpl_dt[[:space:]]" nuopc.runconfig >> tmp_file
set dtime = `grep -o "[0-9][0-9][0-9][0-9]" tmp_file || echo "none"`
echo "dtime ="$dtime
rm tmp_file

ncl 'dir="'$PWD'"' 'fname="'$file'"' 'dtime='$dtime'' $ncl_dir/te_budgets_mpas_220819.ncl  


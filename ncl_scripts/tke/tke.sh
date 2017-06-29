#!/bin/tcsh
#
# This is a driver script for tke.ncl
#
if ( "$#argv" != 2) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 is run case"
  echo "  -arg 2 is history file number (e.g., h0)"
  exit
endif
echo "$NCAR_HOST"
if ("$NCAR_HOST" == "cheyenne") then
  echo "Known computer"
  set ncl_dir = "/glade/u/home/pel/git-scripts/ncl_scripts/tke/"
endif

set n = 1
set case = "$argv[$n]" 
set n = 2
set h_number = "$argv[$n]" 
ncl 'dir="'$PWD'"' 'case="'$case'"' 'h_number="'$h_number'"' $ncl_dir/tke.ncl

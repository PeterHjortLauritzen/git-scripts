#!/bin/tcsh
#
# This is a driver script for tke.ncl
#
echo "$NCAR_HOST"
if ("$NCAR_HOST" == "cheyenne") then
  echo "Known computer"
  set ncl_dir = "/glade/u/home/pel/git-scripts/ncl_scripts/tke/"
endif
ncl 'dir="/glade2/scratch2/pel/QPC4_with-user-topo_ne30_ne30_pe1152_6nmonths_Co92/run"' 'case="QPC4_with-user-topo_ne30_ne30_pe1152_6nmonths_Co92"' $ncl_dir/tke.ncl

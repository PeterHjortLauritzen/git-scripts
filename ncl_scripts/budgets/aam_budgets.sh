#!/bin/tcsh
if ( "$#argv" != 3) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 file with axial angular momentum diagnostics (averaged)"
  echo "  -arg 2 i for instantaneous and a for a file containing average"
  echo "  -arg 3 SE,FV,FV3"  
  exit
endif
set n = 1
set file = "$argv[$n]" 
set n = 2
set tempo = "$argv[$n]"
set n = 3
set dycore = "$argv[$n]"
echo "Dycore="$dycore


set data_dir = "/glade/scratch/pel/"
set ncl_dir = "/glade/u/home/pel/git-scripts/ncl_scripts/budgets"
if (`hostname` == "hobart.cgd.ucar.edu") then
  set data_dir = "/scratch/cluster/pel/"
  set ncl_dir = "/home/pel/git-scripts/ncl_scripts/budgets"
endif
if (`hostname` == "izumi.unified.ucar.edu") then
  set data_dir = "/scratch/cluster/pel/"
  set ncl_dir = "/home/pel/git-scripts/ncl_scripts/budgets"
endif
echo $file
if (! -e atm_in) then
  echo "This script expect the atm_in file for get rsplit, nsplit, .... values"
  exit
else
  echo "Found atm_in file"
endif
if (! -e drv_in) then
  echo "This script expect the drv_in file to get physics time-step"
  exit
else
  echo "Found drv_in file"
endif
if (-e tmp_file) then
  rm tmp_file
endif

grep "atm_cpl_dt[[:space:]]"            drv_in >> tmp_file
set dtime = `sed -r 's/([^0-9]*([0-9]*)){1}.*/\2/' tmp_file`
rm tmp_file
#set dtime = `grep -o "[0-9][0-9][0-9][0-9][0-9]" tmp_file || echo "none"`
echo "dtime ="$dtime

set supportedDycore="False"
if ($argv[$n] == "SE") then
  set supportedDycore=True
  touch tmp_file
  grep "se_nsplit[[:space:]]"            atm_in >> tmp_file      #find line and parse to tmp_file
  set nsplit = `sed -r 's/([^0-9]*([0-9]*)){1}.*/\2/' tmp_file`  #extract number (don't use grep -o "[0-9}"
                                                               #since it assumes 1 digit length
  rm tmp_file  
  #set nsplit = `grep -o "[0-9]" tmp_file`
  touch tmp_file
  grep "se_hypervis_subcycle_sponge[[:space:]]" atm_in >> tmp_file
  set hyper_sponge  = `grep -o "[0-9]" tmp_file`
  rm tmp_file
  touch tmp_file
  grep "se_rsplit[[:space:]]"            atm_in >> tmp_file
  set rsplit = `sed -r 's/([^0-9]*([0-9]*)){1}.*/\2/' tmp_file`
  rm tmp_file
  touch tmp_file
  grep "se_hypervis_subcycle[[:space:]]" atm_in >> tmp_file
  set hyper  = `grep -o "[0-9]" tmp_file`
  rm tmp_file
  touch tmp_file
  grep "se_ftype[[:space:]]"            atm_in >> tmp_file
  set ftype = `sed -r 's/([^0-9]*([0-9]*)){1}.*/\2/' tmp_file`
  rm tmp_file
  touch tmp_file
  grep "se_qsize_condensate_loading[[:space:]]"            atm_in >> tmp_file
  set  qsize_condensate_loading = `sed -r 's/([^0-9]*([0-9]*)){1}.*/\2/' tmp_file`
  rm tmp_file
  echo "rsplit="$rsplit
  echo "nsplit="$nsplit
  echo "hypervis_subcycle="$hyper
  echo "dtime ="$dtime
endif

if ($argv[$n] == "FV3") then
  set supportedDycore=True
  set rsplit=0
  touch tmp_file
  grep "k_split[[:space:]]"            atm_in >> tmp_file      #find line and parse to tmp_file
  set nsplit = `sed -r 's/([^0-9]*([0-9]*)){1}.*/\2/' tmp_file`  #extract number (don't use grep -o "[0-9}"
  #set nsplit = `grep -o "[0-9]" tmp_file`
  rm tmp_file
  set hyper=0
  set hyper_sponge=0  
  set ftype = 1
  touch tmp_file
  grep "fv3_qsize_condensate_loading[[:space:]]"            atm_in >> tmp_file
  set  qsize_condensate_loading = `sed -r 's/([^0-9]*([0-9]*)){1}.*/\2/' tmp_file`
  rm tmp_file
  set lcp_moist = "true"
endif

if ($supportedDycore == "False") then
  echo "The dycore you specified is not supported"
  echo "Supported options are FV, SE and FV3"  
endif

ncl 'dir="'$PWD'"' 'fname="'$file'"' 'rsplit='$rsplit'' 'nsplit='$nsplit'' 'hypervis_subcycle='$hyper'' 'hypervis_subcycle_sponge='$hyper_sponge'' 'ftype='$ftype'' 'qsize_condensate_loading='$qsize_condensate_loading'' 'dtime='$dtime'' 'tempo="'$tempo'"' 'dycore="'$dycore'"' $ncl_dir/aam_budgets.ncl

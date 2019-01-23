#!/bin/tcsh
if ( "$#argv" != 2) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 file with energy diagnostics (averaged)"
  echo "  -arg 2 SE,FV,FV3"
  exit
endif
set n = 1
set file = "$argv[$n]" 

if (`hostname` == "cheyenne6") then
  set data_dir = "/glade/$USER/pel/"
  set ncl_dir = "/glade/u/home/$USER/git-scripts/ncl_scripts/budgets"
else
  set data_dir = "/scratch/cluster/$USER/"
  set ncl_dir = "/home/$USER/git-scripts/ncl_scripts/budgets"
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

set n = 2
set dycore = "$argv[$n]"
echo "Dycore="$dycore

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
  #set nsplit = `grep -o "[0-9]" tmp_file`
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
  rm tmp_file2
  touch tmp_file2
  grep "se_lcp_moist[[:space:]]"            atm_in >> tmp_file2
  sed 's/^.*= //' tmp_file2 >> tmp_file3
  set lcp_moist     = `sed -e 's/\.//g' tmp_file3`
  rm tmp_file*
  touch tmp_file
endif
if ($argv[$n] == "FV") then
  set supportedDycore=True
  set rsplit=0
  set nsplit=0
  set hyper=0
  set ftype = 1
  set qsize_condensate_loading = "1"
  set lcp_moist = "false"
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
echo "rsplit="$rsplit
echo "nsplit="$nsplit
echo "hypervis_subcycle="$hyper
echo "lcp_moist ="$lcp_moist
ncl 'dir="'$PWD'"' 'fname="'$file'"' 'rsplit='$rsplit'' 'nsplit='$nsplit'' 'hypervis_subcycle='$hyper'' 'ftype='$ftype'' 'qsize_condensate_loading='$qsize_condensate_loading'' 'dtime='$dtime'' 'lcp_moist="'$lcp_moist'"' 'dycore="'$dycore'"' $ncl_dir/te_budgets.ncl  


#!/bin/tcsh
#
#
#
if ( "$#argv" == 0) then
  echo "Script usage: source create_commonly_used_scripts.sh CASE DEBUG"
  echo " "
  echo "CASE (numeric value) options are:"
  echo "---------------------------------"
  echo " "
  echo "1. Standard APE CAM4 run (3.5 years simulation; first half year is considered spinup) on Hobart"
  echo " "
  echo "DEBUG (optional argument): If debug then the model just runs 5 time-steps otherwise no debugging."
  echo "-------------------------------------------------------------------------------------------------"
  echo " "
  echo "Aborting"
  exit
endif

set n = 1
set case = "$argv[$n]"
#
# set variables that are independent of case
#
if ( "$#argv" > 1) then
  echo "debug turned on"
  set n = 2
  set debug       = "debug"
  set stop_option = "nsteps"
  set stop_n      = "5"
  set pe_count    = "144"
  set walltime    = "00:10:00"
else
  echo "debug turned off"
  set debug       = "nodebug"
endif
if (`hostname` == "hobart.cgd.ucar.edu") then
  set machine = "hobart"
  echo "You are on Hobart"
  if ($debug == "debug") then
    set queue       = "verylong"
  else
    set queue       = "monster"
  endif
endif
if ($case == "1") then
  echo "Producing run script for standard APE CAM4 run (3.5 years simulation; first half year is considered spinup) on Hobart"
  if ($debug != "debug") then
    set stop_option = "nmonths"
    set stop_n      = "42"
    set walltime    = "72:00:00"
    set pe_count     = "672"
  endif

#
  source create_CESM_run_script.sh ne30_ne30 QPC4 $machine $pe_count $stop_option $stop_n $walltime default standard_APE $queue $debug
endif

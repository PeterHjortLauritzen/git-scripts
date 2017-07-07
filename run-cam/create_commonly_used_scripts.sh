#!/bin/tcsh
#
#
#
if ( "$#argv" <5) then
  echo " "
  echo "Script usage: source create_commonly_used_scripts.sh case res debug energy_diags old_visco"
  echo " "
  echo "Supported resolutions: ne30_ne30, ne30pg3_ne30pg3_mg17"
  echo " "
  echo "CASE (numeric value) options are:"
  echo "---------------------------------"
  echo " "
  echo "1. Standard APE CAM4 run (3.5 years simulation; first half year is considered spinup) "
  echo "2. Standard APE CAM5 run (3.5 years simulation; first half year is considered spinup) "
  echo "3. Standard APE CAM6 run (3.5 years simulation; first half year is considered spinup) "
  echo " "
  echo " "
  echo "10. Standard Held-Suarez run (1200 days) "
  echo " "
  echo " "
  echo "20. Ullirch et al. baroclinic wave with Kessler micro-physics and terminator chemistry"

  echo "DEBUG (optional argument): If debug then the model just runs 5 time-steps otherwise no debugging."
  echo "-------------------------------------------------------------------------------------------------"
  echo " "
  echo "Aborting"
  exit
endif
echo "Number of arguments "$#argv
#
##############################################################
#
# Aqua-planet configurations
#
##############################################################
#
set n = 1
set case = "$argv[$n]"
echo "case is "$case
set n = 2
set res = "$argv[$n]"
set n = 3
set debug = "$argv[$n]"
if ($debug == "debug") then
  echo "debug turned on"
  set debug       = "debug"
  set stop_option = "nsteps"
  set stop_n      = "5"
else
  echo "debug turned off"
  set debug       = "nodebug"
endif
set n = 4
set energy_diags = "$argv[$n]"
if ($debug == "energy_diags") then
  echo "energy diagnostics turned on"
else
  echo "energy diagnostics turned off"
endif
set n = 5
set old_visco = "$argv[$n]"
if ($old_visco == "old_visco") then
  echo "old viscosity settings"
else
  echo "new viscosity settings"
endif

if (`hostname` == "hobart.cgd.ucar.edu") then
  set machine = "hobart"
  echo "You are on Hobart"
  if ($debug == "debug") then
    set queue       = "verylong"
    set pe_count    = "144"
    set walltime    = "00:10:00"
  else
    set queue       = "monster"
  endif
else
  set machine = "cheyenne"
  set queue       = "economy"
  if ($debug == "debug") then
    set pe_count    = "256"
    set walltime    = "10:00"
  endif
endif
if ($case == "1") then
  echo "Producing run script for standard APE CAM4 run (3.5 years simulation; first half year is considered spinup) "
  if ($debug != "debug") then
    set stop_option = "nmonths"
    set stop_n      = "42"
    if ($machine == "hobart") then
      set walltime    = "72:00:00"
      set pe_count     = "672"
    else
      set walltime    = "01:00"
      set pe_count     = "1152"
    endif
  endif

#
  source create_CESM_run_script.sh $res QPC4 $machine $pe_count $stop_option $stop_n $walltime default ftype1 $queue $debug $energy_diags $old_visco
endif

if ($case == "2") then
  echo "Producing run script for standard APE CAM5 run (3.5 years simulation; first half year is considered spinup) "
  if ($debug != "debug") then
    set stop_option = "nmonths"
    set stop_n      = "42"
    set walltime    = "72:00:00"
    set pe_count     = "672"
  endif

#
  source create_CESM_run_script.sh $res QPC5 $machine $pe_count $stop_option $stop_n $walltime default standard_APE $queue $debug $energy_diags $old_visco
endif

if ($case == "3") then
  echo "Producing run script for standard APE CAM6 run (3.5 years simulation; first half year is considered spinup) "
  if ($debug != "debug") then
    set stop_option = "nmonths"
    set stop_n      = "42"
    set walltime    = "72:00:00"
    set pe_count     = "672"
  endif

#
  source create_CESM_run_script.sh $res QPC6 $machine $pe_count $stop_option $stop_n $walltime default standard_APE $queue $debug $energy_diags $old_visco
endif
#
##############################################################
#
# Held-Suarez 
#
##############################################################
#
if ($case == "10") then
  echo "Standard Held-Suarez run (1200 days) "
  if ($debug != "debug") then
    set stop_option = "ndays"
    set stop_n      = "1200"
    set walltime    = "72:00:00"
    set pe_count     = "672"
  endif

#
  source create_CESM_run_script.sh $res FHS94 $machine $pe_count $stop_option $stop_n $walltime default vanilla_HS $queue $debug $energy_diags $old_visco
endif

if ($case == "11") then
  echo "Held-Suarez run (1200 days) with topo"
  if ($debug != "debug") then
    set stop_option = "ndays"
    set stop_n      = "1200"
    set walltime    = "72:00:00"
    set pe_count     = "672"
  endif

#
  source create_CESM_run_script.sh $res FHS94 $machine $pe_count $stop_option $stop_n $walltime /home/pel/release/topo/ne30np4_nc3000_Co092_Fi001_MulG_PF_nullRR_Nsw064_20170510.nc HS_with_Co92topo $queue $debug $energy_diags $old_visco
endif


#
###################################################################################
#
# ULLRICH ET AL. BAROCLINIC WAVE WITH KESSLER MICROPHYSICS AND TERMINATOR CHEMISTRY
#
##################################################################################
#
if ($case == "20") then
  echo "ULLRICH ET AL. BAROCLINIC WAVE WITH KESSLER MICROPHYSICS AND TERMINATOR CHEMISTRY (15 days)"
  if ($debug != "debug") then
    set stop_option = "ndays"
    set stop_n      = "15"
    if ($machine == "hobart") then
      set walltime    = "00:15:00"
      set pe_count     = "672"
    else
      set walltime    = "00:15"
      set pe_count     = "1152"
    endif
  endif

#
  source create_CESM_run_script.sh $res FKESSLER $machine $pe_count $stop_option $stop_n $walltime default standard $queue $debug $energy_diags $old_visco
endif


#/home/pel/src/$src/cime/scripts/create_newcase -case /scratch/cluster/pel/$caze -compset FADIAB -res $res -mach hobart -#-compiler nag --walltime 00:10:00 --run-unsupported 
#cd /scratch/cluster/pel/$caze
#./xmlchange CAM_CONFIG_OPTS="-phys held_suarez"

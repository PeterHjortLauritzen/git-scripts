#!/bin/tcsh
setenv PBS_ACCOUNT NACM0003
#setenv PBS_ACCOUNT "P03010039"
# P03010039
# P93300042
# P03010083
# P93300075
# P05010048
# P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="trunk2"
#set src="simone"
#
# run with CSLAM or without
#
#set res="ne30pg3_ne30pg3_mg17" #cslam
set res="ne30_ne30_mg17"      #no cslam

set cset="FC2000climo"
#
# mapping files (not in cime yet)
#
set pg3map="/glade/p/cgd/amp/pel/cslam-mapping-files"
#
# location of initial condition file (not in CAM yet)
#
set inic="/glade/p/cgd/amp/pel/inic"
echo "Do CSLAM mods in clm and cime:"
source clm_and_cime_mods_for_cslam.sh $src
echo "Done"
set walltime="01:00:00"
set pecount="2700" # runs 100 days in 1h
set NTHRDS="1"
set stopoption="nmonths"
set steps="12"
set caze=${src}_${cset}_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q regular --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange NTHRDS=$NTHRDS
./xmlchange TIMER_LEVEL=10
##
if ($res == "ne30pg3_ne30pg3_mg17") then
  ./xmlchange GLC2LND_SMAPNAME=$pg3map/map_gland4km_TO_ne30pg3_aave.180510.nc
  ./xmlchange GLC2LND_FMAPNAME=$pg3map/map_gland4km_TO_ne30pg3_aave.180510.nc
  ./xmlchange LND2GLC_FMAPNAME=$pg3map/map_ne30pg3_TO_gland4km_aave.180515.nc
  ./xmlchange LND2GLC_SMAPNAME=$pg3map/map_ne30pg3_TO_gland4km_bilin.180515.nc
  ./xmlchange LND2ROF_FMAPNAME=$pg3map/map_ne30pg3_TO_0.5x0.5_nomask_aave_da_180515.nc
  ./xmlchange ROF2LND_FMAPNAME=$pg3map/map_0.5x0.5_nomask_TO_ne30pg3_aave_da_180515.nc
endif
#

./xmlquery EXEROOT
./xmlquery CASEROOT

./case.setup

if ($res == "ne30pg3_ne30pg3_mg17") then
  echo "fsurdat='/glade/p/cesmdata/cseg/inputdata/lnd/clm2/surfdata_map/surfdata_ne30pg3_78pfts_CMIP6_simyr2000_c180731.nc'">>user_nl_clm
endif
if ($res == "ne30_ne30_mg17") then
#  echo "fsurdat='/glade/p/cesmdata/cseg/inputdata/lnd/clm2/surfdata_map/surfdata_ne30np4_simyr2000_c110801.nc'">>user_nl_clm
endif
echo "interpolate_output = .true.,.true.,.true.,.true.,.true.,.true.,.true.,.true." >> user_nl_cam
qcmd -- ./case.build
./case.submit

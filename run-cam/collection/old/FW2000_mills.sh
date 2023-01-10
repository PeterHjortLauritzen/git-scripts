#!/bin/tcsh
#setenv PBS_ACCOUNT "P03010039" #AMP development
setenv PBS_ACCOUNT NACM0003 #ACOM refinement project
# P03010039
# P93300042
# P03010083
# P93300075
# P05010048
# P93300642
#
# source code location (assumed to be in /glade/u/home/$USER/src/$src)
#
set src="trunk"
#
# run with CSLAM or without
#
set res="ne30pg3_ne30pg3_mg17" #CAM-SE-CSLAM
#set res="ne30_ne30_mg17"      #CAM-SE (no CSLAM)
#set res="f09_f09_mg17"        #CAM-FV     
#
# compset
#
#set cset="FC2000climo"
#set cset="FWHIST"
#set cset="FW2000climo"
set cset="F2000climo"
#
# location of initial condition files (not in CAM repo yet)
#
set inic="/glade/p/cgd/amp/pel/inic"
#echo "Do CSLAM mods in clm and cime:"
#source clm_and_cime_mods_for_cslam.sh $src #no longer needed with trunk commit 3/26/2019
#echo "Done"
#
# set walltime
#
set walltime="00:15:00"
#
# set pecount:
#
#
# 900, 1800, 2700, 5400 (pecount should divide 6*30*30 evenly for best performance)
#
# Use 5400 for waccm to get approximate 4.2 SYPD
#
#  set pecount="5400"
set pecount="1800"
#
# SE runs fastests with 1 thread (in general)
#
set NTHRDS="1"
#
# nsteps, ndays, nyears
#
set stopoption="ndays" 
#
# number of steps, days or years
#
set steps="1"
#
# set run direcotry name
#
set caze=test_${src}_${cset}_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
#
# create_newcase
#
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q regular --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
#
# make some changes to run setup
#
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
#
# no archiving
#
./xmlchange DOUT_S=FALSE
./xmlchange NTHRDS=$NTHRDS
## timing detail
#./xmlchange TIMER_LEVEL=10
##
#
# setup run
#
./case.setup
#
# point to correct fsurdat file (CLM)
#
#if ($res == "ne30pg3_ne30pg3_mg17") then
#    if ($cset == "FW2000climo") then
#       echo "fsurdat='/glade/p/cesmdata/cseg/inputdata/lnd/clm2/surfdata_map/surfdata_ne30pg3_78pfts_CMIP6_simyr2000_c180731.nc'">>user_nl_clm
#    endif
#endif
echo "interpolate_output = .true.,.true.,.true.,.true.,.true.,.true.,.true.,.true."       	   >> user_nl_cam
echo "inithist           = 'YEARLY'"   >> user_nl_cam
#
# spun-up initial condition files (we use the same initial condition for CSLAM and non-CSLAM runs
#
if ($cset == "FWHIST") then
   echo "ncdata = '$inic/waccm-FWHIST.i.spinup.nc'" >> user_nl_cam
endif
if ($cset == "FW2000climo") then
   echo "ncdata = '$inic/waccm-FW2000climo.i.spinup.nc'" >> user_nl_cam
endif
qcmd -- ./case.build
./case.submit

#!/bin/tcsh
#
# This script is called from performance_master.sh to do performance testing (SYPD as a function of pecount)
#
#setenv PBS_ACCOUNT "P03010039"
setenv PBS_ACCOUNT "P93300642"
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src = "cam_pel_development_trunk"
echo "res $res"
#set res="f09_f09_mg17"     

#
# location of initial condition file (not in CAM yet)
#
set walltime="03:00:00"
echo "pecount is $pecount"
set stopoption="nmonths"
set steps="1"
if ($pecount == "5400") then
  set walltime="00:45:00" #FW2000
endif
if ($pecount == "2700") then
  set walltime="01:30:00" #FW2000
endif
if ($pecount == "1800") then
  set walltime="03:00:00" #FW2000
endif
if ($pecount == "900") then
  set walltime="06:00:00" #FW2000
endif
if ($pecount == "450") then
  set walltime="12:00:00" #FW2000
endif

set caze=perf_${cset}_${res}_${pecount}
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q economy --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
#./xmlchange --append CAM_CONFIG_OPTS="-cppdefs -Dwaccm_debug -nadv_tt=10"
./xmlchange TIMER_LEVEL=10
./xmlchange EPS_AAREA=1.0e-04
if ($pecount == "5400") then
  echo "executing xmlchange CAM_CONFIG_OPTS=' -pcols 9' --append"
  ./xmlchange CAM_CONFIG_OPTS=' -pcols 9' --append
endif
./case.setup
qcmd -- ./case.build
./case.submit

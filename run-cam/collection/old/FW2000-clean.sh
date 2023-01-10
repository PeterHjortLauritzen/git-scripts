#!/bin/tcsh
setenv PBS_ACCOUNT "P19010000" #ACOM account
set src="CAM"
#
# run with CSLAM or without
#
#set res="ne30_ne30_mg17"      #no cslam
set res="ne30pg3_ne30pg3_mg17"      #cslam
set cset="F2000climo"
set walltime="00:30:00"
set pecount="1800"
set NTHRDS="1"
set stopoption="ndays"
set steps="1"
set caze=${src}_${cset}_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q regular --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange NTHRDS=$NTHRDS
./case.setup
echo "interpolate_output = .true.,.true.,.false.,.true."       	   >> user_nl_cam
qcmd -- ./case.build
./case.submit

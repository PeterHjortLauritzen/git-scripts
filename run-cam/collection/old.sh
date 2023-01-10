#!/bin/tcsh
#
# 11/14/2022
#
# This script is to run aqua-planet for timing purposes
#
# Steps:
#
# 1. git clone https://github.com/ESCOMP/CAM cam
# 2. cd cam
# 3. git checkout cam_development
# 4. ./manage_externals/checkout_externals
#
# NOTES:
#
#
unset proj
setenv proj "P93300642"
#setenv proj "P03010039"
unset src
setenv src "/glade/u/home/$USER/src/cam_development/cime/scripts/"
unset res
setenv res "ne30pg3_ne30pg3_mg17"
#setenv res "ne16_ne16_mg17"
unset comp
setenv comp "F2000climo"
unset cam_phys
setenv cam_phys
setenv comp "cam_dev" #one month in 7 minutes with 1800 PE's
#setenv comp "QPC5"
#setenv comp "QPC4"


unset wall
unset pes
setenv pes "1800"
setenv wall "00:20:00"
unset drv
setenv drv "nuopc"
#
# for nuopc
#
module load python/3.7.9
ncar_pylib

unset caze
setenv caze perf_${comp}_#{cam_phys}_${res}_${pes}
if ($comp == "QPC7") then
  $src/create_newcase --case /glade/scratch/$USER/$caze --compset QPC6 --res $res --driver $drv --walltime $wall --mach cheyenne --pecount $pes --project $proj --compiler intel --queue regular --run-unsupported
else
  $src/create_newcase --case /glade/scratch/$USER/$caze --compset $comp --res $res --driver $drv --walltime $wall --mach cheyenne --pecount $pes --project $proj --compiler intel --queue regular --run-unsupported
endif

cd /glade/scratch/$USER/$caze 
./xmlchange NTHRDS=1
./xmlchange STOP_OPTION=nmonths
./xmlchange STOP_N=1
./xmlchange TIMER_LEVEL=10
./xmlchange DOUT_S=FALSE
#if ($comp == "QPC7") then
#  ./xmlchange CAM_CONFIG_OPTS='-phys cam_dev -aquaplanet'
#endif
./case.setup

#qcmd -- ./case.build
#./case.submit

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
#unset proj
set proj = "P93300642"
#set proj = "P03010039"
set src = "/glade/u/home/$USER/src/cam_development/cime/scripts/"
set res = "f09_f09_mg17"
set comp = "QPC6"
#set comp = "QPC5"
#set comp = "QPC4"
set pes = "144"
set wall = "05:00:00"
set drv = "nuopc"
#
# for nuopc
#
module load python/3.7.9
ncar_pylib

set caze = perf_${comp}_${res}_${pes}
echo $caze
$src/create_newcase --case /glade/scratch/$USER/$caze --compset $comp --res $res --driver $drv --walltime $wall --mach cheyenne --pecount $pes --project $proj --compiler intel --queue regular --run-unsupported

cd /glade/scratch/$USER/$caze 
./xmlchange NTHRDS=1
./xmlchange STOP_OPTION=nmonths
./xmlchange STOP_N=1
./xmlchange TIMER_LEVEL=10
./xmlchange DOUT_S=FALSE
#./xmlchange CAM_CONFIG_OPTS='-phys cam_dev -aquaplanet'
./case.setup

qcmd -- ./case.build
./case.submit

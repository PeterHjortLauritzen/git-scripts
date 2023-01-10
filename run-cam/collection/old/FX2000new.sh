#! /bin/tcsh -f
#
cd /glade/work/fvitt/camdev/waccmx_sedycore_cam6_3_019/cime/scripts

set casename = test_case
set casedir = /glade/scratch/$USER/$casename
set pecount="450"
set PBS_ACCOUNT="P93300642"
./create_newcase --res ne30pg3_ne30pg3_mg17 --compset FX2000 --case $casedir --pecount $pecount --project $PBS_ACCOUNT --run-unsupported

cd $casedir

./xmlchange DOUT_S=FALSE
./xmlchange DEBUG=TRUE
./xmlchange STOP_N=3
./xmlchange STOP_OPTION=nsteps
./xmlchange JOB_WALLCLOCK_TIME=00:15:00 --subgroup case.run

./case.setup
qcmd -- ./case.build

./case.submit

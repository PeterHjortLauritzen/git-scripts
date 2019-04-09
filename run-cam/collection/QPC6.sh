#!/bin/tcsh
setenv PBS_ACCOUNT P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="opt-se-cslam"
#set src="trunk" #cam_cesm2_1_rel_07"
set NTHRDS="1"
#
# run with CSLAM or without
#
#set res="ne30pg2_ne30pg2_mg17" #cslam

#set res="ne30pg3_ne30pg3_mg17" #cslam
set res="ne5_ne5_mg37" #cslam
#set res="ne30_ne30_mg17"        #no cslam
#set res="f19_f19_mg17"        #no cslam
#set res="f09_f09_mg17"        #no cslam

#set res="ne5_ne5_mg37"        #no cslam

set stopoption="nsteps"
set steps="3"
#set stopoption="nmonths"
#set steps="13"
#
# DO NOT MODIFY BELOW THIS LINE
#
set cset="QPC6"
#
# location of initial condition file (not in CAM yet)
#
if(`hostname` == 'hobart.cgd.ucar.edu') then
  set inic="/scratch/cluster/pel/inic"
  set homedir="/home"
  set scratch="/scratch/cluster"
#  set queue="monster"
#  set pecount="480"
  set queue="verylong"
  set pecount="192"
  #
  # mapping files (not in cime yet)
  #
  set pg3map="/scratch/cluster/pel/cslam-mapping-files"
  set compiler="nag"
endif
if(`hostname` == 'izumi.unified.ucar.edu') then
  set inic="/scratch/cluster/pel/inic"
  set homedir="/home"
  set scratch="/scratch/cluster"
  set queue="short"
  set pecount="1"
  set compiler="intel"
#  set compiler="nag"
endif
if(`hostname` == 'cheyenne.ucar.edu') then
  echo "setting up for Cheyenne"
  set inic="/glade/p/cgd/amp/pel/inic"
  set homedir="/glade/u/home"
  set scratch="/glade/scratch"
  set queue="regular"
  #
  # 900, 1800, 2700, 5400 (pecount should divide 6*30*30 evenly)
  #
  set pecount="450"
  set compiler="intel"
endif

set caze=inteldebug_${src}_${cset}_CAM_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
#$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime 24:15:00 --pecount $pecount  --project $PBS_ACCOUNT --compiler $compiler --run-unsupported
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime 01:00:00 --pecount $pecount  --project $PBS_ACCOUNT --compiler $compiler --machine hobart --run-unsupported


cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange CASEROOT=$scratch/$USER/$caze
./xmlchange EXEROOT=$scratch/$USER/$caze/bld
./xmlchange RUNDIR=$scratch/$USER/$caze/run
#
./xmlchange DEBUG=TRUE
./xmlchange NTHRDS=$NTHRDS
## timing detail
./xmlchange TIMER_LEVEL=10
##
./xmlchange --append CAM_CONFIG_OPTS="-nadv_tt=5 -cppdefs -Dwdc_debug" #there are already 6 tracers in FKESSLER
#./xmlchange CAM_CONFIG_OPTS="-phys kessler -chem terminator -analytic_ic  -nlev $nlev"
##
./xmlquery CAM_CONFIG_OPTS
./xmlquery EXEROOT
./xmlquery CASEROOT

./case.setup

echo "se_statefreq       = 1"        >> user_nl_cam
#echo "avgflag_pertape(1) = 'I'" >> user_nl_cam
#echo "nhtfrq             = -24,-24 " >> user_nl_cam
#echo "ndens = 1,1 " >> user_nl_cam
echo "interpolate_output = .true.,.true.,.true.,.true." >> user_nl_cam
#echo "fincl2 = 'TT_LW','TT_MD','TT_HI','TTRMD','TT_UN','OMEGA'" >> user_nl_cam
#echo "EMPTY_HTAPES=.true." >> user_nl_cam
#echo "diff_cnsrv_mass_check=.true." >> user_nl_cam
#echo "se_statediag_numtrac = 99" >> user_nl_cam


if(`hostname` == 'hobart.cgd.ucar.edu') then
  ./case.build
endif
if(`hostname` == 'izumi.unified.ucar.edu') then
 ./case.build
endif
if(`hostname` == 'cheyenne.ucar.edu') then
qcmd -- ./case.build
endif
./case.submit


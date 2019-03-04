#!/bin/tcsh
setenv PBS_ACCOUNT P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
#set src="opt-se-cslam-master"
set src="trunk"
#
# number of test tracers
#
set NTHRDS="1"
#
# run with CSLAM or without
#
#set res="f09_f09_mg17"
#set res="ne30pg2_ne30pg2_mg17" #cslam
#set res="ne30pg3_ne30pg3_mg17" #cslam
set res="ne30_ne30_mg17"        #no cslam

#set stopoption="nsteps"
#set steps="3"
set stopoption="ndays"
set steps="1200"
#
# DO NOT MODIFY BELOW THIS LINE
#
set cset="FHS94"
#
# location of initial condition file (not in CAM yet)
#
if(`hostname` == 'hobart.cgd.ucar.edu') then
  set inic="/scratch/cluster/pel/inic"
  set homedir="/home"
  set scratch="/scratch/cluster"
  set queue="monster"
  set pecount="480" #10 nodes
#  set pecount="768" #16 nodes  
  set machine="hobart"  
  #
  # mapping files (not in cime yet)
  #
  set pg3map="/scratch/cluster/pel/cslam-mapping-files"
#  set compiler="intel"
  set compiler="pgi"
endif

if(`hostname` == 'izumi.unified.ucar.edu') then
  set inic="/scratch/cluster/pel/inic"
  set homedir="/home"
  set scratch="/scratch/cluster"
  set queue="monster"
  set pecount="480"
  set machine="hobart"
  #
  # mapping files (not in cime yet)
  #
  set pg3map="/scratch/cluster/pel/cslam-mapping-files"
  set compiler="intel"
endif
if(`hostname` == 'cheyenne') then
  echo "setting up for Cheyenne"
  set inic="/glade/p/cgd/amp/pel/inic"
  set homedir="/glade/u/home"
  set scratch="/glade/scratch"
  set queue="regular"
  #
  # 900, 1800, 2700, 5400 (pecount should divide 6*30*30 evenly)
  #
  set pecount="180"
  set machine="cheyenne"  
  set compiler="intel"
endif

set caze=nu_top_2.5e5_hypervisOnPlevsFalse_${src}_${cset}_CAM_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime 24:00:00 --pecount $pecount  --project $PBS_ACCOUNT --compiler $compiler --machine $machine --run-unsupported

cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange CASEROOT=$scratch/$USER/$caze
./xmlchange EXEROOT=$scratch/$USER/$caze/bld
./xmlchange RUNDIR=$scratch/$USER/$caze/run
#
#./xmlchange DEBUG=TRUE
./xmlchange NTHRDS=$NTHRDS
## timing detail
./xmlchange TIMER_LEVEL=10
##
#./xmlchange --append CAM_CONFIG_OPTS="-nadv_tt=194" #there are already 6 tracers in FKESSLER
#./xmlchange CAM_CONFIG_OPTS="-phys kessler -chem terminator -analytic_ic  -nlev $nlev"
##
./xmlquery CAM_CONFIG_OPTS
./xmlquery EXEROOT
./xmlquery CASEROOT

./case.setup

echo "se_statefreq       = 244"        >> user_nl_cam
#echo "avgflag_pertape(1) = 'I'" >> user_nl_cam
echo "nhtfrq             = 0,0 " >> user_nl_cam
#echo "ndens = 1,1 " >> user_nl_cam
echo "interpolate_output = .true.,.true.,.true.,.true.,.true." >> user_nl_cam
#echo "se_nu_top = 1.0e5"  >> user_nl_cam
echo "se_hypervis_on_plevs           = .false." >> user_nl_cam
echo "fincl2 = 'PS'" >> user_nl_cam
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


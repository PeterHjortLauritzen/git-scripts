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
set res="ne30pg2_ne30pg2_mg17" #cslam
#set res="ne30pg3_ne30pg3_mg17" #cslam

set stopoption="nsteps"
set steps="2"
#set stopoption="ndays"
#set steps="15"
#
# DO NOT MODIFY BELOW THIS LINE
#
set cset="FKESSLER"
#set cset="QPC4"
#
# location of initial condition file (not in CAM yet)
#
if(`hostname` == 'hobart.cgd.ucar.edu') then
  set inic="/scratch/cluster/pel/inic"
  set homedir="/home"
  set scratch="/scratch/cluster"
  set queue="short"
  set pecount="192"
  #
  # mapping files (not in cime yet)
  #
  set pg3map="/scratch/cluster/pel/cslam-mapping-files"
  set compiler="nag"
else
  echo "setting up for Cheyenne"
  set inic="/glade/p/cgd/amp/pel/inic"
  set homedir="/glade/u/home"
  set scratch="/glade/scratch"
  set queue="regular"
  #
  # 900, 1800, 2700, 5400 (pecount should divide 6*30*30 evenly)
  #
  set pecount="180"
  set compiler="intel"
endif

set caze=xxx_${src}_${cset}_CAM_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime 00:15:00 --pecount $pecount  --project $PBS_ACCOUNT --compiler $compiler --run-unsupported

cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange CASEROOT=$scratch/$USER/$caze
./xmlchange EXEROOT=$scratch/$USER/$caze/bld
./xmlchange RUNDIR=$scratch/$USER/$caze/run
#
./xmlchange DEBUG=FALSE
./xmlchange NTHRDS=$NTHRDS
## timing detail
./xmlchange TIMER_LEVEL=10
##
#./xmlchange --append CAM_CONFIG_OPTS="-nadv_tt=194" #there are already 6 tracers in FKESSLER
./xmlchange --append CAM_CONFIG_OPTS="-cppdefs -Ddebug_coupling"
#./xmlchange CAM_CONFIG_OPTS="-phys kessler -chem terminator -analytic_ic  -nlev $nlev"
##
./xmlquery CAM_CONFIG_OPTS
./xmlquery EXEROOT
./xmlquery CASEROOT

./case.setup

echo "se_statefreq       = 1"        >> user_nl_cam
echo "ncdata = '/fs/cgd/csm/inputdata/atm/cam/inic/se/ape_topo_cam4_ne30np4_L26_c171020.nc'" >> user_nl_cam
#/fs/cgd/csm/inputdata/atm/cam/inic/se/ape_topo_cam4_ne30np4_L30_c171020.nc'" >> user_nl_cam
#echo "use_topo_file          = .false." >> user_nl_cam
#echo "bnd_topo = '/fs/cgd/csm/inputdata/atm/cam/topo/se/ne30pg3_nc3000_Co060_Fi001_PF_nullRR_Nsw042_20171014.nc'" >> user_nl_cam
echo "avgflag_pertape(1) = 'I'" >> user_nl_cam
echo "nhtfrq             = 1,1 " >> user_nl_cam
echo "interpolate_output = .false.,.true." >> user_nl_cam
echo "fincl1 = 'RHO_fvm','f2p_RHO_fvm','f2p_RHO_err','f2p_RHO','p2f_RHO_fvm','p2f_RHO_err_fvm','p2f_RHO'" >> user_nl_cam
echo "fincl2 = 'RHO_fvm','f2p_RHO_fvm','f2p_RHO_err','f2p_RHO','p2f_RHO_fvm','p2f_RHO_err_fvm','p2f_RHO'" >> user_nl_cam

if(`hostname` == 'hobart.cgd.ucar.edu') then
  ./case.build
else
qcmd -- ./case.build
endif
./case.submit


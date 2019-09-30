#!/bin/tcsh
setenv PBS_ACCOUNT NACM0003
#
# P93300642
#
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="opt-se-cslam-trunk"
#set src="trunk"
set cset="FHS94"
set lev="waccmx"
#set lev="cam"
#set cset="FC6X2000" 
#
set NTHRDS="1"
#
# run with CSLAM or without
#
set res="f09_f09_mg17"
#set res="ne30pg2_ne30pg2_mg17" #cslam
#set res="ne30pg3_ne30pg3_mg17" #cslam
#set res="ne0CONUSne30x8_ne0CONUSne30x8_mg17"
#set res="ne30_ne30_mg17"        #no cslam
#set res="ne120_ne120_mg16"
#set res="ne120pg3_ne120pg3_mg17"
set stopoption="nsteps"
set steps="1"
#set stopoption="ndays"
#set steps="1200"

if(`hostname` == 'izumi.unified.ucar.edu') then
  set inic="/scratch/cluster/pel/inic"
  set homedir="/home"
  set inputdir="/fs/cgd/csm/inputdata/atm/cam/"
  set scratch="/scratch/cluster"
#  set queue="monster"
  set queue="short"
#  set pecount="672" #14 nodes (all of machine)
#  set pecount="480"
  set pecount="4"  
  set walltime="02:00:00"
  set machine="izumi"
  #
  # mapping files (not in cime yet)
  #
  set compiler="nag"
endif

#set caze=test-nag-cslam-pe96-hs94-fv-debug
set caze=${cset}_${src}_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --compiler $compiler --machine $machine --run-unsupported

cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
if ($lev == "cam6") then
  ./xmlchange CAM_CONFIG_OPTS="-phys held_suarez -nlev 32" #very important: otherwise you get PS=1000hPa initial condition
endif 
#
# waccm-x
#
if ($lev == "waccmx") then
  ./xmlchange --append CAM_CONFIG_OPTS="-phys held_suarez -nlev 130 -analytic_ic"
endif
#./xmlchange --append CAM_CONFIG_OPTS="-analytic_ic"
#
#./xmlchange DEBUG=TRUE
./xmlchange NTHRDS=$NTHRDS
## timing detail
#./xmlchange --append CAM_CONFIG_OPTS="-nadv_tt=194" #there are already 6 tracers in FKESSLER
#./xmlchange CAM_CONFIG_OPTS="-phys kessler -chem terminator -analytic_ic  -nlev $nlev"
##

./case.setup

if ($res == "ne30_ne30_mg17") then
  echo "se_statefreq       = 1"        >> user_nl_cam
  echo "bnd_topo = '$inputdir/topo/se/ne30pg3_nc3000_Co060_Fi001_PF_nullRR_Nsw042_20171014.nc'">>user_nl_cam
  echo "interpolate_output = .true.,.true.,.false." >> user_nl_cam        
endif

echo "analytic_ic_type = 'us_standard_atmosphere'" >> user_nl_cam
echo "use_topo = .true."
if ($lev == "waccmx") then
  echo "ncdata='/fs/cgd/csm/inputdata/atm/waccm/ic/waccmx_mam4_aqua_4x5_L130_c180803.nc'" >> user_nl_cam
endif  

#
echo "nhtfrq             = 1,1,1 " >> user_nl_cam
echo "fincl1             = 'PS','T','Z3','U','V','OMEGA','PHIS','OMEGA500','OMEGA850','PSL','PHIS' ">> user_nl_cam
echo "nhtfrq             = 1,1,1 " >> user_nl_cam
echo "empty_htapes = .true." >> user_nl_cam
./case.submit


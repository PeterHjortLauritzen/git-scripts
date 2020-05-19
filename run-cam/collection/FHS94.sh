#!/bin/tcsh
setenv PBS_ACCOUNT NACM0003
#
# P93300642
#
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="opt-se-cslam-new"
#set src="trunk"
set cset="FHS94"
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

#
# machine specific settings
#
if(`hostname` == 'hobart.cgd.ucar.edu') then
  set inic="/scratch/cluster/pel/inic"
  set homedir="/home"
  set scratch="/scratch/cluster"
  set queue="monster"
  set pecount="480" #10 nodes
  set walltime="24:00:00"
#  set pecount="768" #16 nodes  
  set machine="hobart"  
  #
  # mapping files (not in cime yet)
  #
  set pg3map="/scratch/cluster/pel/cslam-mapping-files"
  set compiler="intel"
#  set compiler="pgi"
endif

if(`hostname` == 'izumi.unified.ucar.edu') then
  set inic="/scratch/cluster/pel/inic"
  set homedir="/home"
  set scratch="/scratch/cluster"
  set queue="monster"
#  set pecount="672" #14 nodes (all of machine)
  set pecount="480"
  set walltime="24:00:00"
  set machine="izumi"
  #
  # mapping files (not in cime yet)
  #
  set pg3map="/scratch/cluster/pel/cslam-mapping-files"
  set compiler="intel"
endif
if(`hostname` == 'cheyenne5') then
  echo "setting up for Cheyenne"
  set inic="/glade/p/cgd/amp/pel/inic"
  set homedir="/glade/u/home"
  set scratch="/glade/scratch"
  set queue="regular"
  #
  # 900, 1800, 2700, 5400 (pecount should divide 6*30*30 evenly)
  #
  set pecount="2700" # 637 SYPD with FHS94 ne30_ne30; runs in 8min
  set walltime="00:10:00"

  set machine="cheyenne"  
  set compiler="intel"
endif

set caze=${machine}_${src}_${cset}_CAM_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --compiler $compiler --machine $machine --run-unsupported

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
#echo "se_nu_top = 1.25e5"  >> user_nl_cam
#echo "se_hypervis_on_plevs           = .false." >> user_nl_cam
#echo "ncdata='/scratch/cluster/pel/nu_top_0.25_trunk_FHS94_CAM_ne30_ne30_mg17_480_NTHRDS1_1200ndays/run/nu_top_0.25_trunk_FHS94_CAM_ne30_ne30_mg17_480_NTHRDS1_1200ndays.cam.i.0002-01-01-00000.nc'"

echo "se_nu              =   0.4e15  ">> user_nl_cam
echo "se_nu_div          =   2.0e15  ">> user_nl_cam
echo "se_nu_p            =   1.0e15  ">> user_nl_cam
echo "use_topo_file      =  .true.   ">>user_nl_cam
echo "se_hypervis_subcycle        = 3">>user_nl_cam

echo "bnd_topo = '/fs/cgd/csm/inputdata/atm/cam/topo/se/ne30np4_nc3000_Co060_Fi001_PF_nullRR_Nsw042_20171020.nc'">>user_nl_cam
#echo "bnd_topo = '/project/amp/pel/release/topo/old/ne30np4_nc3000_Co092_Fi001_MulG_PF_nullRR_Nsw064_20170510.nc'">>user_nl_cam
echo "ncdata = '/fs/cgd/csm/inputdata/atm/cam/inic/se/ape_topo_cam4_ne30np4_L30_c171020.nc'" >>user_nl_cam
#echo "ncdata = '/scratch/cluster/pel/opt-se-cslam-pgf_FHS94_CAM_ne30_ne30_mg17_480_NTHRDS1_1200ndays/run/opt-se-cslam-pgf_FHS94_CAM_ne30_ne30_mg17_480_NTHRDS1_1200ndays.cam.i.0001-02-01-00000.nc'">>user_nl_cam

echo "inithist          =  'MONTHLY'">>user_nl_cam
echo "fincl2 = 'PS'" >> user_nl_cam
if(`hostname` == 'hobart.cgd.ucar.edu') then
  ./case.build
endif
if(`hostname` == 'izumi.unified.ucar.edu') then
  ./case.build
endif  
if(`hostname` == 'cheyenne5') then
  qcmd -- ./case.build
endif
./case.submit


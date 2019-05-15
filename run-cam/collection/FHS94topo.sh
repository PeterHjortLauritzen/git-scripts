#!/bin/tcsh
setenv PBS_ACCOUNT NACM0003
#
# P93300642
#
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="opt-se-cslam"
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
#set res="ne120_ne120_mg16"
#set stopoption="nsteps"
#set steps="3"
set stopoption="ndays"
set steps="1200"
#set steps="1"
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
#  set pecount="480" #10 nodes
  set pecount="192"
  set walltime="24:00:00"
#  set pecount="768" #16 nodes
#  set pecount="672"
  set machine="hobart"  
  #
  # mapping files (not in cime yet)
  #
  set pg3map="/scratch/cluster/pel/cslam-mapping-files"
  set compiler="intel"
#  set compiler="nag"  
#  set compiler="pgi"
endif

if(`hostname` == 'izumi.unified.ucar.edu') then
  set inic="/scratch/cluster/pel/inic"
  set homedir="/home"
  set inputdir="fs/cgd/csm/inputdata/atm/cam/"
  set scratch="/scratch/cluster"
  set queue="monster"
#  set pecount="672" #14 nodes (all of machine)
  set pecount="480"
#  set pecount="192"  
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
  set inputdir="/glade/p/cesmdata/cseg/inputdata/atm/cam"
  set scratch="/glade/scratch"
  set queue="regular"
  #
  # 900, 1800, 2700, 5400 (pecount should divide 6*30*30 evenly)
  #
  # 637 SYPD with FHS94 ne30_ne30 using 2700 PEs; runs in 8min
  #
#  set pecount="10800" 
  set pecount="2700" 
  set walltime="00:25:00"

  set machine="cheyenne"  
  set compiler="intel"
endif

set caze=dyn_ref_1.0nu_p_0.5_nu_6.0_nu_div_C60topo_${cset}_topo_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --compiler $compiler --machine $machine --run-unsupported

cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange CAM_CONFIG_OPTS="-phys held_suarez" #very important: otherwise you get PS=1000hPa initial condition
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

echo "use_topo_file      =  .true.   ">>user_nl_cam
if ($res == "f09_f09_mg17") then
  echo "bnd_topo = '$inputdir/topo/fv_0.9x1.25_nc3000_Nsw042_Nrs008_Co060_Fi001_ZR_sgh30_24km_GRNL_c170103.nc'">>user_nl_cam
  echo "ncdata   = '$inputdir/inic/fv/cami-mam3_0000-01-01_0.9x1.25_L30_c100618.nc'" >>user_nl_cam
else

  #echo "avgflag_pertape(1) = 'I'" >> user_nl_cam

  #echo "ndens = 1,1 " >> user_nl_cam
  echo "interpolate_output = .true.,.true.,.false." >> user_nl_cam  

#  echo "se_hypervis_dynamic_ref_state = .true." >> user_nl_cam
#  echo "se_nu              =   0.5e15  ">> user_nl_cam
#  echo "se_nu_div          =   6.0e15  ">> user_nl_cam
#  echo "se_nu_p            =   1.0e15  ">> user_nl_cam
#  echo "se_hypervis_subcycle    = 5">>user_nl_cam
#  echo "se_hypervis_subcycle_q  = 1">>user_nl_cam

  if ($res == "ne30_ne30_mg17") then
    echo "se_statefreq       = 256"        >> user_nl_cam
    echo "interpolate_nlat = 192,192,192" >> user_nl_cam
    echo "interpolate_nlon = 288,288,288" >> user_nl_cam    
    echo "bnd_topo = '$inputdir/topo/se/ne30np4_nc3000_Co060_Fi001_PF_nullRR_Nsw042_20171020.nc'">>user_nl_cam
#  echo "bnd_topo = '/project/amp/pel/release/topo/old/ne30np4_nc3000_Co092_Fi001_MulG_PF_nullRR_Nsw064_20170510.nc'">>user_nl_cam
    echo "ncdata = '$inputdir/inic/se/ape_topo_cam4_ne30np4_L30_c171020.nc'" >>user_nl_cam
  endif

  if ($res == "ne30pg3_ne30pg3_mg17") then
    echo "se_statefreq       = 256"        >> user_nl_cam
    echo "interpolate_nlat = 192,192,192" >> user_nl_cam
    echo "interpolate_nlon = 288,288,288" >> user_nl_cam  
    echo "bnd_topo = '$inputdir/topo/se/ne30pg3_nc3000_Co060_Fi001_PF_nullRR_Nsw042_20171014.nc'">>user_nl_cam
#  echo "bnd_topo = '/project/amp/pel/release/topo/old/ne30np4_nc3000_Co092_Fi001_MulG_PF_nullRR_Nsw064_20170510.nc'">>user_nl_cam
    echo "ncdata = '$inputdir/cam/inic/se/ape_topo_cam4_ne30np4_L30_c171020.nc'" >>user_nl_cam
  endif

  if ($res == "ne120_ne120_mg16") then
    echo "se_statefreq       = 600"        >> user_nl_cam
    echo "interpolate_nlat = 192,720,192" >> user_nl_cam
    echo "interpolate_nlon = 288,1440,288" >> user_nl_cam  
    echo "bnd_topo = '/glade/scratch/pel/ne120np4_nc3000_Co060_Fi001_PF_nullRR_Nsw042_20171010.nc'">>user_nl_cam
    echo "ncdata = '/glade/p/cesmdata/cseg/inputdata/atm/cam/inic/se/ape_topo_cam4_ne120np4_L30_c171024.nc'" >>user_nl_cam
    echo "restart_n = 1"              >> user_nl_cam
    echo "restart_option = 'nmonths'" >> user_nl_cam
  endif

endif

echo "nhtfrq             = 0,0,0 " >> user_nl_cam
echo "fincl1             = 'PS','T','Z3','U','V','OMEGA','PHIS','OMEGA500','OMEGA850','PSL' ">> user_nl_cam
echo "fincl2             = 'PS','T','Z3','U','V','OMEGA','PHIS','OMEGA500','OMEGA850','PSL' ">> user_nl_cam
echo "fincl3             = 'PS','T','Z3','U','V','OMEGA','PHIS','OMEGA500','OMEGA850','PSL' ">> user_nl_cam
echo "inithist           =  'MONTHLY'">>user_nl_cam

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


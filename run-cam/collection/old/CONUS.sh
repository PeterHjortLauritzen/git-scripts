#!/bin/tcsh
#setenv PBS_ACCOUNT "P03010039"
#setenv PBS_ACCOUNT NACM0003
setenv PBS_ACCOUNT "P19010000" #ACOM account
#setenv PBS_ACCOUNT "P93300642"
# P03010039
# P93300042
# P03010083
# P93300075
# P05010048
# P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
#set src="trunk"
set src="CAM"

#set res="ne0CONUSne30x8_ne0CONUSne30x8_mg17"
set res="ne0CONUSne30x8_ne0CONUSne30x8_mt12"
#set res="ne30_ne30_mg17"
#set res="ne0TESTONLYne5x4_ne0TESTONLYne5x4_mg37"


#set cset="FWHIST"
set cset="FW2000climo"
#set cset="FC2000climo"
#set cset="FCHIST"
#set cset="F2000climo"
#set cset="FHS94"
#set cset="FADIAB"
#set cset="FKESSLER"
#
# location of initial condition file (not in CAM yet)
#
if(`hostname` == 'izumi.unified.ucar.edu') then
  set homedir="/home"
  set scratch="/scratch/cluster"
  set walltime="00:55:00"
  set pecount="480"  
  set queue="monster"
#  set queue="verylong"  
else
  set homedir="/glade/u/home"
  set inic="/glade/p/cgd/amp/pel/inic"
  set scratch="/glade/scratch"  
  set walltime="00:35:00"
  set pecount="1800"
  set queue="regular"  
endif


set NTHRDS="1"
set stopoption="ndays"
set steps="1"

set caze=balanced_${src}_${cset}_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange NTHRDS=$NTHRDS
## timing detail
./xmlchange TIMER_LEVEL=10
#./xmlchange --append CAM_CONFIG_OPTS="-analytic_ic"
##
if ($cset == "ne0CONUSne30x8_ne0CONUSne30x8_mt12") then
#  ./xmlchange ICE_DOMAIN_FILE=domain.ocn.ne0CONUSne30x8_tx0.1v2.171010.nc
#  ./xmlchange OCN_DOMAIN_FILE=domain.ocn.ne0CONUSne30x8_tx0.1v2.171010.nc  
#  ./xmlchange ATM_DOMAIN_FILE=domain.lnd.ne0CONUSne30x8_tx0.1v2.171010.nc  
#  ./xmlchange LND_DOMAIN_FILE=domain.lnd.ne0CONUSne30x8_tx0.1v2.171010.nc  
#  ./xmlchange EPS_AAREA=9.0e-6
endif
  ./xmlchange EPS_AAREA=9.0e-6
if ($cset == "FKESSLER") then
  ./xmlchange CAM_CONFIG_OPTS=" -phys kessler -chem terminator -nlev 70"
endif

./xmlchange ATM_NCPL=384
./xmlchange REST_OPTION="nsteps"
./xmlchange REST_N=96
#echo "se_nsplit=4" >> user_nl_cam
if ($cset == "FADIAB") then
  ./xmlchange --append CAM_CONFIG_OPTS=" -nlev 70"
#  ./xmlchange --append CAM_CONFIG_OPTS="-analytic_ic -nlev 32"
#  echo "ndens=1 nhtfrq=1"   >> user_nl_cam
#  echo "analytic_ic_type ='moist_baroclinic_wave_dcmip2016'" >> user_nl_cam
#  echo "state_debug_checks=.true. "                          >> user_nl_cam
endif
if ($cset == "FHS94") then
  ./xmlchange CAM_CONFIG_OPTS="-phys held_suarez -nlev 70" #very important: otherwise you get PS=1000hPa initial condition
endif

./case.setup

#echo "fincl1             = 'OMEGA500','OMEGA850','PTTEND','FT','ABS_dPSdt'" >> user_nl_cam
#echo "interpolate_output = .true.,.true."              	                    >> user_nl_cam
#echo "inithist           = '6-HOURLY'"   >> user_nl_cam
#echo "se_statefreq       = 1"                                             >> user_nl_cam
if(`hostname` == 'izumi.unified.ucar.edu') then
 echo "bnd_topo = '/project/amp/pel/release/topo/conus/conus_30_x8_nc3000_Co060_Fi001_MulG_PF_nullRR_Nsw042.C60-repaired.nc'"  >> user_nl_cam
else
# echo "ncdata = '/glade/p/nsc/nacm0003/input/CAM-SE/FW2000climo_conus_30_x8_c190613.nc'"   >> user_nl_cam
 echo "ncdata = '/glade/p/cgd/amp/pel/inic/waccm.CONUS.i.nc'" >> user_nl_cam
echo "se_hypervis_subcycle = 1" >> user_nl_cam
echo "se_hypervis_subcycle_sponge = 1" >> user_nl_cam
echo "se_nu_top = 1.25E5" >> user_nl_cam
echo "se_rayk0= 3" >> user_nl_cam
echo "se_raytau0= 0.002" >> user_nl_cam
echo "se_raykrange= 0.5" >> user_nl_cam
echo "inithist = 'DAILY'" >> user_nl_cam
#/glade/p/cgd/amp/pel/inic/conus-1year-spinup-F2000climo.i.nc
# echo "bnd_topo = '/glade/p/cgd/amp/pel/topo/conus_30_x8_nc3000_Co060_Fi001_MulG_PF_nullRR_Nsw042.C60-repaired.nc'" >>user_nl_cam
endif
#echo "analytic_ic_type = 'us_standard_atmosphere'" >> user_nl_cam
echo "use_topo_file      =  .true.   ">>user_nl_cam

if(`hostname` == 'izumi.unified.ucar.edu') then
  ./case.build
else
  qcmd -- ./case.build
endif  
./case.submit

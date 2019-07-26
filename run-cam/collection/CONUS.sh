#!/bin/tcsh
#setenv PBS_ACCOUNT "P03010039"
setenv PBS_ACCOUNT NACM0003
# P03010039
# P93300042
# P03010083
# P93300075
# P05010048
# P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="opt-se-cslam"

#set res="ne0CONUSne30x8_ne0CONUSne30x8_mg17"
#set res="ne0CONUSne30x8_ne0CONUSne30x8_mt12"
set res="ne30_ne30_mg17"

#set cset="FWHIST"
set cset="FW2000climo"
#set cset="F2000climo"
#set cset="FHS94"
#
# location of initial condition file (not in CAM yet)
#
set inic="/glade/p/cgd/amp/pel/inic"
set walltime="00:55:00"
set pecount="1800"
set NTHRDS="1"
set stopoption="ndays"
set steps="10"

set caze=${src}_${cset}_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q regular --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange NTHRDS=$NTHRDS
## timing detail
./xmlchange TIMER_LEVEL=10
##
if ($cset == "ne0CONUSne30x8_ne0CONUSne30x8_mt12") then
  ./xmlchange ICE_DOMAIN_FILE=domain.ocn.ne0CONUSne30x8_tx0.1v2.171010.nc
  ./xmlchange OCN_DOMAIN_FILE=domain.ocn.ne0CONUSne30x8_tx0.1v2.171010.nc  
  ./xmlchange ATM_DOMAIN_FILE=domain.lnd.ne0CONUSne30x8_tx0.1v2.171010.nc  
  ./xmlchange LND_DOMAIN_FILE=domain.lnd.ne0CONUSne30x8_tx0.1v2.171010.nc  
  ./xmlchange EPS_AAREA=9.0e-6
endif

if ($cset == "FHS94") then
  ./xmlchange CAM_CONFIG_OPTS="-phys held_suarez -nlev 70" #very important: otherwise you get PS=1000hPa initial condition
endif

./case.setup

echo "fincl1             = 'OMEGA500','OMEGA850','PTTEND','FT','ABS_dPSdt'" >> user_nl_cam
echo "interpolate_output = .true.,.true."              	                    >> user_nl_cam
echo "inithist           = '6-HOURLY'"   >> user_nl_cam
echo "se_statefreq       = 1"                                             >> user_nl_cam
# echo "ncdata = '/glade/p/nsc/nacm0003/input/CAM-SE/FW2000climo_conus_30_x8_c190613.nc'"   >> user_nl_cam
# echo "bnd_topo = '/glade/p/cgd/amp/pel/topo/conus_30_x8_nc3000_Co060_Fi001_MulG_PF_nullRR_Nsw042.C60-repaired.nc'">>user_nl_cam
# echo "use_topo_file      =  .true.   ">>user_nl_cam
qcmd -- ./case.build
./case.submit

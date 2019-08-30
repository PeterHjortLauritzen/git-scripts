#!/bin/tcsh
setenv PBS_ACCOUNT NACM0003
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
#set src="trunk"
set src="fisher"
#set src="opt-se-cslam"

#set res="ne0CONUSne30x8_ne0CONUSne30x8_mt12" # CONUS with 1/10 degree ocean mask - recommended for CONUS
#set res="ne30_ne30_mg17"         #SE
#set res="ne30pg3_ne30pg3_mg17"   #SE-CSLAM - recommended for 1 degree
set res="ne30pg3_ne30pg3_mt12"   #SE-CSLAM - recommended for 1 degree

#set cset="FW2000climo"
set cset="F2000climo"
#set cset="FC2000climo"
#set cset="FCHIST"
#set cset="FWHIST"

set homedir="/glade/u/home"
set inic="/glade/p/cgd/amp/pel/inic"
set scratch="/glade/scratch"  
set walltime="03:00:00"
set queue="regular"  
#
# SE and SE-CSLAM does not run faster with threads - always use 1 thread and set pecount explicitly
#
# For best performance with 1 degree use: pecout = 450,900,1800,2700,5400
#
set pecount="5400"
set NTHRDS="1" 

set stopoption="ndays"
set steps="30"

set caze=${src}_${cset}_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported

cd $scratch/$USER/$caze

./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange NTHRDS=$NTHRDS
## timing detail
./xmlchange TIMER_LEVEL=10
##
if ($res == "ne0CONUSne30x8_ne0CONUSne30x8_mt12") then
  ./xmlchange EPS_AAREA=9.0e-4
endif
./case.setup

if ($res == "ne0CONUSne30x8_ne0CONUSne30x8_mt12") then
  if ($cset == "FWHIST") then
    echo "ncdata   = '/glade/p/cgd/amp/pel/inic/waccm.CONUS.i.nc'" >> user_nl_cam
  endif
  if ($cset == "FW2000climo") then
    echo "ncdata   = '/glade/p/cgd/amp/pel/inic/waccm.CONUS.i.nc'" >> user_nl_cam
  endif

  echo "bnd_topo = '/glade/p/cgd/amp/pel/topo/conus_30_x8_nc3000_Co060_Fi001_MulG_PF_nullRR_Nsw042.C60-repaired.nc'" >>user_nl_cam

  if ($cset == "FCHIST") then
    echo "fsurdat = '/glade/p/cesmdata/cseg/inputdata/lnd/clm2/surfdata_map/surfdata_ne0CONUSne30x8_hist_16pfts_Irrig_CMIP6_simyr1850_c190402.nc'" >> user_nl_clm
    echo "flanduse_timeseries = '/glade/p/cesmdata/cseg/inputdata/lnd/clm2/surfdata_map/landuse.timeseries_ne0CONUSne30x8_hist_16pfts_Irrig_CMIP6_simyr1850-2100_c190402.nc'" >> user_nl_clm
  endif

  if ($cset == "FWHIST") then
    echo "fsurdat = '/glade/p/cesmdata/cseg/inputdata/lnd/clm2/surfdata_map/surfdata_ne0CONUSne30x8_hist_16pfts_Irrig_CMIP6_simyr1850_c190402.nc'" >> user_nl_clm
    echo "flanduse_timeseries = '/glade/p/cesmdata/cseg/inputdata/lnd/clm2/surfdata_map/landuse.timeseries_ne0CONUSne30x8_hist_16pfts_Irrig_CMIP6_simyr1850-2100_c190402.nc'" >> user_nl_clm
  endif
endif

qcmd -- ./case.build
#./case.submit

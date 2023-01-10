#!/bin/tcsh
#setenv PBS_ACCOUNT "P93300642"
setenv PBS_ACCOUNT "P93300007"
set src="cam_development"
#
# run with CSLAM or without
#
#set res="ne0CONUSne30x8_ne0CONUSne30x8_mg17"
set res="ne0CONUSne30x8_ne0CONUSne30x8_mt12"
set cset="FWHIST"
set walltime="2:00:00"
set pecount="5400"
set NTHRDS="1"
set stopoption="ndays"
set steps="1"
set caze=nich_${cset}_${res}
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q economy --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange NTHRDS=$NTHRDS
./xmlchange --append CAM_CONFIG_OPTS="-nlev 110" 
#./xmlchange --append CAM_CONFIG_OPTS="-analytic_ic -nlev 110" 
./xmlchange RUN_STARTDATE=2010-01-01
./case.setup
echo "empty_htapes       = .true." >> user_nl_cam
echo "interpolate_output = .true."       	   >> user_nl_cam
echo "avgflag_pertape = 'I','A','A','A','A','A','A','A','A','A','A'"              >> user_nl_cam
echo "fincl1             = 'Q','PS','T','Z3','U','V','OMEGA','PHIS','OMEGA500','OMEGA850','PSL','PHIS', ">> user_nl_cam
echo "                     'PTTEND','OMEGAT','ABS_dPSdt','FU','FV','FT' ">> user_nl_cam
echo "fincl2 = 'PS'" >> user_nl_cam
echo "fincl3 = 'PS'" >> user_nl_cam
echo "fincl4 = 'PS'" >> user_nl_cam
echo "fincl5 = 'PS'" >> user_nl_cam
echo "fincl6 = 'PS'" >> user_nl_cam
echo "fincl7 = 'PS'" >> user_nl_cam
echo "inithist           = 'DAILY'" >> user_nl_cam
echo "nhtfrq             = -6,0,0,0,0,0,0,0,0,0" >> user_nl_cam
echo "mfilt             =  1" >> user_nl_cam
echo "ncdata             = '/glade/p/cgd/amp/pel/inic/waccm-conus-FW-nlev110.i.nc'" >> user_nl_cam

#echo "analytic_ic_type   = 'us_standard_atmosphere'" >> user_nl_cam
#echo "bnd_topo = '/glade/p/cesmdata/cseg/inputdata/atm/cam/topo/se/ne30x8_CONUS_nc3000_Co060_Fi001_MulG_PF_RR_Nsw042_c200428.nc'" >> user_nl_cam
#echo "use_topo_file          =.true." >> user_nl_cam

echo "se_statefreq = 256" >> user_nl_cam
echo "effgw_beres_dp = 0.7" >> user_nl_cam

echo "check_finidat_year_consistency = .false."  >> user_nl_clm

qcmd -- ./case.build
./case.submit


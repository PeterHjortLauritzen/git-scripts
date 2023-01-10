#!/bin/tcsh
setenv PBS_ACCOUNT "P19010000" #ACOM account
set src="CAM-2020-01-24"
#
# run with CSLAM or without
#
#set res="ne0CONUSne30x8_ne0CONUSne30x8_mg17"
#set cset="FHS94"
set res="ne30pg3_ne30pg3_mg17"
#set res="ne30_ne30_mg17"
set cset="FW2000climo"
set walltime="00:30:00"
set pecount="1800"
set NTHRDS="1"
set stopoption="ndays"
set steps="1"
set caze=spinup_${src}_${cset}_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q regular --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange NTHRDS=$NTHRDS
#./xmlchange CAM_CONFIG_OPTS="-phys held_suarez -analytic_ic -nlev 70" 
#./xmlchange --append CAM_CONFIG_OPTS="-analytic_ic -cppdefs -Dwaccm_debug" 
./xmlchange CAM_CONFIG_OPTS="-phys CAM6 -age_of_air_trcs -chem waccm_tsmlt_mam4 -analytic_ic -cppdefs -Dwaccm_debug"

./case.setup
echo "interpolate_output = .true."       	   >> user_nl_cam
#echo "bnd_topo = '/glade/p/cgd/amp/pel/topo/conus_30_x8_nc3000_Co060_Fi001_MulG_PF_nullRR_Nsw042.C60-repaired.nc'">>user_nl_cam
echo "use_topo_file      =  .true.   ">>user_nl_cam
echo "fincl1             = 'Q','PS','T','Z3','U','V','OMEGA','PHIS','OMEGA500','OMEGA850','PSL','PHIS', ">> user_nl_cam
echo "                     'PTTEND','OMEGAT','ABS_dPSdt','FU','FV','FT' ">> user_nl_cam
echo "nhtfrq             = -3"
echo "inithist           = '6-HOURLY'"   >> user_nl_cam
echo "ncdata             = '/glade/scratch/pel/inic/ne30_waccm.i.nc'">> user_nl_cam
echo "analytic_ic_type   = 'us_standard_atmosphere'" >> user_nl_cam
echo "se_statefreq       = 1"        >> user_nl_cam
echo "se_statediag_numtrac = 99  " >> user_nl_cam
qcmd -- ./case.build
./case.submit

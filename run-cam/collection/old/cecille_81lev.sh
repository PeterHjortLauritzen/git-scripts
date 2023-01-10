#!/bin/tcsh
setenv PBS_ACCOUNT "P93300642"
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
# How to get code?
#
# cd ~/src
# git clone https://github.com/brian-eaton/CAM.git eaton-se-dev
# cd eaton-se-dev
# git checkout se_dev
# ./manage_externals/checkout_externals
#
# Execute this script:
#
# source cecille_81lev.sh
#
set src="eaton-se-dev"          #Brian's latest branch with Peter's new code and merged with cam6_2_031
set res="ne30pg3_ne30pg3_mg17"  #1 degree cslam
#set cset="HIST_CAM60%WCSC_CLM50%BGC-CROP_CICE%PRES_DOCN%DOM_MOSART_CISM2%NOEVOLVE_SWAV" #I am getting build errors with this?
set cset="FWscHIST"
set nlev="81"
set walltime="00:45:00"
set pecount="5400" #scalability limit (SE gets more efficient with increased core counts)
#set pecount="2700"
#set pecount="1800"
#set pecount="900"
set stopoption="nmonths"
set steps="4"
set jobq="regular"
set caze=${cset}_${src}_nlev${nlev}_${res}_${pecount}
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset  --res $res  --q $jobq --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
if ($pecount == "5400") then
  ./xmlchange CAM_CONFIG_OPTS=' -pcols 9' --append
endif
./xmlchange RUN_STARTDATE=1986-06-01
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange CAM_CONFIG_OPTS="-phys cam6 -age_of_air_trcs -chem waccm_sc_mam4 -cppdefs -Dwaccm_debug -nlev "$nlev""
#./xmlchange TIMER_LEVEL=10
./xmlchange REST_N=1
./xmlchange REST_OPTION=nmonths

./case.setup
if ($nlev == "81") then
  echo "ncdata = '/glade/p/cesm/amwg_dev/juliob/FWsc_ne30pg3_81L_DANMARSH_GRID_Top_80km.nc'" >> user_nl_cam
endif
echo "qbo_use_forcing = .false."                 >> user_nl_cam
echo "se_statefreq       = 256"                  >> user_nl_cam
echo "check_finidat_year_consistency = .false."  >> user_nl_clm
#
# I/O
#
echo "interpolate_output = .true.,.true.,.true." >> user_nl_cam #output on FV grid
echo "interpolate_nlat = 192,192,192"            >> user_nl_cam #output on FV grid
echo "interpolate_nlon = 288,288,288"            >> user_nl_cam #output on FV grid

echo "empty_htapes       = .true."               >> user_nl_cam
echo "fexcl1 = ''"  >> user_nl_cam #otherwise I get errors for FLDLST: TTPXMLC in fexcl(34, 1) not found
echo "fincl1 = 'ABS_dPSdt','FU','FV','U','V','T','OMEGA500','OMEGA850','PSL','PS'" >> user_nl_cam

echo "inithist = 'MONTHLY'" #just for spin-up

#
# check with WACCM group on these values
#
echo "tau_0_ubc=.true."                          >> user_nl_cam
#echo "effgw_beres_dp         = 0.80D0"   >> user_nl_cam  #70 layer CSLAM best with 0.325 and 110 level CSLAM 0.70
#echo "frontgfc               = 2.7D-15"  >> user_nl_cam  #?
#echo "taubgnd                = 2.5D-3"   >> user_nl_cam  #?
#
# Some of Peter's stability knobs
#
echo "se_nu_top=5.0E5      " >> user_nl_cam
echo "se_molecular_diff = 0" >> user_nl_cam

#echo "se_nu_top=5.0E5      " >> user_nl_cam
#echo "se_molecular_diff = 5.0E3" >> user_nl_cam
#
# default files not on CAM trunk yet
#
echo "fsurdat = '/glade/work/aherring/grids/uniform-res/ne30np4.pg3/clm_surfdata_5_0/surfdata_ne30np4.pg3_hist_78pfts_CMIP6_simyr1850_c200426.nc'">>user_nl_clm
echo "flanduse_timeseries = '/glade/scratch/aherring/ctsm_release-clm5.0.30/tools/mksurfdata_map/cam-se/landuse.timeseries_ne30np4.pg3_hist_78pfts_CMIP6_simyr1850-2015_c200426.nc'">>user_nl_clm
#
# Source code modifications from Cecille (otherwise model will crash in chemistry code at start-up):
#
#  chem_init: do not know how to set water vapor upper boundary when model top is 
#  near mesopause
#
cp /glade/p/cesmdata/cseg/runs/cesm2_0/f.e21.FWscHIST_BCG.f09_f09_mg17_92L_80kmTop_bugfix.001/SourceMods/src.cam/chemistry.F90 SourceMods/src.cam/
cp /glade/p/cesmdata/cseg/runs/cesm2_0/f.e21.FWscHIST_BCG.f09_f09_mg17_92L_80kmTop_bugfix.001/SourceMods/src.cam/mo_tgcm_ubc.F90 SourceMods/src.cam/ 


qcmd -- ./case.build
./case.submit

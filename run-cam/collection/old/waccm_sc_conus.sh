#!/bin/tcsh
#setenv PBS_ACCOUNT "P03010039"
setenv PBS_ACCOUNT "P19010000" #ACOM account
#setenv PBS_ACCOUNT NACM0003
# P03010039
# P93300042
# P03010083
# P93300075
# P05010048
# P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="cam_pel_development"
#
# run with CSLAM or without
#
set res="ne0CONUSne30x8_ne0CONUSne30x8_mt12"
#
# DO NOT MODIFY BELOW THIS LINE
#
set cset="FWsc2000climo"

set walltime="00:45:00"
set pecount="1800"
set NTHRDS="1"
set stopoption="ndays"
set steps="1"

set caze=${src}_${cset}_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q regular --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
  ./xmlchange EPS_AAREA=9.0e-6
./xmlchange DOUT_S=FALSE
#./xmlchange CASEROOT=/glade/scratch/$USER/$caze
#./xmlchange EXEROOT=/glade/scratch/$USER/$caze/bld
#./xmlchange RUNDIR=/glade/scratch/$USER/$caze/run

#./xmlchange --append CAM_CONFIG_OPTS="-cppdefs -Dwaccm_debug"
#./xmlchange CAM_CONFIG_OPTS="-phys cam6 -age_of_air_trcs -chem waccm_sc_mam4 -usr_mech_infile /glade/work/mmills/case/f.e21.FWsc2000climo.ne30pg3_ne30pg3_mg17.c20190831/chem_mech.in -cppdefs -Dwaccm_debug"
./xmlchange NTHRDS=$NTHRDS
./xmlchange TIMER_LEVEL=10
./xmlchange REST_N=1
./xmlchange REST_OPTION=ndays
#
# point to M.Mills case
#
#./xmlchange RUN_TYPE=branch
#./xmlchange RUN_REFCASE=e21.FWsc2000climo.ne30pg3_ne30pg3_mg17.c20190903b
#./xmlchange RUN_REFDATE=0030-01-01-00000
#
# copy restart files
#

./case.setup
#cp /glade/scratch/mmills/f.e21.FWsc2000climo.ne30pg3_ne30pg3_mg17.c20190903b/run/*.r*.0030-01-01-00000.nc run/
echo "inithist = 'DAILY'" >> user_nl_cam
echo "se_statefreq       = 1"        >> user_nl_cam
#echo "                    'PTTEND','FT','OMEGAT','CLDTOT','TMQ','ABS_dPSdt','CSLAM_gamma','FU','FV','U','V','T','OMEGA500','OMEGA850'  ">> user_nl_cam

echo "nhtfrq = -1,0,0,0,0,0,0,0,0"        >> user_nl_cam
echo "interpolate_output = .true.,.false.,.false.,.false.,.false."        >> user_nl_cam
echo "empty_htapes       = .true."        >> user_nl_cam
echo "fincl1 = 'PS','PSDRY','PSL','OMEGA','OMEGA500','OMEGA850','PRECL','PRECC','PTTEND','FT','OMEGAT','CLDTOT','TMQ','ABS_dPSdt','FU','FV','U','V','T','OMEGA500','OMEGA850'"        >> user_nl_cam
echo "fincl2 = 'PS'"        >> user_nl_cam
echo "fincl3 = 'PS'"        >> user_nl_cam
echo "fincl4 = 'PS'"        >> user_nl_cam
echo "fincl5 = 'PS'"        >> user_nl_cam
echo "fincl6 = 'PS'"        >> user_nl_cam
echo "fincl7 = 'PS'"        >> user_nl_cam
echo "fincl8 = 'PS'"        >> user_nl_cam
echo "fincl9 = 'PS'"        >> user_nl_cam


#echo "ncdata = '/glade/scratch/pel/CAM_FHS94_ne0CONUSne30x8_ne0CONUSne30x8_mg17_1800_NTHRDS1_1ndays/run/CAM_FHS94_ne0CONUSne30x8_ne0CONUSne30x8_mg17_1800_NTHRDS1_1ndays.cam.i.0001-02-01-00000.nc'" >> user_nl_cam
echo "ncdata = '/glade/p/cgd/amp/pel/inic/waccm.CONUS.i.nc'" >> user_nl_cam
echo "                        " >> user_nl_cam
echo "effgw_beres_dp = 0.4D0"   >> user_nl_cam
echo "frontgfc = 3.0D-15"       >> user_nl_cam
echo "taubgnd = 2.0D-3"         >> user_nl_cam
echo "                        " >> user_nl_cam
echo "dust_emis_fact = 0.7D0"                       >> user_nl_cam
echo "lght_no_prd_factor = 1.80D0"                  >> user_nl_cam
echo "                                            " >> user_nl_cam
#echo "ncdata = '/glade/scratch/mmills/f.e21.FWsc2000climo.ne30pg3_ne30pg3_mg17.c20190903b/run/f.e21.FWsc2000climo.ne30pg3_ne30pg3_mg17.c20190903b.cam.i.0030-01-01-00000.nc'" >> user_nl_cam
#echo "ncdata  = '/glade/p/cesmdata/cseg/inputdata/cesm2_init/f.e21.FW2000climo.ne30pg3_ne30pg3_mg17.cam_trunk.outputFV1deg.c190411/0017-01-01/f.e21.FW2000climo.ne30pg3_ne30pg3_mg17.cam_trunk.outputFV1deg.c190411_SOAG.cam.i.0017-01-01-00000_c190606.nc'" >> user_nl_cam
echo "                                            " >> user_nl_cam
echo "qbo_use_forcing = .false."                    >> user_nl_cam
echo "                                            " >> user_nl_cam
#echo "srf_emis_specifier		= 'bc_a4 ->  /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_bc_a4_anthro_surf#ace_2000climo_0.9x1.25_c20170608.nc',"                       >> user_nl_cam
#echo "        'bc_a4 ->  /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_bc_a4_bb_surface_2000climo_0.9x1.25_c2017032#2.nc',"        >> user_nl_cam
#echo "        'DMS ->    /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_DMS_bb_surface_2000climo_0.9x1.25_c20170322.#nc'," >> user_nl_cam
#echo "        'DMS ->    /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_DMS_other_surface_2000climo_0.9x1.25_c201703#22.nc'," >> user_nl_cam
#echo "        'num_a1 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_so4_a1_bb_surface_2000climo_0.9x1.25_c20#170322.nc'," >> user_nl_cam
#echo "        'num_a1 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_so4_a1_anthro-ag-ship_surface_2000climo_#0.9x1.25_c20170616.nc'," >> user_nl_cam
#echo "        'num_a2 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_so4_a2_anthro-res_surface_2000climo_0.9x#1.25_c20170616.nc'," >> user_nl_cam
#echo "        'num_a4 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_bc_a4_bb_surface_2000climo_0.9x1.25_c201#70322.nc'," >> user_nl_cam
#echo "        'num_a4 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_bc_a4_anthro_surface_2000climo_0.9x1.25_#c20170608.nc'," >> user_nl_cam
#echo "        'num_a4 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_pom_a4_anthro_surface_2000climo_0.9x1.25#_c20170608.nc'," >> user_nl_cam
#echo "        'num_a4 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_pom_a4_bb_surface_2000climo_0.9x1.25_c20#170509.nc'," >> user_nl_cam
#echo "        'pom_a4 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_pom_a4_anthro_surface_2000climo_0.9x1.25_c20#170608.nc'," >> user_nl_cam
#echo "        'pom_a4 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_pom_a4_bb_surface_2000climo_0.9x1.25_c201703#22.nc'," >> user_nl_cam
#echo "        'SO2 ->    /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_SO2_anthro-ag-ship-res_surface_2000climo_0.9#x1.25_c20170616.nc'," >> user_nl_cam
#echo "        'SO2 ->    /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_SO2_anthro-ene_surface_2000climo_0.9x1.25_c2#0170616.nc'," >> user_nl_cam
#echo "        'SO2 ->    /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_SO2_bb_surface_2000climo_0.9x1.25_c20170322.#nc'," >> user_nl_cam
#echo "        'so4_a1 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_so4_a1_anthro-ag-ship_surface_2000climo_0.9x#1.25_c20170616.nc'," >> user_nl_cam
#echo "        'so4_a1 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_so4_a1_bb_surface_2000climo_0.9x1.25_c201703#22.nc'," >> user_nl_cam
#echo "        'so4_a2 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_so4_a2_anthro-res_surface_2000climo_0.9x1.25#_c20170616.nc'," >> user_nl_cam
#echo "        'SOAG ->   /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_SOAGx1.5_anthro_surface_2000climo_0.9x1.25_c#20170608.nc'," >> user_nl_cam
#echo "        'SOAG ->   /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_SOAGx1.5_bb_surface_2000climo_0.9x1.25_c2017#0322.nc'," >> user_nl_cam
#echo "        'SOAG ->   /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_SOAGx1.5_biogenic_surface_2000climo_0.9x1.25#_c20170322.nc'," >> user_nl_cam
#echo "        'E90 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions_E90global_surface_1750-2100_0.9x1.25_c20170322.nc'" >#> user_nl_cam
##./xmlchange RUN_REFCASE=opt-se-cslam-new_FWsc2000climo_ne30pg3_ne30pg3_mg17_2700_NTHRDS1_12nmonths
##./xmlchange RUN_REFDATE=0001-12-30
##./xmlchange RUN_STARTDATE=0001-12-30
#cp /glade/scratch/pel/opt-se-cslam-new_FWsc2000climo_ne30pg3_ne30pg3_mg17_2700_NTHRDS1_12nmonths/run/*.r*.0001-12-30-00000.nc run/


qcmd -- ./case.build
./case.submit

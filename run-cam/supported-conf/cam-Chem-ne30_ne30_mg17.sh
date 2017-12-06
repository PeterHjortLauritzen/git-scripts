#!/bin/tcsh
setenv src "trunk"
setenv caze FCHIST_ne30mg17_`date '+%y%m%d'`
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset FCHIST --res ne30_ne30_mg17  --q regular --walltime 01:00:00 --pecount 1800  --project P03010039 --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=nmonths,STOP_N=1
./xmlchange DOUT_S=FALSE
./xmlchange TIMER_LEVEL=10
./case.setup
#
# special namelist settings
#
echo "ncdata = '/glade/p/acd/tilmes/inputdata/init/cesm2/SE/f.e20.FCHIST.ne30_ne30.chem01_cam5_4_152.001.cam.i.2010-02-02-00000.nc'">>user_nl_cam
echo "flbc_file          	= '/glade/p/acd/dkin/inputdata/atm/waccm4/lbc/LBC_1750-2017ex_CMIP6_0p5degLat_c170601.nc'">>user_nl_cam
echo "ext_frc_specifier = 'bc_a4  -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_bc_a4_aircraft_vertical_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'so4_a1 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_so4_a1_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',">>user_nl_cam
echo " 'so4_a1 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_so4_a1_anthro-ene_vertical_1750-2015_0.9x1.25_c20170616.nc',">>user_nl_cam
echo " 'so4_a2 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_so4_a2_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',">>user_nl_cam
echo " 'num_a1 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_num_so4_a1_anthro-ene_vertical_1750-2015_0.9x1.25_c20170616.nc',">>user_nl_cam
echo " 'num_a1 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_a1_so4_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',">>user_nl_cam
echo " 'num_a2 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_num_a2_so4_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',">>user_nl_cam
echo " 'num_a4 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_num_bc_a4_aircraft_vertical_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'NO2	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_NO2_aircraft_vertical_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'SO2	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/stratvolc/VolcanEESMv2.10_SO2_1850-2016_1deg_c170920.nc',">>user_nl_cam
echo " 'SO2	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_SO2_aircraft_vertical_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'SO2	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions-cmip6_SO2_contvolcano_vertical_850-5000_0.9x1.25_c20170724.nc',">>user_nl_cam
echo " 'SO2	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_SO2_anthro-ene_vertical_1750-2015_0.9x1.25_c20170616.nc'">>user_nl_cam
echo "srf_emis_specifier = 'DMS  	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_DMS_other_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'DMS  	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_DMS_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'SO2  	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_SO2_anthro-ag-ship-res_surface_1750-2015_0.9x1.25_c20170616.nc',">>user_nl_cam
echo " 'SO2  	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_SO2_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'so4_a1   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_so4_a1_anthro-ag-ship_surface_1750-2015_0.9x1.25_c20170616.nc',">>user_nl_cam
echo " 'so4_a1   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_so4_a1_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'so4_a2   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_so4_a2_anthro-res_surface_1750-2015_0.9x1.25_c20170616.nc',">>user_nl_cam
echo " 'num_a1   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_num_so4_a1_anthro-ag-ship_surface_1750-2015_0.9x1.25_c20170616.nc',">>user_nl_cam
echo " 'num_a1   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_num_so4_a1_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'num_a2   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_num_so4_a2_anthro-res_surface_1750-2015_0.9x1.25_c20170616.nc',">>user_nl_cam
echo " 'bc_a4	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_bc_a4_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'bc_a4	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_bc_a4_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'pom_a4   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_pom_a4_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'pom_a4   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_pom_a4_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'num_a4   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_num_pom_a4_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'num_a4   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_num_pom_a4_bb_surface_1750-2015_0.9x1.25_c20170509.nc',">>user_nl_cam
echo " 'num_a4   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_num_bc_a4_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'num_a4   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_num_bc_a4_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'NO   	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_NO_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'NO   	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_NO_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'NO   	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_NO_other_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'CO   	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CO_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'CO   	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CO_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'CO   	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CO_other_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'BENZENE  -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_BENZENE_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'BENZENE  -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_BENZENE_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'BIGALK   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_BIGALK_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'BIGALK   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_BIGALK_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'BIGENE   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_BIGENE_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'BIGENE   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_BIGENE_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'C2H2 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C2H2_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'C2H2 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C2H2_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'C2H4 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C2H4_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'C2H4 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C2H4_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'C2H4 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C2H4_other_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'C2H5OH   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C2H5OH_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'C2H5OH   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C2H5OH_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'C2H6 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C2H6_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'C2H6 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C2H6_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'C2H6 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C2H6_other_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'C3H6 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C3H6_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'C3H6 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C3H6_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'C3H6 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C3H6_other_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'C3H8 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C3H8_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'C3H8 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C3H8_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'C3H8 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_C3H8_other_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'CH2O 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CH2O_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'CH2O 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CH2O_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'CH3CHO   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CH3CHO_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'CH3CHO   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CH3CHO_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'CH3CN	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CH3CN_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'CH3CN	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CH3CN_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'CH3COCH3 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CH3COCH3_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'CH3COCH3 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CH3COCH3_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'CH3COCHO -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CH3COCHO_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'CH3COOH  -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CH3COOH_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'CH3COOH  -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CH3COOH_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'CH3OH	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CH3OH_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'CH3OH	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_CH3OH_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'GLYALD   -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_GLYALD_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'HCN  	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_HCN_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'HCN  	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_HCN_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'HCOOH	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_HCOOH_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'HCOOH	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_HCOOH_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo "'MEK  	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_MEK_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'MTERP	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_MTERP_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'NH3  	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_NH3_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'NH3  	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_NH3_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'NH3  	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_NH3_other_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'TOLUENE  -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_TOLUENE_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'TOLUENE  -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_TOLUENE_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'XYLENES  -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_XYLENES_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'XYLENES  -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_XYLENES_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'IVOC 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_IVOC_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'IVOC 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_IVOC_bb_surface_1750-2015_0.9x1.25_c20170322.nc',">>user_nl_cam
echo " 'SVOC 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_SVOC_anthro_surface_1750-2015_0.9x1.25_c20170608.nc',">>user_nl_cam
echo " 'SVOC 	-> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015v2/emissions-cmip6_SVOC_bb_surface_1750-2015_0.9x1.25_c20170322.nc'">>user_nl_cam
echo "do_beljaars = .true.">>user_nl_cam
./case.build
./case.submit



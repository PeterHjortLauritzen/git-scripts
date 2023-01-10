#!/bin/tcsh
#setenv PBS_ACCOUNT "P03010039"
#setenv PBS_ACCOUNT "P19010000" #ACOM account
#setenv PBS_ACCOUNT "P93300607" #ACOM account
setenv PBS_ACCOUNT "P93300642"
# P03010039
# P93300042
# P03010083
# P93300075
# P05010048
# P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#

set src="cam6_3_025_CESM2.2"
#set src="se_dev"
#
# run with CSLAM or without
#
set res="ne30pg3_ne30pg3_mg17" #cslam
#set res="ne30_ne30_mg17" 
#set res="f09_f09_mg17"   
#set res="ne0CONUSne30x8_ne0CONUSne30x8_mt12"  

#set nlev="110"
#set steps="48"
#set pecount="5400"


#set nlev="70"
#set steps="72"
#set pecount="5400"

set nlev="70"
set steps="1"
set stopoption="nsteps"
set pecount="1800"

set cset="FWsc2000climo"
#set cset="FW2000climo"
#set walltime="00:10:00"

#set stopoption="ndays"


#set stopoption="nsteps"
#set steps="1"
#set jobq="regular"
#set jobq="economy"
set jobq="premium"

set walltime="00:15:00"
set pecount="450"

#set stopoption="nmonths"
#set steps="120"
#set jobq="economy"

set NTHRDS="1"

set caze=richter_nlev${nlev}_${src}_${cset}_${res}_${pecount} #_NTHRDS${NTHRDS}_${steps}${stopoption}
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q $jobq --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
#./xmlchange --append CAM_CONFIG_OPTS="-cppdefs -Dwaccm_debug"
#./xmlchange CAM_CONFIG_OPTS="-phys cam6 -age_of_air_trcs -chem waccm_sc_mam4 -usr_mech_infile /glade/work/mmills/case/f.e21.FWsc2000climo.ne30pg3_ne30pg3_mg17.c20190831/chem_mech.in -cppdefs -Dwaccm_debug -nlev "$nlev""

#./xmlchange CAM_CONFIG_OPTS="-phys cam6 -age_of_air_trcs -chem waccm_sc_mam4 -cppdefs -Dwaccm_debug -nlev "$nlev""
#
./xmlquery CAM_CONFIG_OPTS
./xmlchange NTHRDS=$NTHRDS
./xmlchange TIMER_LEVEL=10
./xmlchange REST_N=4
./xmlchange REST_OPTION=nmonths
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
#echo "switching compiler from intel/19.0.2 to intel/18.0.5"
#sed -i 's/19.0.2/18.0.5/g' env_mach_specific.xml

#cp /glade/scratch/mmills/f.e21.FWsc2000climo.ne30pg3_ne30pg3_mg17.c20190903b/run/*.r*.0030-01-01-00000.nc run/

#xecho "analytic_ic_type = 'us_standard_atmosphere'" >> user_nl_cam
#xecho "se_nsplit = 6"  >> user_nl_cam
#xecho "se_rsplit = 5" >> user_nl_cam

#
if ($res == "f09_f09_mg17") then
  if ($nlev == "110") then
    echo "ncdata = '/glade/scratch/tilmes/archive/f.e21.FWscHIST_BGC.f09_f09_mg17.cesm2.1-exp012.110L.effgw_0800/atm/hist/f.e21.FWscHIST_BGC.f09_f09_mg17.cesm2.1-exp012.110L.effgw_0800.cam.i.2008-01-01-00000.nc'" >> user_nl_cam   
  endif


else
  echo "inithist = 'YEARLY'" >> user_nl_cam
  echo "se_statefreq       = 256"        >> user_nl_cam
  #echo "                    'PTTEND','FT','OMEGAT','CLDTOT','TMQ','ABS_dPSdt','CSLAM_gamma','FU','FV','U','V','T','OMEGA500','OMEGA850'  ">> user_nl_cam
#  echo "se_rayk0= 10" >> user_nl_cam
#  echo "se_raytau0= 0.002" >> user_nl_cam
#  echo "se_raykrange= 5" >> user_nl_cam


  echo "interpolate_output = .true.,.true.,.true."    >> user_nl_cam
  echo "interpolate_nlat = 192,192,192"               >> user_nl_cam
  echo "interpolate_nlon = 288,288,288"               >> user_nl_cam
endif

echo "                                            " >> user_nl_cam
echo "qbo_use_forcing = .false."                    >> user_nl_cam
echo "                                            " >> user_nl_cam

#if ($res == "ne30pg3_ne30pg3_mg17") then
#echo "ext_frc_specifier              = 'num_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_num_so4_a1_anthro-ene_vertical_mol_2000climo_ne30xne30_c20200224.nc'," >> user_n#l_cam
#echo "         'num_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions-cmip6_num_a1_so4_contvolcano_vertical_850-5000_ne30_ne30_c20200125.nc'," >> user_nl_cam
#echo "         'num_a2 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions-cmip6_num_a2_so4_contvolcano_vertical_850-5000_ne30_ne30_c20200125.nc'," >> user_nl_cam
#echo "         'SO2 ->    /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions-cmip6_SO2_contvolcano_vertical_850-5000_ne30_ne30_c20200125.nc'," >> user_nl_cam
#echo "         'so4_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_so4_a1_anthro-ene_vertical_mol_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "         'so4_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions-cmip6_so4_a1_contvolcano_vertical_850-5000_ne30_ne30_c20200125.nc'," >> user_nl_cam
#echo "         'so4_a2 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions-cmip6_so4_a2_contvolcano_vertical_850-5000_ne30_ne30_c20200125.nc'" >> user_nl_cam
#echo "                                            " >> user_nl_cam
#echo "srf_emis_specifier		= 'bc_a4 ->  /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_bc_a4_anthro_surface_2000climo_ne30xne30_c20200224.nc',"                      # >> user_nl_cam
#echo "        'bc_a4 ->  /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_bc_a4_bb_surface_2000climo_ne30xne30_c20200224.nc',"        >> user_nl_cam
#echo "        'DMS ->    /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_DMS_bb_surface_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'DMS ->    /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_DMS_other_surface_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'num_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_num_so4_a1_bb_surface_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'num_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_num_so4_a1_anthro-ag-ship_surface_mol_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'num_a2 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_num_so4_a2_anthro-res_surface_mol_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'num_a4 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_num_bc_a4_bb_surface_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'num_a4 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_num_bc_a4_anthro_surface_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'num_a4 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_num_pom_a4_anthro_surface_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'num_a4 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_num_pom_a4_bb_surface_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'pom_a4 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_pom_a4_anthro_surface_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'pom_a4 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_pom_a4_bb_surface_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'SO2 ->    /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_SO2_anthro-ag-ship-res_surface_mol_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'SO2 ->    /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_SO2_anthro-ene_surface_mol_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'SO2 ->    /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_SO2_bb_surface_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'so4_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_so4_a1_anthro-ag-ship_surface_mol_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'so4_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_so4_a1_bb_surface_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'so4_a2 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_so4_a2_anthro-res_surface_mol_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'SOAG ->   /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_SOAGx1.5_anthro_surface_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'SOAG ->   /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_SOAGx1.5_bb_surface_2000climo_ne30xne30_c20200224.nc'," >> user_nl_cam
#echo "        'SOAG ->   /glade/p/acom/acom-climate/cmip6inputs/historical_ne30pg3/emissions_2000climo/emissions-cmip6_SOAGx1.5_biogenic_surface_2000climo_ne30xne30_c20200224.nc'" >> user_nl_cam
#endif

#if ($res == "ne30_ne30_mg17") then
#echo "ext_frc_specifier              = 'num_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_num_so4_a1_anthro-ene_vertical_mol_175001-201412_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "         'num_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_num_a1_so4_contvolcano_vertical_850-5000_ne30_ne30_c20191206.nc'," >> user_nl_cam
#echo "         'num_a2 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_num_a2_so4_contvolcano_vertical_850-5000_ne30_ne30_c20191206.nc'," >> user_nl_cam
#echo "         'SO2 ->    /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_SO2_contvolcano_vertical_850-5000_ne30_ne30_c20191206.nc'," >> user_nl_cam
#echo "         'so4_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_so4_a1_anthro-ene_vertical_mol_175001-201412_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "         'so4_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_so4_a1_contvolcano_vertical_850-5000_ne30_ne30_c20191206.nc'," >> user_nl_cam
#echo "         'so4_a2 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_so4_a2_contvolcano_vertical_850-5000_ne30_ne30_c20191206.nc'" >> user_nl_cam
#echo "                                            " >> user_nl_cam
#echo "srf_emis_specifier		= 'bc_a4 ->  /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_bc_a4_anthro_surface_175001-201412_ne30_ne30_c20191230.nc',"  >> user_nl_cam
#echo "        'bc_a4 ->  /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_bc_a4_bb_surface_175001-201512_ne30_ne30_c20191230.nc',"        >> user_nl_cam
#echo "        'DMS ->    /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_DMS_bb_surface_175001-201512_ne30_ne30_c20200102.nc'," >> user_nl_cam                                        
#echo "        'DMS ->    /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_DMS_other_surface_1750_2015_ne30_ne30_c20200103.nc'," >> user_nl_cam
#echo "        'num_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_num_so4_a1_bb_surface_175001-201512_ne30_ne30_c20191231.nc'," >> user_nl_cam
#echo "        'num_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_num_so4_a1_anthro-ag-ship_surface_mol_175001-201412_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "        'num_a2 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_num_so4_a2_anthro-res_surface_mol_175001-201412_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "        'num_a4 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_num_bc_a4_bb_surface_175001-201512_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "        'num_a4 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_num_bc_a4_anthro_surface_175001-201412_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "        'num_a4 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_num_pom_a4_anthro_surface_175001-201412_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "        'num_a4 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_num_pom_a4_bb_surface_175001-201512_ne30_ne30_c20191231.nc'," >> user_nl_cam
#echo "        'pom_a4 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_pom_a4_anthro_surface_175001-201412_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "        'pom_a4 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_pom_a4_bb_surface_175001-201512_ne30_ne30_c20191231.nc'," >> user_nl_cam
#echo "        'SO2 ->    /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_SO2_anthro-ag-ship-res_surface_mol_175001-201412_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "        'SO2 ->    /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_SO2_anthro-ene_surface_mol_175001-201412_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "        'SO2 ->    /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_SO2_bb_surface_175001-201512_ne30_ne30_c20191231.nc'," >> user_nl_cam
#echo "        'so4_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_so4_a1_anthro-ag-ship_surface_mol_175001-201412_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "        'so4_a1 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_so4_a1_bb_surface_175001-201512_ne30_ne30_c20191231.nc'," >> user_nl_cam
#echo "        'so4_a2 -> /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_so4_a2_anthro-res_surface_mol_175001-201412_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "        'SOAG ->   /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_SOAGx1.5_anthro_surface_175001-201412_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "        'SOAG ->   /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_SOAGx1.5_anthro_surface_175001-201412_ne30_ne30_c20191230.nc'," >> user_nl_cam
#echo "        'SOAG ->   /glade/p/acom/acom-climate/cmip6inputs/historical_ne30/emissions-cmip6_SOAGx1.5_anthro_surface_175001-201412_ne30_ne30_c20191230.nc'" >> user_nl_cam
#endif
#echo "        'E90 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions_E90global_surface_1750-2100_0.9x1.25_c20170322.nc'" >> user_nl_cam
#./xmlchange RUN_REFCASE=opt-se-cslam-new_FWsc2000climo_ne30pg3_ne30pg3_mg17_2700_NTHRDS1_12nmonths
#./xmlchange RUN_REFDATE=0001-12-30
#./xmlchange RUN_STARTDATE=0001-12-30
#cp /glade/scratch/pel/opt-se-cslam-new_FWsc2000climo_ne30pg3_ne30pg3_mg17_2700_NTHRDS1_12nmonths/run/*.r*.0001-12-30-00000.nc run/




#./xmlchange RUN_REFCASE=f.e21.FW2000climo.ne30pg3_ne30pg3_mg17.cam_trunk.outputFV1deg.c190411,RUN_REFDATE=0017-01-01,GET_REFCASE=TRUE,RUN_TYPE=hybrid

#echo "use_init_interp = .true." >> user_nl_clm

qcmd -- ./case.build
./case.submit

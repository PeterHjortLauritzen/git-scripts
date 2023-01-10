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
set src="opt-se-cslam-new"
#
# run with CSLAM or without
#
set res="ne30pg3_ne30pg3_mg17" #cslam
#
# DO NOT MODIFY BELOW THIS LINE
#
set cset="FWsc2000climo"

set walltime="12:00:00"
set pecount="2700"
set NTHRDS="1"
set stopoption="nmonths"
set steps="12"

set caze=new_${src}_${cset}_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q regular --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
#./xmlchange CASEROOT=/glade/scratch/$USER/$caze
#./xmlchange EXEROOT=/glade/scratch/$USER/$caze/bld
#./xmlchange RUNDIR=/glade/scratch/$USER/$caze/run

./xmlchange CAM_CONFIG_OPTS="-phys cam6 -age_of_air_trcs -chem waccm_sc_mam4 -usr_mech_infile /glade/work/mmills/case/f.e21.FWsc2000climo.ne30pg3_ne30pg3_mg17.c20190831/chem_mech.in -cppdefs -Dwaccm_debug"
#./xmlchange --append CAM_CONFIG_OPTS="-cppdefs -Dwaccm_debug"
./xmlchange NTHRDS=$NTHRDS
./xmlchange TIMER_LEVEL=10
#
# point to M.Mills case
#
./xmlchange RUN_TYPE=branch
./xmlchange RUN_REFCASE=e21.FWsc2000climo.ne30pg3_ne30pg3_mg17.c20190903b
./xmlchange RUN_REFDATE=0030-01-01-00000
#
# copy restart files
#

./case.setup
cp /glade/scratch/mmills/f.e21.FWsc2000climo.ne30pg3_ne30pg3_mg17.c20190903b/run/*.r*.0030-01-01-00000.nc run/

echo "se_statefreq       = 256"        >> user_nl_cam
#echo "                    'PTTEND','FT','OMEGAT','CLDTOT','TMQ','ABS_dPSdt','CSLAM_gamma','FU','FV','U','V','T','OMEGA500','OMEGA850'  ">> user_nl_cam

echo "se_hypervis_subcycle           = 1"  >> user_nl_cam
#se_nsplit = 9" >> user_nl_cam
echo "                        " >> user_nl_cam
echo "effgw_beres_dp = 0.5D0"   >> user_nl_cam
echo "frontgfc = 3.0D-15"       >> user_nl_cam
echo "taubgnd = 2.5D-3"         >> user_nl_cam
echo "                        " >> user_nl_cam
echo "fexcl1 = 'BTAUN', 'BTAUS', 'BTAUE', 'BTAUW', 'BTAUNET', 'BUTEND1', 'BUTEND2', 'BUTEND3', 'BUTEND4', 'BUTEND5',">> user_nl_cam
echo " 'MAXQ0', 'HDEPTH', 'NETDT', 'TAUN', 'TAUS', 'TAUE', 'TAUW', 'TAUGWX', 'TAUGWY', 'UTEND1', 'UTEND2', 'UTEND3',">> user_nl_cam
echo " 'UTEND4', 'UTEND5', 'FRONTGF', 'FRONTGFA', 'EKGW', 'QNO', 'QRLNLTE', 'QRL_TOT', 'DUV', 'DVV', 'TTPXMLC'">> user_nl_cam
echo "  " >> user_nl_cam
echo "fincl1 = 'AOA1', 'AOA2', 'CH4', 'H2O', 'N2O', 'CFC11', 'CFC12', 'CFC11STAR', 'UTGWORO'," >> user_nl_cam
echo "         'VTGWORO', 'UTGWSPEC', 'VTGWSPEC', 'BUTGWSPEC', 'AODVISstdn', 'AODVISdn', 'KVH_CLUBB', 'KVH', 'TTENDICE',">> user_nl_cam
echo "         'QVTENDICE', 'QCTENDICE', 'NCTENDICE', 'FQTENDICE', 'MASS','PMID','PDELDRY','E90'">> user_nl_cam
echo "          "  >> user_nl_cam
echo "fincl2 = 'U:I','V:I','T:I','OMEGA:I','PMID:I','PS:I'" >> user_nl_cam
echo "   ">> user_nl_cam
echo "fincl3 = 'U:A','V:A','T:A','OMEGA:A','PMID:A','DTCOND:A','UTGWSPEC:A','UTGWORO:A','E90:A','BUTGWSPEC:A'">> user_nl_cam
echo "                                            " >> user_nl_cam
echo "nhtfrq = 0,-6,-24"                            >> user_nl_cam
echo "avgflag_pertape = 'A', 'I', 'A'"              >> user_nl_cam
echo "                                            " >> user_nl_cam
echo "interpolate_output = .true.,.true.,.true."    >> user_nl_cam
echo "interpolate_nlat = 192,192,192"               >> user_nl_cam
echo "interpolate_nlon = 288,288,288"               >> user_nl_cam
echo "                                            " >> user_nl_cam
echo "dust_emis_fact = 0.7D0"                       >> user_nl_cam
echo "lght_no_prd_factor = 1.80D0"                  >> user_nl_cam
echo "                                            " >> user_nl_cam
echo "ncdata  = '/glade/p/cesmdata/cseg/inputdata/cesm2_init/f.e21.FW2000climo.ne30pg3_ne30pg3_mg17.cam_trunk.outputFV1deg.c190411/0017-01-01/f.e21.FW2000climo.ne30pg3_ne30pg3_mg17.cam_trunk.outputFV1deg.c190411_SOAG.cam.i.0017-01-01-00000_c190606.nc'" >> user_nl_cam
echo "                                            " >> user_nl_cam
echo "qbo_use_forcing = .false."                    >> user_nl_cam
echo "                                            " >> user_nl_cam
echo "srf_emis_specifier		= 'bc_a4 ->  /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_bc_a4_anthro_surface_2000climo_0.9x1.25_c20170608.nc',"                       >> user_nl_cam
echo "        'bc_a4 ->  /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_bc_a4_bb_surface_2000climo_0.9x1.25_c20170322.nc',"        >> user_nl_cam
echo "        'DMS ->    /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_DMS_bb_surface_2000climo_0.9x1.25_c20170322.nc'," >> user_nl_cam
echo "        'DMS ->    /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_DMS_other_surface_2000climo_0.9x1.25_c20170322.nc'," >> user_nl_cam
echo "        'num_a1 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_so4_a1_bb_surface_2000climo_0.9x1.25_c20170322.nc'," >> user_nl_cam
echo "        'num_a1 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_so4_a1_anthro-ag-ship_surface_2000climo_0.9x1.25_c20170616.nc'," >> user_nl_cam
echo "        'num_a2 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_so4_a2_anthro-res_surface_2000climo_0.9x1.25_c20170616.nc'," >> user_nl_cam
echo "        'num_a4 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_bc_a4_bb_surface_2000climo_0.9x1.25_c20170322.nc'," >> user_nl_cam
echo "        'num_a4 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_bc_a4_anthro_surface_2000climo_0.9x1.25_c20170608.nc'," >> user_nl_cam
echo "        'num_a4 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_pom_a4_anthro_surface_2000climo_0.9x1.25_c20170608.nc'," >> user_nl_cam
echo "        'num_a4 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_num_pom_a4_bb_surface_2000climo_0.9x1.25_c20170509.nc'," >> user_nl_cam
echo "        'pom_a4 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_pom_a4_anthro_surface_2000climo_0.9x1.25_c20170608.nc'," >> user_nl_cam
echo "        'pom_a4 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_pom_a4_bb_surface_2000climo_0.9x1.25_c20170322.nc'," >> user_nl_cam
echo "        'SO2 ->    /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_SO2_anthro-ag-ship-res_surface_2000climo_0.9x1.25_c20170616.nc'," >> user_nl_cam
echo "        'SO2 ->    /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_SO2_anthro-ene_surface_2000climo_0.9x1.25_c20170616.nc'," >> user_nl_cam
echo "        'SO2 ->    /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_SO2_bb_surface_2000climo_0.9x1.25_c20170322.nc'," >> user_nl_cam
echo "        'so4_a1 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_so4_a1_anthro-ag-ship_surface_2000climo_0.9x1.25_c20170616.nc'," >> user_nl_cam
echo "        'so4_a1 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_so4_a1_bb_surface_2000climo_0.9x1.25_c20170322.nc'," >> user_nl_cam
echo "        'so4_a2 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_so4_a2_anthro-res_surface_2000climo_0.9x1.25_c20170616.nc'," >> user_nl_cam
echo "        'SOAG ->   /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_SOAGx1.5_anthro_surface_2000climo_0.9x1.25_c20170608.nc'," >> user_nl_cam
echo "        'SOAG ->   /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_SOAGx1.5_bb_surface_2000climo_0.9x1.25_c20170322.nc'," >> user_nl_cam
echo "        'SOAG ->   /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_2000climo/emissions-cmip6_SOAGx1.5_biogenic_surface_2000climo_0.9x1.25_c20170322.nc'," >> user_nl_cam
echo "        'E90 -> /glade/p/cesmdata/cseg/inputdata/atm/cam/chem/emis/CMIP6_emissions_1750_2015/emissions_E90global_surface_1750-2100_0.9x1.25_c20170322.nc'" >> user_nl_cam


qcmd -- ./case.build
./case.submit

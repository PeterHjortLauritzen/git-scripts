#!/bin/tcsh
#
# 11/14/2022
#
# This script is experimental!
#
# Steps:
#
# 1. git clone https://github.com/ESCOMP/CAM cam
# 2. cd cam
# 3. git checkout cam_development
# 4. ./manage_externals/checkout_externals
# 5. in ccs_config/modelgrid_aliases_nuopc.xml
#    remove CLM from the "not compset"
#    in the entry
#
#        "<model_grid alias="ne16pg3_ne16pg3_mg17" not_compset="_POP|_CLM">"
#
# 6. 
#
# NOTES:
#
# - setting PS analytically (US standard atmosphere) helps stability a lot
# - Rayleigh friction with 5 days time-scale hardly made a difference
# - gravity wave settings? done but not confirmed by Julio!
# - new topo file? done
# - try run with CLUBB extending to top and look at tendencies? does not run!
#
#
set short = "T"
set proj  = "P93300642"
#set proj "P03010039"
set src   = "/glade/u/home/$USER/src/cam_development/cime/scripts/"
set res   = "ne16pg3_ne16pg3_mg17"
#set res "ne16_ne16_mg17"
set comp  = "HIST_CAM60%WCCM_CLM50%SP_CICE%PRES_DOCN%DOM_MOSART_SGLC_SWAV_SESP"

if ($short == "T") then
  echo "Short run"
  set pes  = "450"
  set wall = "00:20:00"
else
  set pes  = "1536"
  set wall = "02:30:00"
endif
set drv = "nuopc"
set pw  = `pw`
#
# for nuopc
#
module load python/3.7.9
ncar_pylib

unset caze
if ($short == "T") then
  set caze = acom_fric_heat_test_${res}_${pes}_short
else
  set caze = acom_${res}_${pes}_long
#  set caze acom_maxDel4Del2_to_top_${res}_${pes}_long
#  set caze acom_CLUBB_to_top_${res}_${pes}_long
endif
$src/create_newcase --case /glade/scratch/$USER/$caze --compset $comp --res $res --driver $drv --walltime $wall --mach cheyenne --pecount $pes --project $proj --compiler intel --queue regular --run-unsupported

cd /glade/scratch/$USER/$caze 
#./xmlchange REST_N=12
#./xmlchange REST_OPTION=nmonths
./xmlchange NTHRDS=1
if ($short == "T") then
  ./xmlchange STOP_OPTION=ndays
  ./xmlchange STOP_N=1
echo "inithist = 'DAILY'" >> user_nl_cam
else
  ./xmlchange STOP_OPTION=nmonths
  ./xmlchange STOP_N=1
echo "inithist = 'MONTHLY'" >> user_nl_cam
endif


#./xmlchange CAM_CONFIG_OPTS="-phys cam6 -age_of_air_trcs -chem waccm_ma_mam4 -nlev 135 -analytic_ic"
#echo "analytic_ic_type = 'us_standard_atmosphere'" >> user_nl_cam
#echo "use_topo_file          =  .true."            >> user_nl_cam

./xmlchange CAM_CONFIG_OPTS="-phys cam6 -age_of_air_trcs -chem waccm_ma_mam4 -nlev 135 -cppdefs -Dwaccm_debug"
./xmlchange DOUT_S=FALSE
#
# only for spin-up
#


#
# initial condition spun-up fromo US standard atmosphere (u=v=0)
#
echo "ncdata='/glade/p/cgd/amp/pel/inic/acom_ne16pg3_ne16pg3_mg17_1536_long.cam.i.1980-01-01-00000.nc'" >> user_nl_cam
#/glade/p/cgd/amp/pel/inic/acom_ne16pg3_ne16pg3_mg17_1536_long.cam.i.1980-04-01-00000.nc
#echo "ncdata='/glade/work/nadavis/cesm_tools/FW2000climo_ne16np4_ne16np4_135L.nc'" >>user_nl_cam
#
# new topo file
#
echo "bnd_topo='/glade/p/cgd/amp/pel/topo/files/ne16pg3_gmted2010_modis_bedmachine_nc3000_Laplace0200_20221116.nc'" >>user_nl_cam
echo "drydep_srf_file='/glade/u/home/nadavis/input_data/atmsrf_ne16pg3_110920.nc'" >>user_nl_cam
echo "flbc_file              = '/glade/p/cesmdata/cseg/inputdata/atm/waccm/lb/LBC_17500116-20150116_CMIP6_0p5degLat_c180227.nc'" >>user_nl_cam
echo "flbc_list              = 'CCL4', 'CF2CLBR', 'CF3BR', 'CFC11', 'CFC113', 'CFC12', 'CH3BR', 'CH3CCL3', 'CH3CL', 'CH4',"      >>user_nl_cam
echo "         'CO2', 'H2', 'HCFC22', 'N2O', 'CFC114', 'CFC115', 'HCFC141B', 'HCFC142B', 'H2402', 'OCS', 'SF6', 'CFC11eq'"       >>user_nl_cam

echo "interpolate_output = .true.,.false.,.true." >>user_nl_cam
echo "interpolate_nlat = 192" >>user_nl_cam
echo "interpolate_nlon = 288" >>user_nl_cam

echo "empty_htapes=.true." >>user_nl_cam

echo "fincl1 = 'U','V','Q','T','PSL','OMEGA','PS','PRECT','OMEGA500','OMEGA850',        " >>user_nl_cam
echo "         'UTGWORO','VTGWORO','UTEND_TOT','VTEND_TOT','UTEND_CLUBB','VTEND_CLUBB'," >>user_nl_cam
echo "         'UTEND_PHYSTOT','VTEND_PHYSTOT'," >>user_nl_cam
echo "         'UTEND_VDIFF','VTEND_VDIFF','UTEND_GWDTOT','VTEND_GWDTOT'," >>user_nl_cam
echo "         'UTEND_LUNART','VTEND_LUNART','UTEND_CORE','VTEND_CORE'," >>user_nl_cam
echo "         'OMEGA_COURANT'" >>user_nl_cam
echo "fincl3 = 'U','V','Q','T','PSL','OMEGA','PS','PRECT','OMEGA500','OMEGA850'," >>user_nl_cam
echo "         'UTGWORO','VTGWORO','UTEND_TOT','VTEND_TOT','UTEND_CLUBB','VTEND_CLUBB'," >>user_nl_cam
echo "         'UTEND_PHYSTOT','VTEND_PHYSTOT'," >>user_nl_cam
echo "         'UTEND_VDIFF','VTEND_VDIFF','UTEND_GWDTOT','VTEND_GWDTOT'," >>user_nl_cam
echo "         'UTEND_LUNART','VTEND_LUNART','UTEND_CORE','VTEND_CORE'," >>user_nl_cam
echo "         'OMEGA_COURANT'" >>user_nl_cam

echo "avgflag_pertape    = 'I','A','A'"             >>user_nl_cam
if ($short == "T") then
  echo "nhtfrq             = -1,0,-1"                 >>user_nl_cam
else
  echo "nhtfrq             = 0,0,-24"                  >>user_nl_cam
endif
#echo "mfilt              =  1,1,48"                >>user_nl_cam

echo "qbo_use_forcing              = .false."       >>user_nl_cam

#echo "se_sponge_del4_lev=10"                        >>user_nl_cam
#echo "se_sponge_del4_nu_div_fac=5"                 >>user_nl_cam
#echo "se_sponge_del4_nu_fac=5"                     >>user_nl_cam

echo "use_gw_rdg_beta = .true."                    >>user_nl_cam #was false
echo "use_gw_convect_dp = .true."                  >>user_nl_cam #was false
#echo "!history file error if not true (cant fexcl)" >>user_nl_cam
#echo "!just set effgw_cm to zero"                   >>user_nl_cam
echo "use_gw_front = .true."                        >>user_nl_cam
echo "effgw_beres_dp         = 0.7D0"               >>user_nl_cam #was 0
echo "gw_qbo_hdepth_scaling  = 0.25D0"              >>user_nl_cam #was 1
echo "effgw_cm               = 1.0D0"               >>user_nl_cam #was 0
echo "effgw_rdg_beta         = 1.0D0"               >>user_nl_cam #was 0
echo "gw_top_taper = .true."                        >>user_nl_cam

#
# CLUBB active all the way to model top
#
#echo "trop_cloud_top_press = 0.0007D0"              >>user_nl_cam

#echo "se_nu_top=1e5"                                >>user_nl_cam
#echo "se_nsplit=10"                                 >>user_nl_cam
#echo "se_rsplit=1"                                  >>user_nl_cam
#echo "se_qsplit=1"                                  >>user_nl_cam


echo "se_nsplit=4"                                  >>user_nl_cam
echo "se_rsplit=3"                                  >>user_nl_cam
echo "se_qsplit=1"                                  >>user_nl_cam
echo "se_hypervis_subcycle   =  3"                  >>user_nl_cam
echo "se_hypervis_subcycle_q =  1"                  >>user_nl_cam
echo "se_sponge_del4_lev = 3"                       >>user_nl_cam
echo "se_nu_top=1e6"                                >>user_nl_cam
#
# extra sponge setting
#
#echo "se_sponge_del4_lev = 3"                       >>user_nl_cam
#echo "se_nu_top=4e6"                                >>user_nl_cam
#echo "se_sponge_del4_nu_fac     =  10.0"            >>user_nl_cam
#echo "se_sponge_del4_nu_div_fac =  10.0"            >>user_nl_cam


echo "nlte_limit_co2=.true."                        >>user_nl_cam
#
# CLM namelist
#
echo "fsurdat = '/glade/u/home/nadavis/input_data/surfdata_ne16pg3_SSP5-8.5_78pfts_CMIP6_simyr2000_c220718.nc'" >>user_nl_clm
echo "flanduse_timeseries = '/glade/u/home/nadavis/input_data/landuse.timeseries_ne16pg3_SSP5-8.5_78pfts_CMIP6_simyr2000-2100_c220718.nc'">>user_nl_clm
echo "use_init_interp = .true.">>user_nl_clm
#
# after running model once add
#
#    finidat = 'init_generated_files/finidat_interp_dest.nc'
#
# so that startup is faster (and remove "use_init_interp=.true.")
#

if ($short == "T") then
  echo "se_statefreq       = 1"          >>user_nl_cam
else
  echo "se_statefreq       = 144"        >>user_nl_cam
endif

./case.setup
#
# Source mods for Courant number mods
#
#ln -s $pw/ACOM-ne16pg3/src.cam/*.F90 SourceMods/src.cam/
qcmd -- ./case.build
#./case.submit

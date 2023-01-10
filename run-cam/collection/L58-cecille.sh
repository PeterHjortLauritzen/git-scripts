#!/bin/tcsh
#
# 8/18/2022
#
# This script is experimental trying to replicate Cecile's setup documented here:
# 
# https://github.com/NCAR/amwg_dev/blob/f.cesm3_cam058_mom_e.FWscHIST.ne30_L58.024
#
setenv short "T" # "T" for short test run and "F" for long run
unset proj
setenv proj "P93300642"
unset src
#
# Cecile's source code directory
# 
# Her setup is here: /glade/p/cesmdata/cseg/runs/cesm2_0/f.cesm3_cam058_mom_e.FWscHIST.ne30_L58.024
#
setenv src "/glade/work/hannay/cesm_tags/cesm3_cam6_3_058_MOM_e/"

unset res
#
# SE-CSLAM or SE
#
setenv res "ne30pg3_ne30pg3_mg17"
#setenv res "ne30_ne30_mg17"
unset comp
#
# Compset
#
setenv comp "FWscHIST"
#
# Set WALLCLOCL, queue and pes
#
unset wall
unset pes
if ($short == "T") then
  echo "Short run"
  setenv pes "450"
  setenv wall "00:20:00"
  setenv queue "premium"
else
  setenv pes "1800"
  setenv wall "02:30:00"
  setenv queue "regular"
endif
unset drv
setenv drv "nuopc"
#
# for nuopc
#
module load python/3.7.9
ncar_pylib
#
# set your case name
#
unset caze
if ($short == "T") then
  setenv caze cecille_setup_${res}_${pes}_short
else
  setenv caze cecille_steup_${res}_${pes}_long
endif
#
#
#
$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $comp --res $res --driver $drv --walltime $wall --mach cheyenne --pecount $pes --project $proj --compiler intel --queue $queue --run-unsupported

cd /glade/scratch/$USER/$caze 
#./xmlchange REST_N=12
#./xmlchange REST_OPTION=nmonths
./xmlchange NTHRDS=1
if ($short == "T") then
  ./xmlchange STOP_OPTION=ndays
  ./xmlchange STOP_N=1
else
  ./xmlchange STOP_OPTION=ndays
  ./xmlchange STOP_N=60
endif
#
# Important changes to setup
#
./xmlchange --append CAM_CONFIG_OPTS="-phys cam_dev -microphys mg2 -chem waccm_sc_mam4 -nlev 58"
./xmlchange RUN_STARTDATE=1979-01-01
./xmlchange DOUT_S=FALSE #do not archieve output

#
# set all your I/O here
#
echo "interpolate_output = .true.,.true.,.true.,.true." >>user_nl_cam
echo "interpolate_nlat = 192,192,192,192"               >>user_nl_cam
echo "interpolate_nlon = 288,288,288,288"               >>user_nl_cam

if ($short == "T") then
  echo "se_statefreq       = 1"          >>user_nl_cam
else
  echo "se_statefreq       = 144"        >>user_nl_cam
endif

echo "tracer_cnst_specifier = 'O3','OH','NO3','HO2','HALONS'" >>user_nl_cam
echo "co2_flag=.false."                                       >>user_nl_cam
echo "history_aerosol = .true."                               >>user_nl_cam
echo "clubb_gamma_coef   =  0.28"                             >>user_nl_cam
echo "clubb_c14 = 2.2D0"                                      >>user_nl_cam
#
# Cecile is testing some old CLUBB parameters; turned off here
#
#echo "clubb_l_trapezoidal_rule_zm          =  .false."        >>user_nl_cam
#echo "clubb_l_trapezoidal_rule_zt          =  .false."        >>user_nl_cam
#
echo "ncdata = '/glade/p/cesm/amwg_dev/juliob/FWsc_ne30pg3_58L_GRID_48_taperstart10km_lowtop_BL10_v3_beta1p75_Top_43km.nc'"        >>user_nl_cam
#
# time-steps
#
echo "se_rsplit            = 3"  >>user_nl_cam
echo "se_nsplit            = 2"  >>user_nl_cam
echo "se_hypervis_subcycle = 4"  >>user_nl_cam
#
# new no-leak topo
#
echo "bnd_topo  = '/glade/p/cgd/amp/juliob/bndtopo/latest/ne30pg3_gmted2010_modis_bedmachine_nc3000_Laplace0100_20220622.nc'"        >>user_nl_cam
#
# some CLM changes to namelist
#
echo " check_finidat_year_consistency = .false."   >>user_nl_clm
echo " use_init_interp = .true."                   >>user_nl_clm
#
# bug fix for SE advection
#
cp /glade/u/home/pel/git-scripts/run-cam/collection/src.cam.L58-cecille/prim_advance_mod.F90 SourceMods/src.cam/
./case.setup
qcmd -- ./case.build
./case.submit

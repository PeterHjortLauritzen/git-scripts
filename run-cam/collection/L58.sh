#!/bin/tcsh
#
# 8/17/2022
#
# This script is experimental!
#
# The setup is for running the L58 model.
#
# Steps:
#
# 1. git clone https://github.com/ESCOMP/CAM cam
# 2. cd cam
# 3. git checkout cam_development
# 4. ./manage_externals/checkout_externals
# 5. Edit line below executing create_newcase to your source code location
# 6. source L58.sh
#
# NOTE:
#
# The code for better upper boundary conditions is not on cam_development
# yet so the code is currently using a kluge that was used about a year
# ago by the AMP group.
#
setenv short "F"
unset proj
setenv proj "P93300642"
#setenv proj "P03010039"
unset src
setenv src "cam_development"
unset res
setenv res "ne30pg3_ne30pg3_mg17"
unset comp
setenv comp "FWscHIST"

unset wall
unset pes
if ($short == "T") then
  echo "Short run"
  setenv pes "450"
  setenv wall "00:20:00"
else
  setenv pes "1800"
  setenv wall "00:30:00"
endif
unset drv
setenv drv "nuopc"
#
# for nuopc
#
module load python/3.7.9
ncar_pylib

unset caze
if ($short == "T") then
  setenv caze ${src}_${res}_${pes}_short
else
  setenv caze ${src}_${res}_${pes}_long
endif
/glade/scratch/pel/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $comp --res $res --driver $drv --walltime $wall --mach cheyenne --pecount $pes --project $proj --compiler intel --queue regular --run-unsupported

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

#./xmlchange --append CAM_CONFIG_OPTS="-phys cam_dev -chem waccm_sc_mam4 -cppdefs -Dwaccm_debug -nlev 93 -nadv_tt=5"
./xmlchange --append CAM_CONFIG_OPTS="-phys cam_dev -microphys mg2 -chem waccm_sc_mam4 -nlev 58 -cppdefs -Dwaccm_debug -nadv_tt=5"
./xmlchange RUN_STARTDATE=1979-01-01
./xmlchange DOUT_S=FALSE

#echo "mfilt  = 0,5,20,40,120,240,365,73,365"               >>user_nl_cam
#echo "nhtfrq = 0, -24,-6,-3,-1,1,-24,-24"                  >>user_nl_cam
echo "nhtfrq = 0, -24,0,0,0,0,0,0"                  >>user_nl_cam
echo "fexcl1 = ' '  "                                      >>user_nl_cam
echo "fexcl2 = ' '  "                                      >>user_nl_cam
echo "fincl1 = 'PRECT','PRECC','TT_LW', 'TT_MD', 'TT_HI', 'TTRMD' , 'TT_UN','PSL','OMEGA500','OMEGA850','ABS_dPSdt','NO2'"   >>user_nl_cam
echo "fincl2 = 'PRECT','PRECC','TT_LW', 'TT_MD', 'TT_HI', 'TTRMD' , 'TT_UN','PSL','OMEGA500','OMEGA850','ABS_dPSdt','NO2'"   >>user_nl_cam
echo "interpolate_output = .true.,.true.,.true.,.true." >>user_nl_cam
echo "interpolate_nlat = 192,192,192,192"               >>user_nl_cam
echo "interpolate_nlon = 288,288,288,288"               >>user_nl_cam


if ($short == "T") then
  echo "se_statefreq       = 1"          >>user_nl_cam
else
  echo "se_statefreq       = 144"        >>user_nl_cam
endif

echo "tracer_cnst_specifier          = 'O3','OH','NO3','HO2','HALONS'"        >>user_nl_cam

echo "co2_flag=.false."           >>user_nl_cam

echo "history_aerosol = .true."   >>user_nl_cam

echo "clubb_gamma_coef   =  0.28" >>user_nl_cam
echo "clubb_c14 = 2.2D0"          >>user_nl_cam
#echo "clubb_l_trapezoidal_rule_zm          =  .false."        >>user_nl_cam
#echo "clubb_l_trapezoidal_rule_zt          =  .false."        >>user_nl_cam

echo "ncdata = '/glade/p/cesm/amwg_dev/juliob/FWsc_ne30pg3_58L_GRID_48_taperstart10km_lowtop_BL10_v3_beta1p75_Top_43km.nc'"        >>user_nl_cam

echo "interpolate_output = .true.,.true."        >>user_nl_cam
echo "interpolate_nlat = 192,192"        >>user_nl_cam
echo "interpolate_nlon = 288,288"        >>user_nl_cam

echo "se_rsplit            = 3"        >>user_nl_cam
echo "se_nsplit           = 2"        >>user_nl_cam
echo "se_hypervis_subcycle =  4"        >>user_nl_cam

echo "bnd_topo  = '/glade/p/cgd/amp/juliob/bndtopo/latest/ne30pg3_gmted2010_modis_bedmachine_nc3000_Laplace0100_20220622.nc'"        >>user_nl_cam




#
# temporary (unphysical) fix
#
# When PR for this is done: In the UBC specifier code you would simply include 'Q->2.e-8vmr' (or whatever value is appropriate at the top of the L93 model) in the ubc_specifier namelist option. 
# Contact: F.Vitt (NCAR)
#
cp /glade/u/home/pel/git-scripts/run-cam/collection/src.cam.L93/chemistry.F90 SourceMods/src.cam/

./case.setup

qcmd -- ./case.build
./case.submit

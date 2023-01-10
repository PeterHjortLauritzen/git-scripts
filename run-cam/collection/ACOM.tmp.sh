#!/bin/tcsh
#
# 9/9/2022
#
# This script is experimental!
#
# The setup is for running the L83 model (~80km top) using the latest
# cam_development code:
#
# Steps:
#
# 1. git clone https://github.com/ESCOMP/CAM cam
# 2. cd cam
# 3. git checkout cam_development
# 4. ./manage_externals/checkout_externals
# 5. Edit line below executing create_newcase to your source code location
# 6. source ACOM.sh
#
setenv short "T"
unset proj
setenv proj "P93300642"
#setenv proj "P03010039"
unset src
setenv src "cam_development"
unset res
setenv res "ne30_ne30_mg17"
unset comp
setenv comp FWscHIST
unset wall
unset pes
if ($short == "T") then
  echo "Short run"
  setenv pes "1800"
  setenv wall "00:30:00"
else
  setenv pes "1800"
  setenv wall "02:30:00"
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
  setenv caze acom_fix_short
else
  setenv caze acom_fix_long
endif
/glade/work/hannay/cesm_tags/cesm3_cam6_3_058_MOM_e/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $comp --res $res --driver $drv --walltime $wall --mach cheyenne --pecount $pes --project $proj --compiler intel --queue regular --run-unsupported

cd /glade/scratch/$USER/$caze 
#./xmlchange REST_N=12
#./xmlchange REST_OPTION=nmonths
./xmlchange NTHRDS=1
if ($short == "T") then
  ./xmlchange STOP_OPTION=ndays
  ./xmlchange STOP_N=5
else
  ./xmlchange STOP_OPTION=ndays
  ./xmlchange STOP_N=60
endif


#./xmlchange CAM_CONFIG_OPTS="-phys cam_dev -microphys mg2 -age_of_air_trcs -chem trop_strat_mam4_vbs -nlev 58 -nadv 202"
#
# add test tracers
#
./xmlchange CAM_CONFIG_OPTS="-phys cam_dev -microphys mg2 -age_of_air_trcs -chem trop_strat_mam4_vbs -nlev 58 -nadv 207 -nadv_tt 5"
./xmlchange RUN_STARTDATE=2011-01-01

./xmlchange DOUT_S=FALSE

ln -s /glade/u/home/pel/git-scripts/run-cam/collection/ACOM-files/user_nl_cam .
ln -s /glade/u/home/pel/git-scripts/run-cam/collection/ACOM-files/user_nl_clm .

./case.setup
#qcmd -- ./case.build
#./case.submit

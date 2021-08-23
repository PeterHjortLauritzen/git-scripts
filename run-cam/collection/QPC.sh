#!/bin/tcsh
if ( "$#argv" != 1) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 res"
  echo "supported resolutions/dycores are"
  echo "se-cslam: ne30pg3_ne30pg3_mg17"
  echo "se      : ne30_ne30_mg17"
  echo "fv3     : C96_C96_mg17"
  echo "fv      : f09_f09_mg17"
  echo "mpas    : mpasa120_mpasa120"
endif
set n = 1
unset res
set res = "$argv[$n]" 

#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="cam_development"
#
# number of test tracers
#
set NTHRDS="1"
set pw=`pwd`
set stopoption="ndays"
set steps="10"
set cset="QPC6"
if ($res == "C96_C96_mg17") then
  set pecount="384"
else
  set pecount="450"
#  set pecount="144"
endif
if ($res == "mpasa120_mpasa120") then
  set src="mpas" # remove when MPAS on cam_development
#  set pecount = "36x1"
  set pecount = "576x1"
endif
set pw=`pwd`
source machine_settings.sh startup
echo $PBS_ACCOUNT

set caze=${cset}_${res}
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime 00:20:00 --pecount $pecount  --project $PBS_ACCOUNT --compiler $compiler --run-unsupported


cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange DEBUG=FALSE
./xmlchange NTHRDS=$NTHRDS
./xmlchange TIMER_LEVEL=10
./case.setup

echo "test_tracer_names              = 'TT_SLOT1','TT_SLOT2','TT_SLOT3','TT_COSB','TT_CCOSB','TT_lCCOSB','TT_SLOT'" >> user_nl_cam

if ( $res == "ne30pg3_ne30pg3_mg17" || $res == "ne30_ne30_mg17" ) then
  echo "se_statefreq       = 144"                     >> user_nl_cam
#  echo "interpolate_output = .true.,.true.,.true."    >> user_nl_cam
#  echo "interpolate_nlat   = 192,192,192"             >> user_nl_cam
#  echo "interpolate_nlon   = 288,288,288"             >> user_nl_cam
endif
if ($res == "mpasa120_mpasa120") then
  echo "ncdata='/project/amp/pel/inic/x1.40962.init.umjs.dry.32levels.nc'" >> user_nl_cam
endif
#echo "avgflag_pertape(1) = 'I'" >> user_nl_cam
#echo "avgflag_pertape(2) = 'I'" >> user_nl_cam
#echo "avgflag_pertape(5) = 'I'" >> user_nl_cam
#echo "nhtfrq             = -24,-24,-24,-24,-24" >> user_nl_cam

#cd SourceMods/src.cam/
#ln -s $pw/src.cam/*.F90 .
#cd ../../
source $pw/machine_settings.sh cleanup

if(`hostname` == 'hobart.cgd.ucar.edu') then
  ./case.build
endif
if(`hostname` == 'izumi.unified.ucar.edu') then
 ./case.build
endif
if(`hostname` == 'cheyenne1' || `hostname` == 'cheyenne2' || `hostname` == 'cheyenne3' || `hostname` == 'cheyenne4' || `hostname` == 'cheyenne5' || `hostname` == 'cheyenne6') then
qcmd -- ./case.build
endif
./case.submit


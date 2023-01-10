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
set short = "False"
set src="cam_development"
set cset="FHS94"
set NTHRDS="1"
if ($res == "C96_C96_mg17") then
  set pecount="384"
else
if ($short == "True") then
    set pecount="36"
  else
    set pecount="450"
  endif
endif
if ($res == "mpasa120_mpasa120") then
  set pecount = "576x1" 
endif
if ($short == "True") then
  set stopoption="nsteps"
  set steps="5"
  set walltime="00:15:00"
else
  set stopoption="nmonths"
  set steps="2"
  set walltime="01:00:00"
endif
#set stopoption="ndays"
#set steps="1800"
#set walltime="05:00:00"

#set PBS_ACCOUNT="P93300642"
set PBS_ACCOUNT="P03010039"
set homedir="/glade/u/home"
set scratch="/glade/scratch"
set queue="regular"
set compiler="intel"
set machine="cheyenne"
set pw=`pwd`

set caze=topoMoist_${cset}_${res}_${pecount}
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --compiler $compiler --machine $machine --run#-unsupported
cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
#./xmlchange CAM_CONFIG_OPTS="-analytic_ic -phys held_suarez -nlev 32 -nadv_tt 5" #very important: otherwise you get PS=1000hPa initial condition
./xmlchange CAM_CONFIG_OPTS="-phys held_suarez -nlev 32 -nadv_tt 5"
./xmlchange NTHRDS=$NTHRDS
./xmlquery CASEROOT
#./xmlchange REST_N=12
./xmlchange REST_OPTION=nmonths
./case.setup
echo "use_topo_file          =  .true." >> user_nl_cam
echo "analytic_ic_type ='us_standard_atmosphere'"  >> user_nl_cam
if ($res == "ne30_ne30_mg17" || $res == "ne30pg3_ne30pg3_mg17") then
  echo "se_statefreq       = 256"        >> user_nl_cam
  echo "interpolate_output = .false.,.true." >> user_nl_cam      
  echo "interpolate_nlat = 192,192,192"               >> user_nl_cam
  echo "interpolate_nlon = 288,288,288"               >> user_nl_cam
  echo "ncdata = '/glade/p/cesmdata/inputdata/atm/cam/inic/se/ape_topo_cam6_ne30np4_L32_c171023.nc'" >>user_nl_cam
  echo "fincl2 = 'PS','T','U','V','OMEGA500','OMEGA850','TT_UN'  " >> user_nl_cam
endif
echo "fincl1 = 'PS','T','U','V','OMEGA500','OMEGA850','TT_UN'  " >> user_nl_cam
echo "empty_htapes       = .true."   >> user_nl_cam
if ($short == "True") then
  echo "avgflag_pertape(1) = 'I'"                           >> user_nl_cam
  echo "avgflag_pertape(2) = 'I'"                           >> user_nl_cam
  echo "nhtfrq             = 1,   1, 0,            	" >> user_nl_cam
else
  echo "avgflag_pertape(1) = 'A'"                           >> user_nl_cam
  echo "avgflag_pertape(2) = 'A'"                           >> user_nl_cam
  echo "nhtfrq             = 0,   0, 0,            	" >> user_nl_cam
  echo "inithist           =  'YEARLY'"                     >> user_nl_cam
endif
#echo "test_tracer_names  = 'TT_SLOT','TT_EM8'"            >>user_nl_cam
cd SourceMods/src.cam/
ln -s /glade/u/home/pel/git-scripts/run-cam/collection/src.cam.FHS94-topo/held_suarez_1994.F90 .
cd ../../
if(`hostname` == 'hobart.cgd.ucar.edu') then
  ./case.build
endif
if(`hostname` == 'izumi.unified.ucar.edu') then
 ./case.build
endif
if(`hostname` == 'cheyenne1.ib0.cheyenne.ucar.edu' || `hostname` == 'cheyenne1' || `hostname` == 'cheyenne2' || `hostname` == 'cheyenne3' || `hostname` == 'cheyenne4' || `hostname` == 'cheyenne5' || `hostname` == 'cheyenne6') then
  qcmd -A $PBS_ACCOUNT-- ./case.build
endif
./case.submit

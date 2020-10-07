#!/bin/tcsh
setenv PBS_ACCOUNT "P93300642"
#
# P93300642
#
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="CAM"
set cset="FHS94"
set NTHRDS="1"
#set res="ne30_ne30_mg17" 
set res="f09_f09_mg17"       
set stopoption="ndays"
set steps="1800"
set topo="True"
set nlev="70"
echo "setting up for Cheyenne"
set inic="/glade/p/cgd/amp/pel/inic"
set homedir="/glade/u/home"
set inputdir="/glade/p/cesmdata/cseg/inputdata/atm"
set scratch="/glade/scratch"
set queue="economy"
#
# 637 SYPD with FHS94 ne30_ne30 using 2700 PEs; runs in 8min
#  81 SYPD with FHS94 ne30pg3_ne30pg3 using  900 PEs
#
set pecount="1800" 
set walltime="03:00:00"
set machine="cheyenne"  
set compiler="intel"

set caze=${cset}_high_order_top_${src}_${res}_nlev${nlev}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --compiler $compiler --machine $machine --run-unsupported

cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange CAM_CONFIG_OPTS="-analytic_ic -phys held_suarez -nlev "$nlev" -nadv_tt=5" #very important: otherwise you get PS=1000hPa initial condition
./xmlchange NTHRDS=$NTHRDS
./xmlquery CASEROOT
./case.setup

echo "use_topo_file      =  .true.   ">>user_nl_cam
echo "analytic_ic_type='us_standard_atmosphere'">>user_nl_cam
#if ($res == "f09_f09_mg17") then
##  echo "bnd_topo = '$inputdir/topo/fv_0.9x1.25_nc3000_Nsw042_Nrs008_Co060_Fi001_ZR_sgh30_24km_GRNL_c170103.nc'">>user_nl_cam
#  echo "ncdata   = '$inputdir/inic/fv/cami-mam3_0000-01-01_0.9x1.25_L32_c141031.nccami-mam3_0000-01-01_0.9x1.25_L30_c100618.nc'" >>user_nl_cam
#endif

if ($res == "f09_f09_mg17") then
  echo "fv_nsplit = 16" >> user_nl_cam
  echo "fv_nspltrac = 4" >> user_nl_cam
  echo "fv_div24del2flag = 4" >> user_nl_cam
  echo "fv_nspltvrm = 2" >> user_nl_cam
  echo "fv_high_order_top = .true." >> user_nl_cam
endif

if ($res == "ne30_ne30_mg17" || $res == "ne30pg3_ne30pg3_mg17") then
  echo "se_statefreq       = 256"        >> user_nl_cam
  echo "interpolate_output = .true.,.true.,.false.,.false." >> user_nl_cam      
#    echo "bnd_topo = '$inputdir/topo/se/ne30np4_nc3000_Co060_Fi001_PF_nullRR_Nsw042_20171020.nc'">>user_nl_cam

#  if ($nlev == 110) then
#    echo "ncdata = '/glade/p/cgd/amp/pel/inic/waccm.nlev110.nc'" >>user_nl_cam
#  endif     
  if ($nlev == 70) then
    echo "ncdata = '$inputdir/waccm/ic/FW2000_ne30_L70_01-01-0001_c200602.nc'" >> user_nl_cam
    #
    # WACCM dynamics settings
    #
    echo "se_nsplit = 5"                                                       >> user_nl_cam
    echo "se_rsplit = 4"                                                       >> user_nl_cam
    echo "se_molecular_diff = 100.0"                                           >> user_nl_cam
    echo "se_hypervis_subcycle =1"                                             >> user_nl_cam
    echo "se_nu_top = 0.0"                                                     >> user_nl_cam

    echo "interpolate_nlat = 192,192,192"               >> user_nl_cam
    echo "interpolate_nlon = 288,288,288"               >> user_nl_cam
  endif
#  if ($nlev == 32) then
#    echo "ncdata = '$inputdir/inic/se/ape_topo_cam6_ne30np4_L32_c171023.nc'" >>user_nl_cam
#  endif        
endif

echo "nhtfrq = 0,0,0,-24" >> user_nl_cam
echo "fincl1 = 'PS','T','Z3','U','V','OMEGA','PHIS','OMEGA500','OMEGA850','PSL','PHIS', ">> user_nl_cam
echo "         'TT_LW','TT_MD','TT_HI','TTRMD','TT_UN'" >> user_nl_cam
#echo "fincl2             = 'PS','T','Z3','U','V','OMEGA','PHIS','OMEGA500','OMEGA850','PSL' ">> user_nl_cam
#echo "fincl3             = 'PS','T','Z3','U','V','OMEGA','PHIS','OMEGA500','OMEGA850','PSL' ">> user_nl_cam
#echo "inithist           =  'MONTHLY'">>user_nl_cam

qcmd -- ./case.build
./case.submit


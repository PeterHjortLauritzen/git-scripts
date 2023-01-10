#!/bin/tcsh
setenv PBS_ACCOUNT P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="mpas"
#set src="trunk"
set res="mpasa120_mpasa120"
set stopoption="ndays"
set steps="10"
set cset="FKESSLER"
echo "setting up for Cheyenne"
set homedir="/glade/u/home"
set scratch="/glade/scratch"
set queue="regular"
set pecount="36x1" 

set caze=${src}_${cset}_CAM_${res}_${pecount}_${steps}${stopoption}
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --input-dir /glade/work/duda/cesmdata/inputdata --q $queue --walltime 00:20:00 --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported

cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange TIMER_LEVEL=10
#./xmlchange CAM_CONFIG_OPTS="-nadv_tt 6 -chem none -phys kessler -nlev 26 -analytic_ic "
./xmlchange CAM_CONFIG_OPTS="-nadv_tt 6 -chem none -phys kessler -nlev 26  "

#./xmlchange --append CAM_CONFIG_OPTS="-nadv_tt=10" #there are already 6 tracers in FKESSLER
#./xmlchange CAM_CONFIG_OPTS="-phys kessler -chem terminator -analytic_ic  -nlev $nlev"

./case.setup
echo "analytic_ic_type = 'moist_baroclinic_wave_dcmip2016'" >> user_nl_cam
echo "avgflag_pertape(1) = 'I'"                                                                                          >> user_nl_cam
echo "fincl1         = 'PS','PSDRY','PRECL','Q','CLDLIQ','RAINQM','T','U','V','OMEGA'"                                           >> user_nl_cam
echo "mpas_block_decomp_file_prefix = '/glade/work/duda/cesmdata/inputdata/atm/cam/inic/mpas/mpasa120.graph.info.part.'" >> user_nl_cam
echo "ncdata = '/glade/work/duda/cesmdata/inputdata/atm/cam/inic/mpas/mpasa120_L26_FKESSLER.init.nc'"                    >> user_nl_cam
#echo "ncdata = '/glade/work/duda/cesmdata/inputdata/atm/cam/inic/mpas/mpasa120_L32_v6.1.grid.nc'"   >> user_nl_cam
qcmd -- ./case.build
./case.submit

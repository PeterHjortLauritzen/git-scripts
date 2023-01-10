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
set cset="FHS94"
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
./xmlchange --append CAM_CONFIG_OPTS="-nlev 26" #there are already 6 tracers in FKESSLER

./case.setup
#echo "analytic_ic_type = ''" >> user_nl_cam
#echo "avgflag_pertape(1) = 'I'"                                                                                          >> user_nl_cam
#echo "fincl1 = 'PS', 'PRECL', 'Q', 'CLDLIQ', 'RAINQM', 'T', 'U', 'V', 'iCLy', 'iCL', 'iCL2', 'OMEGA',"                   >> user_nl_cam
#echo "         'TT_SLOT1', 'TT_SLOT2', 'TT_SLOT3', 'TT_COSB', 'TT_CCOSB', 'TT_lCCOSB'"                                   >> user_nl_cam
echo "mpas_block_decomp_file_prefix = '/glade/work/duda/cesmdata/inputdata/atm/cam/inic/mpas/mpasa120.graph.info.part.'" >> user_nl_cam
echo "ncdata = '/glade/work/duda/cesmdata/inputdata/atm/cam/inic/mpas/mpasa120_L26_FKESSLER.init.nc'"                    >> user_nl_cam
qcmd -- ./case.build
./case.submit

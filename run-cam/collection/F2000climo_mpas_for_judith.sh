#!/bin/tcsh
setenv PBS_ACCOUNT P93300642
#
# cd /glade/u/home/$USER/src
# git clone https://github.com/ESCOMP/CAM cam_development
# cd cam_development
# git checkout cam_development
# ./manage_externals/checkout_externals
#
# edit settings in script below
#
# source F2000climo_mpas_for_judith.sh
#
module load python
set homedir="/glade/u/home"
set src="cam_development"
set scratch="/glade/scratch"
set mach="cheyenne"
set cset="F2000climo"
set dycore = "mpas"
set proj="P03010039"
set res="mpasa120_mpasa120"
#
# Note: pecount can not be chosen arbitrarily; there must be a 
#       corresponding pe layout file in 
#
#       /glade/p/cesmdata/inputdata/atm/cam/inic/mpas
#
# For example, existing 1 degree mpas pe layout files are listed with
#
# ls /glade/p/cesmdata/inputdata/atm/cam/inic/mpas/mpasa120.graph.info*
#
set pecount="144"
set stopoption="ndays"
set steps="1"
set wall="00:20:00"
set queue="regular" #  set queue="short
set compiler="intel"
#
# set name for case
#
set caze=${cset}_${res}
#
# create_newcase (initial setup)
#
$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime $wall --pecount $pecount   --compiler $compiler --project $proj --walltime $wall  --run-unsupported

cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
#
# no archiving of output
#
./xmlchange DOUT_S=FALSE
#
# to run CAM7 (/CAM6+)
#
#./xmlchange --append CAM_CONFIG_OPTS="-phys cam_dev"
#./xmlchange ROF_NCPL=96 #fix nuopc bug when only running a couple of time-steps

./case.setup
echo "inithist = 'ENDOFRUN'"                                               >> user_nl_cam
echo "EMPTY_HTAPES=.true."                                                 >> user_nl_cam
echo "avgflag_pertape(1) = 'I'"                                            >> user_nl_cam
echo "nhtfrq = 1"                                                          >> user_nl_cam
echo "fincl1 = 'PS','PSDRY','PSL','OMEGA500','OMEGA850','PRECT'"           >> user_nl_cam  
#
# set fsurdat (not set by default in CLM yet)
#
echo "fsurdat = '/glade/p/cesmdata/cseg/inputdata/lnd/clm2/surfdata_map/surfdata_mpasa120_hist_78pfts_CMIP6_simyr2000_c211108.nc'" >> user_nl_clm
#
# it takes a long time to interpolate land datasets. Once the model has been run once, one may
# speed up the initialization with (not needed if restarting model run)
#
# echo "finidat = 'init_generated_files/finidat_interp_dest.nc'" >>
# user_nl_clm

qcmd -A $proj -- ./case.build 
./case.submit

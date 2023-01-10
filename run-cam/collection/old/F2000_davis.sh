#!/bin/tcsh
#
# check out CAM:
#
#     mkdir /glade/u/home/$USER/src
#     cd /glade/u/home/$USER/src
#     svn co https://svn-ccsm-models.cgd.ucar.edu/cam1/trunk
#     cd trunk
#     ./manage_externals/checkout_externals 
#
#     go to directory where this script is
#     source F2000_davis.sh
#
setenv PBS_ACCOUNT NACM0003
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="trunk"
#set res="ne30pg3_ne30pg3_mg17"#cslam
set res="ne30_ne30_mg17"       #regular SE
#set res="f09_f09_mg17"        #FV

set cset="F2000climo"
set walltime="00:10:00"
set pecount="1800"
set NTHRDS="1"
set stopoption="ndays"
set steps="1"
set caze=${src}_${cset}_${res}_${pecount}_NTHRDS${NTHRDS}_${steps}${stopoption}
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q regular --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange NTHRDS=$NTHRDS

./case.setup
#
# change namelist: fincl1 and fincl2 is output on FV grid and fincl3 is output on SE native grid
#
echo "nhtfrq = -24,-24,-24"  >> user_nl_cam
echo "interpolate_output = .true.,.true.,.false."       	   >> user_nl_cam
echo "interpolate_nlat   = 192,192,192" >> user_nl_cam #output on FV grid
echo "interpolate_nlon   = 288,288,288" >> user_nl_cam #output on FV grid
echo "interpolate_type    = 0         " >> user_nl_cam #evaluate SE basis functions at lat-lon points (high-order)
#echo "interpolate_type        = 1          " >> user_nl_cam #bilinear interpolation from GLL points to lat-lon points
qcmd -- ./case.build
./case.submit

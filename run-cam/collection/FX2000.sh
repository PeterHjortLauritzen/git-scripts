#!/bin/tcsh
#setenv PBS_ACCOUNT "P03010039"
setenv PBS_ACCOUNT "P93300642"
#setenv PBS_ACCOUNT NACM0003
# P03010039
# P93300042
# P03010083
# P93300075
# P05010048
# P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="cam_pel_development_trunk"
#set src="cam_ref"
#
# run with CSLAM or without
#
#set res="ne30pg3_ne30pg3_mg17" #cslam
#
# still need to att ne30pg3 to components/clm/bld/namelist_files/namelist_definition_ctsm.xml?
#
#set res="ne0CONUSne30x8_ne0CONUSne30x8_mg17"
#set res="ne30_ne30_mg17"      #no cslam
#set res="ne30pg3_ne30pg3_mg17"      #cslam
#set res="ne120pg3_ne120pg3_mg17"
#set res="ne120pg3_ne120pg3_mt13"

set res="f19_f19_mg17"     

#set climateRun="True"
set climateRun="False"
#set energyConsistency="True"
set energyConsistency="False"
set test_tracers="False"
set defaultIO="False"
#
# DO NOT MODIFY BELOW THIS LINE
#
#set cset="FWHIST"
#set cset="FCHIST"
#set cset="FW2000climo"
#set cset="F2000climo"
set cset="FXHIST"
#set cset="FHS94"
#
# location of initial condition file (not in CAM yet)
#
set inic="/glade/p/cgd/amp/pel/inic"
#echo "Do CSLAM mods in clm and cime:"
#source clm_and_cime_mods_for_cslam.sh $src
#echo "Done"
  set walltime="00:15:00"
  set pecount="1"
  set NTHRDS="1"
  set stopoption="nsteps"
  set steps="1"


    set caze=debug_${src}_${cset}_${res}_NTHRDS${NTHRDS}_${steps}${stopoption}

/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q regular --walltime $walltime  --project $PBS_ACCOUNT --run-unsupported
#/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q regular --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
#./xmlchange CASEROOT=/glade/scratch/$USER/$caze
#./xmlchange EXEROOT=/glade/scratch/$USER/$caze/bld
#./xmlchange RUNDIR=/glade/scratch/$USER/$caze/run

./xmlchange DEBUG=TRUE #xxxx
#
#./xmlchange NTHRDS=$NTHRDS
## timing detail
./xmlchange TIMER_LEVEL=10


#./xmlchange EPS_AAREA=1.0e-04

./xmlquery EXEROOT
./xmlquery CASEROOT

./case.setup





#
# spinup
#
#echo "se_nsplit = 120" >> user_nl_cam
#echo "inithist='6-HOURLY'" >> user_nl_cam
#echo "se_hypervis_on_plevs = .false." >> user_nl_cam
#echo "se_nu_top =  1.0e6"   >> user_nl_cam
#
#echo "se_nu     =  0.1E17" >> user_nl_cam
#echo "se_nu_div =  0.1E17" >> user_nl_cam
#echo "se_nu_p   =  0.1E17" >> user_nl_cam
#echo "se_hypervis_subcycle = 3" >> user_nl_cam

qcmd -- ./case.build
./case.submit

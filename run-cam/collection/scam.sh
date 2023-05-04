#!/bin/tcsh
setenv PBS_ACCOUNT P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
# module load intel...
# /usr/local/toolworks/totalview.2018.1.12/bin/totalview ../bld/cesm.exe
#
#
#
# On Izumi with NAG a clean build takes about 28 minutes!
#
set src="cam_development"
#set src="ebudget_dev_update"
#set mach="cheyenne"
set mach="izumi"
set cset="FSCAM"
set dycore = "eul"
#set proj="P93300642"
set proj="P03010039"
#set proj="P93300042"  #production account
set res="T42_T42"
set pecount="1"

set stopoption="nsteps"
set steps="3"
set wall="00:05:00"
#
# DO NOT MODIFY BELOW THIS LINE
#

if ($mach == "cheyenne") then
  set homedir="/glade/u/home"
  set scratch="/glade/scratch"
  set queue="regular" #  set queue="short
  set compiler="intel"
else
  set homedir="/home"
  set scratch="/scratch/cluster"
  set queue="monster" #  set queue="short
  set compiler="intel"
#  set compiler="nag"
endif

### Set Desired IOP
### $1 means read from command line. Or put one of the names in:
###     arm95 arm97 atex bomex cgilsS11 cgilsS12 cgilsS6 dycomsRF01 dycomsRF02 gateIII mpace rico sparticus togaII twp06

set IOP = arm97
set IOPNAME = scam_$IOP
set MODSDIR = $homedir/$USER/src/$src/cime_config/usermods_dirs

set caze=${src}_${cset}_${res}

$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime $wall --pecount $pecount   --compiler $compiler --project $proj --walltime $wall   --user-mods-dir ${MODSDIR}/${IOPNAME}  --run-unsupported

cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
if ($mach != "cheyenne") then
  ./xmlchange DEBUG=TRUE #otherwise NAG error
endif

./case.setup

if ($mach == "cheyenne") then
  qcmd -A $proj -- ./case.build 
  ./case.submit
else
echo "#PBS -q long                                      " >> get_compute
echo "# Number of nodes (CHANGE THIS if needed)         " >> get_compute
echo "#PBS -l walltime=1:00:00,nodes=1:ppn=16           " >> get_compute
echo "# output file base name                           " >> get_compute
echo "#PBS -N interactive                               " >> get_compute
echo "# Put standard error and standard out in same file" >> get_compute
echo "#PBS -j oe                                        " >> get_compute
echo "# Export all Environment variables                " >> get_compute
echo "#PBS -V                                           " >> get_compute
#
#qsub -X -I get_compute
./case.build
#./case.submit
endif  


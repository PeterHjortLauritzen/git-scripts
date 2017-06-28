#!/bin/tcsh
#
# This script creates a CESM run-script to run CAM for various configurations
#
# Peter Hjort Lauritzen
# Climate and Global Dynamics Laboratory
# National Center for Atmospheric Research
# Boulder, Colorado
#
# Example usage:
#
# run CAM4 Aqua-planet with mountains using the spectral-element dynamical core
#
# source master.sh ne30_ne30 QPC4 cheyenne 1152 nmonths 6 01:30:00 /glade/u/home/pel/release/topo/ne30np4_nc3000_Co092_Fi001_MulG_PF_nullRR_Nsw064_20170510.nc Co92
#
if ( "$#argv" > 10) then
  echo "Too many arguments specified "$#argv
  echo "Aborting"
  exit
endif
if ( "$#argv" < 9) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 is res      : ne30_ne30, ..."
  echo "  -arg 2 is compset  : FKESSLER QPC4 QPC5 QPC6"
  echo "  -arg 3 is machine  : cheyenne hobart"
  echo "  -arg 4 is pecount  : pecount"
  echo "  -arg 5 is stop unit: nmonths,ndays,nsteps"
  echo "  -arg 6 is stop_n   : integer"
  echo "  -arg 7 is walltime : e.g., 01:00:00"
  echo "  -arg 8 is topo_file: user specified topo files (if no user specified topo use default)"
  echo "  -arg 9 append case : text to append to case name"
  exit
endif
#set project_number = "P03010083" #"P03010039" #"P93300042"
set n = 1
set res = "$argv[$n]"
set n = 2
set compset = "$argv[$n]"
set n = 3
set machine = "$argv[$n]"
set n = 4
set pecount = "$argv[$n]"
set n = 5
set stop_option = "$argv[$n]"
set n = 6
set stop_n = "$argv[$n]"
set n = 7
set walltime = "$argv[$n]"
set n = 8
set user_topo = "$argv[$n]"
set n = 9
set append_case_name = "$argv[$n]"

if ($user_topo == "default") then
  setenv caze ${compset}_${res}_pe${pecount}_${stop_n}${stop_option}_{$append_case_name}
  setenv script ${compset}_${res}_pe${pecount}_${stop_n}${stop_option}_{$append_case_name}.sh
else
  setenv caze ${compset}_with-user-topo_${res}_pe${pecount}_${stop_n}${stop_option}_{$append_case_name}
  setenv script ${compset}_with-user-topo_${res}_pe${pecount}_${stop_n}${stop_option}_{$append_case_name}.sh
endif
if (-e $script) then
  echo "$script already exists - ABORT"
  exit
else
  touch $script
endif
setenv src "physgrid"
if ($machine == "cheyenne") then
    echo "/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $compset --res $res --walltime $walltime --pecount $pecount --project P93300042 --run-unsupported" >> $script
    echo "cd /glade/scratch/$USER/$caze" >> $script
else if ($machine == "hobart") then
    echo "/home/$USER/src/$src/cime/scripts/create_newcase --case /scratch/cluster/$USER/$caze --compset $compset --res $res --walltime $walltime --q verylong --pecount $pecount --compiler nag --run-unsupported" >> $script
    echo "cd /scratch/cluster/$USER/$caze" >> script
else
    echo "Machine $machine not found" 
    exit
endif
echo "./xmlchange STOP_OPTION=$stop_option,STOP_N=$stop_n" >> $script
#
# do not archive
#
echo "./xmlchange DOUT_S=FALSE" >> $script
#
# change physics time-step
#
#./xmlchange ATM_NCPL=192
#./xmlchange NTHRDS=1
##./xmlchange DEBUG=TRUE
echo "./case.setup" >> $script

echo 'echo "se_statefreq       = 144                                                    ">> user_nl_cam' >> $script
echo 'echo "empty_htapes       = .true.                                                 ">> user_nl_cam' >> $script
echo 'echo "fincl1             = '\''U:I'\'','\''V:I'\'','\''T:I'\'','\''PS:I'\''                               ">> user_nl_cam' >> $script
echo 'echo "fincl2             = '\''U'\'','\''V'\'','\''T'\'','\''PS'\'','\''OMEGA'\'','\''PHIS'\'','\''PSL'\'',                 ">> user_nl_cam' >> $script
echo 'echo "                     '\''OMEGA500'\'','\''PRECT'\'','\''PRECL'\'','\''RELHUM'\'','\''TMQ'\''              ">> user_nl_cam' >> $script
echo 'echo "nhtfrq             = -40,0                                                  ">> user_nl_cam' >> $script
echo 'echo "interpolate_output = .true.,.true.                                          ">> user_nl_cam' >> $script
if ($user_topo == "default") then
  echo "use default topo settings"
else
  echo 'echo "use_topo_file      =    .true.                                              ">> user_nl_cam' >> $script
  echo 'echo "bnd_topo = '\'''$user_topo''\''" >> user_nl_cam' >> $script
  echo 'echo "ncdata = '\''/glade/p/cesmdata/cseg/inputdata/atm/cam/inic/se/cami_0000-01-01_ne30np4_L26_c100108.nc'\''" >> user_nl_cam' >> $script
endif
echo "./case.build"  >> $script
echo "./case.submit" >> $script
echo "script "$script" was successfully created"
echo "check that the settings are correct before submitting!"

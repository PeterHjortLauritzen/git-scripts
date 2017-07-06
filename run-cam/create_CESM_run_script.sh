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
# source create_CESM_run_script.sh ne30_ne30 QPC4 cheyenne 1152 nmonths  6 01:30:00 /glade/u/home/pel/release/topo/ne30np4_nc3000_Co092_Fi001_MulG_PF_nullRR_Nsw064_20170510.nc Co92 economy
#
# source create_CESM_run_script.sh ne30_ne30 QPC4 hobart    672 nmonths 42 01:30:00 /glade/u/home/pel/release/topo/ne30np4_nc3000_Co092_Fi001_MulG_PF_nullRR_Nsw064_20170510.nc Co92 monster
#
# source create_CESM_run_script.sh ne30_ne30 QPC6 cheyenne 3456 nmonths 6 02:30:00 /glade/u/home/pel/release/topo/ne30np4_nc3000_Co092_Fi001_MulG_PF_nullRR_Nsw064_20170510.nc Co92 economy
#
# source create_CESM_run_script.sh ne120_ne120 QPC4 cheyenne 11520 nmonths 6 01:30:00 /glade/scratch/pel/topo/ne120np4_nc3000_Co024_Fi001_Oc001_PF_nullRR_Nsw016_c170601.nc Co24 economy
#
#
#  source create_CESM_run_script.sh ne30pg3_ne30pg3_mg17 QPC4 cheyenne 1152 nmonths 6 01:30:00 /glade/u/home/pel/release/topo/ne30pg3_nc3000_Co060_Fi001_MulG_PF_nullRR_Nsw042_20170501.nc Co60 economy
#
if ( "$#argv" > 13) then
  echo "Too many arguments specified "$#argv
  echo "Aborting"
  exit
endif
if ( "$#argv" < 13) then
  echo "Wrong number of arguments specified: "$#argv
  echo "  -arg 1 is res       : ne30_ne30, ..."
  echo "  -arg 2 is compset   : FKESSLER QPC4 QPC5 QPC6"
  echo "  -arg 3 is machine   : cheyenne hobart"
  echo "  -arg 4 is pecount   : pecount"
  echo "  -arg 5 is stop unit : nmonths,ndays,nsteps"
  echo "  -arg 6 is stop_n    : integer"
  echo "  -arg 7 is walltime  : e.g., 01:00:00"
  echo "  -arg 8 is topo_file : user specified topo files (if no user specified topo use default)"
  echo "  -arg 9 append case  : text to append to case name"
  echo "  -arg 10 queue       : queue"
  echo "  -arg 11 debugging   : debug nodebug"
  echo "  -arg 12 energy diags: energy_diags"
  echo "  -arg 13 old_visco   : old viscosity settings"
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
set n=10
set queue = "$argv[$n]"
set n=11
set debug = "$argv[$n]"
set n=12
set energy_diags = "$argv[$n]"
set n=13
set old_visco = "$argv[$n]"

if (! -e tmp) then
  echo "creating directory tmp"
  mkdir tmp
else
  echo "directory tmp already exists"
endif

if ($user_topo == "default") then
  set caze   = ${compset}_${res}_pe${pecount}_${stop_n}${stop_option}_{$append_case_name}_{$machine}_{$debug}_{$old_visco}
  set script = tmp/${caze}.sh
else
  set caze   = ${compset}_with-user-topo_${res}_pe${pecount}_${stop_n}${stop_option}_{$append_case_name}_{$machine}_{$debug}_{$old_visco}
  set script = tmp/${caze}.sh
endif
if (-e $script) then
  echo "$script already exists - ABORT"
  exit
else
  touch $script
endif
set src = "physgrid"
if ($machine == "cheyenne") then
    set inputdata = "/glade/p/cesmdata/cseg/inputdata/atm/cam"
    set git_scripts = "/glade/u/home/$USER/git-scripts/run-cam"
    echo "/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $compset --res $res --walltime $walltime --pecount $pecount --project P93300042 --q $queue --run-unsupported" >> $script
    echo "cd /glade/scratch/$USER/$caze" >> $script
else if ($machine == "hobart") then
    set inputdata = "/fs/cgd/csm/inputdata/atm/cam"
    set git_scripts = "/home/$USER/git-scripts/run-cam"
    echo "/home/$USER/src/$src/cime/scripts/create_newcase --case /scratch/cluster/$USER/$caze --compset $compset --res $res --walltime $walltime --q $queue --pecount $pecount --compiler nag --run-unsupported" >> $script
    echo "cd /scratch/cluster/$USER/$caze" >> $script
    echo "./xmlchange NTHRDS=1" >> $script
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
if ($compset == "FHS94") then
  echo './xmlchange CAM_CONFIG_OPTS="-phys held_suarez -analytic_ic"' >> $script
endif


if ($debug == "debug") then
  echo "Debugging turned on"
  echo "./xmlchange DEBUG=TRUE" >> $script
else
  echo "Debugging turned off"
endif
echo "./case.setup" >> $script

echo 'echo "se_statefreq       = 144                                                    ">> user_nl_cam' >> $script
set fincl_n = (0 1 2 3 4 5 6 7 8 9 10 11 12 ) 
@ fincl_n++
set comma = " "
set ndens = ""
if ($energy_diags == "energy_diags") then
  echo 'echo "adding energy diagnostics to fincl"' >> $script
  if ($compset == "FHS94") then
    source $git_scripts/make_energy_diagnostics_fincl.sh $script fincl$fincl_n false fincl3
    @ fincl_n++
    set ndens = "$ndens" "$comma""1"
    set comma = ","
  else
    set tmp_fincl = $fincl_n
    @ fincl_n++
    set tmp_fincl_plus_one = $fincl_n
    source $git_scripts/make_energy_diagnostics_fincl.sh $script fincl$tmp_fincl true fincl$tmp_fincl_plus_one
    echo "xxxxxxxxx"
    set ndens = "$ndens $comma""1,1"
    set comma = ","
  endif
endif

if ($case == "QPC4QPC" || $case == "QPC5QPC" || $case == "QPC6QPC" || $case == "FHS94") then
  echo 'echo "empty_htapes       = .true.                                                 ">> user_nl_cam' >> $script
  echo 'echo "fincl'$fincl_n'             = '\''U:I'\'','\''V:I'\'','\''T:I'\'','\''PS:I'\''                               ">> user_nl_cam' >> $script
  @ fincl_n++
  set ndens = "$ndens $comma""2"
  set comma = ","
endif


if ($compset != "FHS94" & $compset != "FKESSLER") then
  echo 'echo "fincl'$fincl_n'             = '\''U'\'','\''V'\'','\''T'\'','\''PS'\'','\''OMEGA'\'','\''PHIS'\'','\''PSL'\'',                 ">> user_nl_cam' >> $script
  echo 'echo "                     '\''OMEGA500'\'','\''PRECT'\'','\''PRECL'\'','\''RELHUM'\'','\''TMQ'\''              ">> user_nl_cam' >> $script
  @ fincl_n++
  set ndens = "$ndens $comma""2"
  set comma = ","
endif
if ($compset == "FHS94") then
  echo "analytic_ic_type='held_suarez_1994'" >> $script
endif

if ($compset == "FKESSLER") then
  echo 'echo "interpolate_output = .true.,.true.,.true.,.true.                                          ">> user_nl_cam' >> $script
endif
if ($debug == "debug") then
  echo 'echo "nhtfrq             = 1,1,1,1                                                ">> user_nl_cam' >> $script
  echo 'echo "interpolate_output = .true.,.true.,.true.,.true.                                          ">> user_nl_cam' >> $script
#else
#  echo 'echo "nhtfrq             = -400,0,0,0                                              ">> user_nl_cam' >> $script
#echo 'echo "interpolate_output = .true.,.false.,.false.,.true.                                          ">> user_nl_cam' >> $script
endif
#
# set topo file and initial condition (of necessary)
#
if ($user_topo == "default") then
  echo "use default topo settings"
else
  echo 'echo "use_topo_file      =    .true.                                              ">> user_nl_cam' >> $script
  echo 'echo "bnd_topo = '\'''$user_topo''\''" >> user_nl_cam' >> $script
  if ($res == "ne30_ne30") then
    if ($compset == "QPC4") then
      echo 'echo "ncdata = '\'''$inputdata'/inic/se/cami_0000-01-01_ne30np4_L26_c100108.nc'\''" >> user_nl_cam' >> $script
    endif
    if ($compset == "QPC6") then
#      echo 'echo "ncdata = '\'''$inputdata'/inic/se/cami_minimal_ne30np4_L32_c151218.nc'\''" >> user_nl_cam' >> $script
      echo 'echo "ncdata = '\'''$inputdata'/inic/homme/cami_ne30p4_L32_c160128.nc'\''" >> user_nl_cam' >> $script
    endif
    if ($compset == "FHS94") then
      echo 'echo "ncdata = '\'''$inputdata'/inic/homme/cami-mam3_0000-01-01_ne30np4_L30_c130424.nc'\''" >> user_nl_cam' >> $script
    endif
  endif
  if ($res == "ne120_ne120") then
  echo 'echo "ncdata = '\'''$inputdata'/inic/se/cami_0000-01-01_ne120np4_L26_c110304.nc'\''" >> user_nl_cam' >> $script
  endif
endif
if ($old_visco == "old_visco") then
  echo "Using old viscosity defaults"
  echo 'echo "se_nu_div = 6.25E15                                             ">> user_nl_cam' >> $script
  echo 'echo "se_nu     = 1.00E15                                             ">> user_nl_cam' >> $script
  echo 'echo "se_nu_p   = 1.00E15                                             ">> user_nl_cam' >> $script
  echo 'echo "se_hypervis_subcycle   = 3                                             ">> user_nl_cam' >> $script
  echo 'echo "se_hypervis_on_plevs   = .false.                                             ">> user_nl_cam' >> $script
endif

set nchar = `echo $ndens | awk '{print length($0)}'`
if ($nchar != 0) then
  #
  # only echo ndens if it is being altered by this script
  #
  echo 'echo "ndens              ='$ndens'                                                 ">> user_nl_cam' >> $script
endif

echo "./case.build"  >> $script
echo "./case.submit" >> $script
echo "script "$script" was successfully created"
echo "check that the settings are correct before submitting!"

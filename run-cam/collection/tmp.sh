#!/bin/tcsh
setenv PBS_ACCOUNT P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
#
# On Izumi with NAG a clean build takes about 28 minutes!
#
#set src="cam_development"
set src="ebudget_dev_update"
set mach="cheyenne"
#set mach="izumi"
set cset="QPC6"
set dycore = "mpas"
#set dycore = "se"
#set dycore = "cslam"
#set dycore = "fv"
#set proj="P93300642"
set proj="P03010039"
#set proj="P93300042"  #production account
if ($dycore == "mpas") then
  set res="mpasa480_mpasa480"
  if ($mach == "cheyenne") then
    set pecount="144"    
  else
    set pecount="144"
  endif
endif
if ($dycore == "fv") then
  set res="f09_f09_mg17"
  set pecount="144"
endif
if ($dycore == "se") then
  set res="ne16_ne16_mg17"
  set pecount="240"
endif  
if ($dycore == "cslam") then
  set res="ne16pg3_ne16pg3_mg17"
  set pecount="240"
endif  
set stopoption="nsteps"
set steps="15"
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
  set compiler="nag"
endif

#set caze=ebudget_${cset}_${res}_${pecount}_${steps}${stopoption}
#set caze=ebudget_ifdef_camdev_${cset}_${res}
set caze=${src}_nocamdev_${cset}_${res}

$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime $wall --pecount $pecount   --compiler $compiler --project $proj --walltime $wall  --run-unsupported

cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
if ($mach != "cheyenne") then
  ./xmlchange DEBUG=TRUE #otherwise NAG error
endif
if ($dycore == "mpas") then
  #
  # no inic with u,v,T etc. for mpas so starting from anaytical intial condition
  #
  ./xmlchange --append CAM_CONFIG_OPTS="-phys cam_dev -analytic_ic"
else
#  ./xmlchange --append CAM_CONFIG_OPTS="-phys cam_dev"
endif
#./xmlchange --append CAM_CONFIG_OPTS="-phys cam_dev  -cppdefs -Dphl_cam_development"
./xmlchange ROF_NCPL=48 #fix nuopc bug when only running a couple of time-steps

./case.setup

echo "thermo_budget_history = .true."           >> user_nl_cam
echo "thermo_budget_histfile_num = 2"           >> user_nl_cam


echo "inithist = 'ENDOFRUN'"                                               >> user_nl_cam
echo "avgflag_pertape(1) = 'A'"                                            >> user_nl_cam
echo "avgflag_pertape(2) = 'A'"                                            >> user_nl_cam
echo "avgflag_pertape(3) = 'A'"                                            >> user_nl_cam
echo "nhtfrq = 1,1,1"                                                      >> user_nl_cam
echo "history_amwg = .false."                                              >> user_nl_cam
echo "state_debug_checks           = .true."                               >> user_nl_cam
echo "fincl1 = 'PS','PSDRY','PSL','OMEGA500','OMEGA850','PRECT'"           >> user_nl_cam  
if ($dycore == "mpas") then
  if ($mach == "cheyenne") then
    echo "ncdata = '/glade/p/cesmdata/inputdata/atm/cam/inic/mpas/mpasa480_L32_notopo_grid_c201125.nc'" >> user_nl_cam
  else
    echo "ncdata = '/fs/cgd/csm/inputdata/atm/cam/inic/mpas/mpasa480_L32_notopo_grid_c201125.nc'"  >> user_nl_cam
  endif
  echo "analytic_ic_type = 'moist_baroclinic_wave_dcmip2016'"              >> user_nl_cam
endif
if ($dycore == "se" || $dycore == "cslam") then
    echo "interpolate_output = .true.,.true.,.true."                       >> user_nl_cam
    echo "se_statefreq       = 1"                                          >> user_nl_cam
    echo "se_statediag_numtrac = 99"                                       >> user_nl_cam
    
    echo "!"                                                               >> user_nl_cam
    echo "! for energy consistency"                                        >> user_nl_cam
    echo "!"                                                               >> user_nl_cam
    echo "se_ftype     = 1"                                                >> user_nl_cam
    echo "print_energy_errors = .true."                                    >> user_nl_cam
#    echo "se_lcp_moist =  .false."                                         >> user_nl_cam
#    echo "water_species_in_air = 'Q'"                                      >> user_nl_cam
endif
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

qsub -X -I get_compute
#  ./case.build
#./case.submit
endif  


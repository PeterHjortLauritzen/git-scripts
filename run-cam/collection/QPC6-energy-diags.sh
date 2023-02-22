#!/bin/tcsh
setenv PBS_ACCOUNT P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
#
# On Izumi with NAG a clean build takes about 28 minutes!
#
#set src="ebudget_dev_update" #cam6_3_072_ebudget_dev_update"
set src="ebudget_dev_update"
#set mach="cheyenne"
set mach="izumi"
set cset="QPC6"
#set dycore = "mpas"
#set dycore = "se"
set dycore = "cslam"
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
set wall="00:20:00"
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
set caze=ebudget_latest_${cset}_${res}

$homedir/$USER/src/$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime 00:05:00 --pecount $pecount   --compiler $compiler --project $proj --walltime $wall  --run-unsupported

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
  ./xmlchange --append CAM_CONFIG_OPTS="-phys cam_dev"
endif
#./xmlchange --append CAM_CONFIG_OPTS="-phys cam_dev  -cppdefs -Dphl_cam_development"
./xmlchange ROF_NCPL=48 #fix nuopc bug when only running a couple of time-steps

./case.setup

echo "thermo_budget_history = .true."           >> user_nl_cam
echo "thermo_budget_histfile_num = 2"           >> user_nl_cam
echo "thermo_budget_averaging_option = 'NSTEP'" >> user_nl_cam # ENDOFRUN,NSTEP,NDAY,NMONTH,NYEAR
echo "thermo_budget_averaging_n = 1"            >> user_nl_cam # some integer number of steps/days/months/etc.


echo "inithist = 'ENDOFRUN'"                                               >> user_nl_cam
echo "EMPTY_HTAPES=.true."                                                 >> user_nl_cam
echo "avgflag_pertape(1) = 'A'"                                            >> user_nl_cam
echo "avgflag_pertape(2) = 'A'"                                            >> user_nl_cam
echo "avgflag_pertape(3) = 'A'"                                            >> user_nl_cam
echo "nhtfrq = 1,1,1"                                                      >> user_nl_cam
echo "state_debug_checks           = .true."                               >> user_nl_cam
echo "fincl1 = 'PS','PSDRY','PSL','OMEGA500','OMEGA850','PRECT'"           >> user_nl_cam  
echo "fincl2 =   'WV_phBF','WL_phBF','WI_phBF','SE_phBF','KE_phBF', "      >> user_nl_cam 
echo "           'WV_phBP','WL_phBP','WI_phBP','SE_phBP','KE_phBP',"       >> user_nl_cam  
echo "           'WV_phAP','WL_phAP','WI_phAP','SE_phAP','KE_phAP',"       >> user_nl_cam  
echo "           'WV_phAM','WL_phAM','WI_phAM','SE_phAM','KE_phAM',"       >> user_nl_cam


if ($dycore == "mpas") then
  echo "          'WV_dBF' ,'WL_dBF' ,'WI_dBF' ,'SE_dBF' ,'KE_dBF' ,"      >> user_nl_cam
  echo "          'WV_dAP' ,'WL_dAP' ,'WI_dAP' ,'SE_dAP' ,'KE_dAP' ,"      >> user_nl_cam
  echo "          'WV_dAM' ,'WL_dAM' ,'WI_dAM' ,'SE_dAM' ,'KE_dAM'"        >> user_nl_cam
  if ($mach == "cheyenne") then
    echo "ncdata = '/glade/p/cesmdata/inputdata/atm/cam/inic/mpas/mpasa480_L32_notopo_grid_c201125.nc'" >> user_nl_cam
  else
    echo "ncdata = '/fs/cgd/csm/inputdata/atm/cam/inic/mpas/mpasa480_L32_notopo_grid_c201125.nc'"  >> user_nl_cam
  endif
  echo "analytic_ic_type = 'moist_baroclinic_wave_dcmip2016'"              >> user_nl_cam
endif
if ($dycore == "se" || $dycore == "cslam") then
    echo "           'WV_dyBF','WL_dyBF','WI_dyBF','SE_dyBF','KE_dyBF',"   >> user_nl_cam  
    echo "           'WV_dyBP','WL_dyBP','WI_dyBP','SE_dyBP','KE_dyBP',"   >> user_nl_cam  
    echo "           'WV_dyAP','WL_dyAP','WI_dyAP','SE_dyAP','KE_dyAP',"   >> user_nl_cam  
    echo "           'WV_dyAM','WL_dyAM','WI_dyAM','SE_dyAM','KE_dyAM',"   >> user_nl_cam 
    echo "           'WV_dBF','WL_dBF','WI_dBF','SE_dBF','KE_dBF',"        >> user_nl_cam
    echo "           'WV_dED','WL_dED','WI_dED','SE_dED','KE_dED',"        >> user_nl_cam
    echo "           'WV_dAD','WL_dAD','WI_dAD','SE_dAD','KE_dAD',"        >> user_nl_cam
    echo "           'WV_dAF','WL_dAF','WI_dAF','SE_dAF','KE_dAF',"        >> user_nl_cam
    echo "           'WV_dBD','WL_dBD','WI_dBD','SE_dBD','KE_dBD',"        >> user_nl_cam
    echo "           'WV_dAR','WL_dAR','WI_dAR','SE_dAR','KE_dAR',"        >> user_nl_cam
    echo "           'WV_dAH','WL_dAH','WI_dAH','SE_dAH','KE_dAH',"        >> user_nl_cam
    echo "           'WV_dBH','WL_dBH','WI_dBH','SE_dBH','KE_dBH',"        >> user_nl_cam
    echo "           'WV_dCH','WL_dCH','WI_dCH','SE_dCH','KE_dCH',"        >> user_nl_cam
    echo "           'WV_dAS','WL_dAS','WI_dAS','SE_dAS','KE_dAS',"        >> user_nl_cam
    echo "           'WV_dBS','WL_dBS','WI_dBS','SE_dBS','KE_dBS'"         >> user_nl_cam
    
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
echo "fincl3 = 'BP_phy_params'"                                            >> user_nl_cam
if ($mach == "cheyenne") then
  qcmd -A $proj -- ./case.build 
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
endif  
#./case.submit

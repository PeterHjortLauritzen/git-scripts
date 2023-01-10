#!/bin/tcsh
setenv PBS_ACCOUNT "P93300642"
#
# P93300642
#
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="/glade/u/home/pel/src/CAM"
set cset="F2000climo"
set NTHRDS="1"
set res="ne30_ne30_mg17" 
set stopoption="nmonths"
set steps="2"
echo "setting up for Cheyenne"
set scratch="/glade/scratch"
set queue="premium"
set pecount="1800" 
set walltime="02:00:00"
set machine="cheyenne"  
set compiler="intel"

setenv pw `pwd`

set caze=check_energy
$src/cime/scripts/create_newcase --case $scratch/$USER/$caze --compset $cset --res $res  --q $queue --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --compiler $compiler --machine $machine --run-unsupported

cd $scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./xmlchange REST_N=2
./xmlchange REST_OPTION=nmonths
./xmlchange NTHRDS=$NTHRDS
./xmlquery CASEROOT
./case.setup

echo "se_nu_top = 0.5E5  ">>user_nl_cam
echo "interpolate_output = .true.,.false.,.false.,.false." >> user_nl_cam 
echo "interpolate_nlat = 192,192,192"               >> user_nl_cam
echo "interpolate_nlon = 288,288,288"               >> user_nl_cam
echo "nhtfrq = 0,0,0,0" >> user_nl_cam
echo "ndens              = 2,1,2,2                                            ">> user_nl_cam
    echo "avgflag_pertape(1) = 'A'"                                                    >> user_nl_cam
    echo "avgflag_pertape(2) = 'A'"                                                    >> user_nl_cam
    echo "avgflag_pertape(3) = 'A'"                                                    >> user_nl_cam
  echo "fincl1 = 'PS','T','Z3','U','V','OMEGA','PHIS','OMEGA500','OMEGA850','PSL','PHIS','U200','EFIX'">> user_nl_cam
  echo "fincl2 =   'WV_pBF','WL_pBF','WI_pBF','SE_pBF','KE_pBF',  ">> user_nl_cam
  echo "           'WV_pBP','WL_pBP','WI_pBP','SE_pBP','KE_pBP',  ">> user_nl_cam
  echo "           'WV_pAP','WL_pAP','WI_pAP','SE_pAP','KE_pAP',  ">> user_nl_cam
  echo "           'WV_pAM','WL_pAM','WI_pAM','SE_pAM','KE_pAM',  ">> user_nl_cam
  echo "           'WV_dED','WL_dED','WI_dED','SE_dED','KE_dED',  ">> user_nl_cam
  echo "           'WV_dAF','WL_dAF','WI_dAF','SE_dAF','KE_dAF',  ">> user_nl_cam
  echo "           'WV_dBD','WL_dBD','WI_dBD','SE_dBD','KE_dBD',  ">> user_nl_cam
  echo "           'WV_dAD','WL_dAD','WI_dAD','SE_dAD','KE_dAD',  ">> user_nl_cam
  echo "           'WV_dAR','WL_dAR','WI_dAR','SE_dAR','KE_dAR',  ">> user_nl_cam
  echo "           'WV_dBF','WL_dBF','WI_dBF','SE_dBF','KE_dBF',  ">> user_nl_cam
  echo "           'WV_dBH','WL_dBH','WI_dBH','SE_dBH','KE_dBH',  ">> user_nl_cam
  echo "           'WV_dCH','WL_dCH','WI_dCH','SE_dCH','KE_dCH',  ">> user_nl_cam
  echo "           'WV_dAH','WL_dAH','WI_dAH','SE_dAH','KE_dAH',  ">> user_nl_cam
  echo "           'WV_dBS','WL_dBS','WI_dBS','SE_dBS','KE_dBS',  ">> user_nl_cam
  echo "           'WV_dAS','WL_dAS','WI_dAS','SE_dAS','KE_dAS'   ">> user_nl_cam

#cp $pw/src.cam/*.F90 SourceMods/src.cam/
qcmd -- ./case.build
./case.submit


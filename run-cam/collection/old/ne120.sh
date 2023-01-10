#!/bin/tcsh
#setenv PBS_ACCOUNT "P03010039"
setenv PBS_ACCOUNT NACM0003
# P03010039
# P93300042
# P03010083
# P93300075
# P05010048
# P93300642
#
# source code (assumed to be in /glade/u/home/$USER/src)
#
set src="opt-se-cslam-new"
#set src="trunk"
set res="ne120pg3_ne120pg3_mt13"
set cset="F2000climo"
set walltime="12:00:00"
#
# 900, 1800, 2700, 5400 (pecount should divide 6*30*30 evenly)
#
set pecount="5400"
set NTHRDS="1"
set stopoption="nmonths"
set steps="6"
set caze=HiResMIPnew

/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $cset --res $res  --q regular --walltime $walltime --pecount $pecount  --project $PBS_ACCOUNT --run-unsupported
cd /glade/scratch/$USER/$caze
./xmlchange STOP_OPTION=$stopoption,STOP_N=$steps
./xmlchange DOUT_S=FALSE
./case.setup
  echo "se_statefreq       = 512"        >> user_nl_cam
  echo "fincl1            = 'PS','PSDRY','PSL','OMEGA','OMEGA500','OMEGA850','PRECL','PRECC',     ">> user_nl_cam
  echo "                    'PTTEND','ABS_dPSdt'                                                  ">> user_nl_cam
  echo "fincl2            = 'PS','PSL','UBOT','VBOT','PRECC','PRECL','PRECT','TAUGWX','TAUGWY',   ">> user_nl_cam
  echo "                    'TAUX','TAUY','TS'                                                    ">> user_nl_cam #TKE
  echo "fincl3            = 'PS','U','V','OMEGA','T','Q','Z3','CLOUD'                             ">> user_nl_cam
  echo "fincl4            = 'PSL','T200','T500','U850','UBOT','V850','VBOT'                       ">> user_nl_cam

#  echo "fincl5 =   'WV_pBF','WL_pBF','WI_pBF','SE_pBF','KE_pBF', ">> user_nl_cam 
#  echo "           'WV_pBP','WL_pBP','WI_pBP','SE_pBP','KE_pBP', ">> user_nl_cam
#  echo "           'WV_pAP','WL_pAP','WI_pAP','SE_pAP','KE_pAP', ">> user_nl_cam
#  echo "           'WV_pAM','WL_pAM','WI_pAM','SE_pAM','KE_pAM', ">> user_nl_cam
#  echo "           'WV_dED','WL_dED','WI_dED','SE_dED','KE_dED', ">> user_nl_cam
#  echo "           'WV_dAF','WL_dAF','WI_dAF','SE_dAF','KE_dAF', ">> user_nl_cam
#  echo "           'WV_dBB','WL_dBB','WI_dBB','SE_dBB','KE_dBB', ">> user_nl_cam
#  echo "           'WV_dBD','WL_dBD','WI_dBD','SE_dBD','KE_dBD', ">> user_nl_cam
#  echo "           'WV_dBK','WL_dBK','WI_dBK','SE_dBK','KE_dBK', ">> user_nl_cam
#  echo "           'WV_dAK','WL_dAK','WI_dAK','SE_dAK','KE_dAK', ">> user_nl_cam
#  echo "           'WV_dAD','WL_dAD','WI_dAD','SE_dAD','KE_dAD', ">> user_nl_cam
#  echo "           'WV_dAR','WL_dAR','WI_dAR','SE_dAR','KE_dAR', ">> user_nl_cam
#  echo "           'WV_dBF','WL_dBF','WI_dBF','SE_dBF','KE_dBF', ">> user_nl_cam
#  echo "           'WV_dBH','WL_dBH','WI_dBH','SE_dBH','KE_dBH', ">> user_nl_cam
#  echo "           'WV_dCH','WL_dCH','WI_dCH','SE_dCH','KE_dCH', ">> user_nl_cam
#  echo "           'WV_dAH','WL_dAH','WI_dAH','SE_dAH','KE_dAH', ">> user_nl_cam
#  echo "           'WV_dBS','WL_dBS','WI_dBS','SE_dBS','KE_dBS', ">> user_nl_cam
#  echo "           'WV_dAS','WL_dAS','WI_dAS','SE_dAS','KE_dAS', ">> user_nl_cam
#  echo "           'WV_p2d','WL_p2d','WI_p2d','SE_p2d','KE_p2d', ">> user_nl_cam
#  echo "           'WV_PDC','WL_PDC','WI_PDC'                    ">> user_nl_cam

#	echo "fincl1 =   'WV_pBF','WL_pBF','WI_pBF','SE_pBF','KE_pBF', ">> user_nl_cam
#	echo "           'WV_pBP','WL_pBP','WI_pBP','SE_pBP','KE_pBP', ">> user_nl_cam
#	echo "           'WV_pAP','WL_pAP','WI_pAP','SE_pAP','KE_pAP', ">> user_nl_cam
#	echo "           'WV_pAM','WL_pAM','WI_pAM','SE_pAM','KE_pAM', ">> user_nl_cam
#	echo "           'WV_dED','WL_dED','WI_dED','SE_dED','KE_dED', ">> user_nl_cam
#	echo "           'WV_dAF','WL_dAF','WI_dAF','SE_dAF','KE_dAF', ">> user_nl_cam
#	echo "           'WV_dBD','WL_dBD','WI_dBD','SE_dBD','KE_dBD', ">> user_nl_cam
#	echo "           'WV_dAD','WL_dAD','WI_dAD','SE_dAD','KE_dAD', ">> user_nl_cam
#	echo "           'WV_dAR','WL_dAR','WI_dAR','SE_dAR','KE_dAR', ">> user_nl_cam
#	echo "           'WV_dBF','WL_dBF','WI_dBF','SE_dBF','KE_dBF', ">> user_nl_cam
#	echo "           'WV_dBH','WL_dBH','WI_dBH','SE_dBH','KE_dBH', ">> user_nl_cam
#	echo "           'WV_dCH','WL_dCH','WI_dCH','SE_dCH','KE_dCH', ">> user_nl_cam
#	echo "           'WV_dAH','WL_dAH','WI_dAH','SE_dAH','KE_dAH', ">> user_nl_cam
#	echo "           'WV_p2d','WL_p2d','WI_p2d','SE_p2d','KE_p2d', ">> user_nl_cam
#	echo "           'WV_PDC','WL_PDC','WI_PDC'                    ">> user_nl_cam

  
    
  echo "avgflag_pertape(1) = 'A'"                                                    >> user_nl_cam
  echo "avgflag_pertape(2) = 'I'"                                                    >> user_nl_cam
  echo "avgflag_pertape(3) = 'I'"                                                    >> user_nl_cam
  echo "avgflag_pertape(4) = 'I'"                                                    >> user_nl_cam
  echo "avgflag_pertape(5) = 'A'"                                                    >> user_nl_cam
  echo "nhtfrq             = 0,-3,-6,-6,0                                          ">> user_nl_cam
  echo "interpolate_output = .true.,.false.,.false.,.true.,.false."               	   >> user_nl_cam
  echo "ndens              = 2,2,2,2,1                                               ">> user_nl_cam
  echo "inithist = 'YEARLY'"     >> user_nl_cam
  echo "interpolate_nlat = 720"  >> user_nl_cam
  echo "interpolate_nlon = 1440" >> user_nl_cam
./xmlchange REST_N=6
./xmlchange REST_OPTION=nmonths
qcmd -- ./case.build
./case.submit

#!/bin/tcsh
if ( "$#argv" != 2) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 is namelist file name"
  echo "  -arg 2 is is fincl, for example, fincl2"
  exit
endif
set n = 1
set fname = "$argv[$n]"
set n = 2
set fincl = "$argv[$n]"

echo 'echo "'$fincl' = '\''WV_pBF'\'','\''WL_pBF'\'','\''WI_pBF'\'','\''SE_pBF'\'','\''KE_pBF'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''WV_pBP'\'','\''WL_pBP'\'','\''WI_pBP'\'','\''SE_pBP'\'','\''KE_pBP'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''WV_pAP'\'','\''WL_pAP'\'','\''WI_pAP'\'','\''SE_pAP'\'','\''KE_pAP'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''WV_pAM'\'','\''WL_pAM'\'','\''WI_pAM'\'','\''SE_pAM'\'','\''KE_pAM'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''WV_dED'\'','\''WL_dED'\'','\''WI_dED'\'','\''SE_dED'\'','\''KE_dED'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''WV_dAF'\'','\''WL_dAF'\'','\''WI_dAF'\'','\''SE_dAF'\'','\''KE_dAF'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''WV_dBD'\'','\''WL_dBD'\'','\''WI_dBD'\'','\''SE_dBD'\'','\''KE_dBD'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''WV_dAD'\'','\''WL_dAD'\'','\''WI_dAD'\'','\''SE_dAD'\'','\''KE_dAD'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''WV_dAR'\'','\''WL_dAR'\'','\''WI_dAR'\'','\''SE_dAR'\'','\''KE_dAR'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''WV_dBF'\'','\''WL_dBF'\'','\''WI_dBF'\'','\''SE_dBF'\'','\''KE_dBF'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''WV_dBH'\'','\''WL_dBH'\'','\''WI_dBH'\'','\''SE_dBH'\'','\''KE_dBH'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''WV_dCH'\'','\''WL_dCH'\'','\''WI_dCH'\'','\''SE_dCH'\'','\''KE_dCH'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''WV_dAH'\'','\''WL_dAH'\'','\''WI_dAH'\'','\''SE_dAH'\'','\''KE_dAH'\'', ">> user_nl_cam'>> $fname
#
# noise diagnostic
#
#echo 'echo "         '\''ABS_dPSdt'\''"                                                    >> user_nl_cam' >> $fname
#
# PDC diag
#
#'\''WV_PDC'\'','\''WI_PDC'\'','\''WL_PDC'\'',
#echo "Energy diagnostics added to"$fname
#echo "REMEMBER TO SET ndens=2 (DOUBLE-PRECISION) AND DO NOT INTERPOLATE OUTPUT"
#echo "DONE"

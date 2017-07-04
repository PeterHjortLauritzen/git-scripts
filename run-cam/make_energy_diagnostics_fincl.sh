#!/bin/tcs
if ( "$#argv" <4) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 is namelist file name"
  echo "  -arg 2 is is fincl, for example, fincl2"
  echo "  -arg 3 is wet=true or false"
  echo "  -arg 4 (optional) is fincl for axial angular momentum diagnostics"
  exit
endif
set n = 1
set fname = "$argv[$n]"
set n = 2
set fincl = "$argv[$n]"
set n = 3
set wet = "$argv[$n]"
if ($wet == "true") then
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
echo 'echo "           '\''WV_dAH'\'','\''WL_dAH'\'','\''WI_dAH'\'','\''SE_dAH'\'','\''KE_dAH'\''  ">> user_nl_cam'>> $fname
else
#echo 'echo "'$fincl' = '\''SE_pBF'\'','\''KE_pBF'\'', ">> user_nl_cam'>> $fname
#echo 'echo "           '\''SE_pBP'\'','\''KE_pBP'\'', ">> user_nl_cam'>> $fname
#echo 'echo "           '\''SE_pAP'\'','\''KE_pAP'\'', ">> user_nl_cam'>> $fname
#echo 'echo "           '\''SE_pAM'\'','\''KE_pAM'\'', ">> user_nl_cam'>> $fname
echo 'echo "'$fincl' = '\''SE_dED'\'','\''KE_dED'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''SE_dAF'\'','\''KE_dAF'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''SE_dBD'\'','\''KE_dBD'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''SE_dAD'\'','\''KE_dAD'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''SE_dAR'\'','\''KE_dAR'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''SE_dBF'\'','\''KE_dBF'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''SE_dBH'\'','\''KE_dBH'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''SE_dCH'\'','\''KE_dCH'\'', ">> user_nl_cam'>> $fname
echo 'echo "           '\''SE_dAH'\'','\''KE_dAH'\''  ">> user_nl_cam'>> $fname
endif

if ( "$#argv" == 4) then
  set n = 4
  set fincl2 = "$argv[$n]"
  echo 'echo "'$fincl2' ='\''MR_dED'\'','\''MO_dED'\'',">> user_nl_cam'>> $fname
  echo 'echo "           '\''MR_dAF'\'','\''MO_dAF'\'',">> user_nl_cam'>> $fname
  echo 'echo "           '\''MR_dBD'\'','\''MO_dBD'\'',">> user_nl_cam'>> $fname
  echo 'echo "           '\''MR_dAD'\'','\''MO_dAD'\'',">> user_nl_cam'>> $fname
  echo 'echo "           '\''MR_dAR'\'','\''MO_dAR'\'',">> user_nl_cam'>> $fname
  echo 'echo "           '\''MR_dBF'\'','\''MO_dBF'\'',">> user_nl_cam'>> $fname
  echo 'echo "           '\''MR_dBH'\'','\''MO_dBH'\'',">> user_nl_cam'>> $fname
  echo 'echo "           '\''MR_dCH'\'','\''MO_dCH'\'',">> user_nl_cam'>> $fname
  echo 'echo "           '\''MR_dAH'\'','\''MO_dAH'\'' ">> user_nl_cam'>> $fname
endif


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

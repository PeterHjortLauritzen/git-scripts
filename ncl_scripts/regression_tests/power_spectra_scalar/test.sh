#!/bin/tcsh
echo "First interpolate date to lat-lon grid"
set pwd = $PWD
source ../../interp_se_to_latlon.sh $pwd/inputdata ne16np4_nc3000_Co120_Fi001_PF_nullRR_Nsw084_20171012.nc
echo "Produce power spectrum"
source ../../power_spectra_scalar.sh  ne16np4_nc3000_Co120_Fi001_PF_nullRR_Nsw084_20171012.nc.bilinear_to_nlon360xnlat180.nc PHIS

#!/bin/tcsh
echo "First interpolate date to lat-lon grid"
source ../../interp_se_to_latlon.sh inputdata ne30pg3_nc3000_Co060_Fi001_PF_nullRR_Nsw042_20171014.nc 
echo "Produce power spectrum"
source ../../power_spectra_scalar.sh  ne30pg3_nc3000_Co060_Fi001_PF_nullRR_Nsw042_20171014.nc.bilinear_to_nlon360xnlat180.nc PHIS

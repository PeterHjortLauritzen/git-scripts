#!/bin/tcsh
#
# 9/1/2022
#
# This script is experimental!
#
# The setup is for running the L83 model (~80km top) using the latest
# cam_development code:
#
# Steps:
#
# 1. git clone https://github.com/ESCOMP/CAM cam
# 2. cd cam
# 3. git checkout cam_development
# 4. ./manage_externals/checkout_externals
# 5. Edit line below executing create_newcase to your source code location
# 6. source L83.sh
#
setenv short "T"
unset proj
setenv proj "P93300642"
#setenv proj "P03010039"
unset src
setenv src "cam_development"
unset res
setenv res "f09_f09_mg17"
unset comp
setenv comp "HIST_CAM60%WCSC_CLM50%BGC-CROP_CICE%PRES_DOCN%DOM_MOSART_SGLC_SWAV"
# Isla used  1850_CAM60_CLM50%BGC-CROP-CMIP6DECK_CICE%CMIP6_POP2%ECO%ABIO-DIC_MOSART_CISM2%NOEVOLVE_WW3_BGC%BDRD
unset wall
unset pes
if ($short == "T") then
  echo "Short run"
  setenv pes "450"
  setenv wall "00:20:00"
else
  setenv pes "1800"
  setenv wall "02:30:00"
endif
unset drv
setenv drv "nuopc"
#
# for nuopc
#
module load python/3.7.9
ncar_pylib

unset caze
if ($short == "T") then
  setenv caze ${src}_${res}_${pes}_short
else
  setenv caze ${src}_${res}_${pes}_long
endif
/glade/u/home/pel/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $comp --res $res --driver $drv --walltime $wall --mach cheyenne --pecount $pes --project $proj --compiler intel --queue regular --run-unsupported

cd /glade/scratch/$USER/$caze 
#./xmlchange REST_N=12
#./xmlchange REST_OPTION=nmonths
./xmlchange NTHRDS=1
if ($short == "T") then
  ./xmlchange STOP_OPTION=ndays
  ./xmlchange STOP_N=1
else
  ./xmlchange STOP_OPTION=ndays
  ./xmlchange STOP_N=60
endif

./xmlchange --append CAM_CONFIG_OPTS="-phys cam_dev -chem waccm_sc_mam4 -nlev 83"
#./xmlchange RUN_STARTDATE=1979-01-01
./xmlchange DOUT_S=FALSE

echo "ncdata = '/glade/p/cgd/amp/pel/inic/b.e21.B1850.f09_g17.L83_cam6.001.cam.i.0106-01-01-00000.nc'" >>user_nl_cam
#
# settings from Isla' setup
#
echo "effgw_beres_dp         = 0.90D0"           >>user_nl_cam
echo "gw_qbo_hdepth_scaling  = 0.25D0"           >>user_nl_cam
echo "qbo_use_forcing        = .false."          >>user_nl_cam
echo "frontgfc               = 2.7D-15"          >>user_nl_cam
echo "taubgnd                = 2.5D-3"           >>user_nl_cam
echo "effgw_rdg_beta = 0.75D0"                   >>user_nl_cam
echo "effgw_rdg_beta_max = 0.75D0"               >>user_nl_cam
#
# upper boundary setting
#
echo "tau_0_ubc=.true."                          >>user_nl_cam
echo "ubc_specifier = 'Q->2.d-10vmr'"            >>user_nl_cam
#
# Dan Marsh on the above constant UBC setting: 
#
# While this is OK for testing, I recall Mike made a climatology netcdf file of WACCM fields that 
# would be better to use. Francis added this as an option. Hopefully it is monthly mean data and 
# you can have a proper seasonal cycle of water vapor near the mesopause.
#
# Mike's UBC file has monthly means starting in 1950.  To cycle over year.200 use these settings:
#
#ubc_specifier = 'Q:H2O->UBC_FILE'
#ubc_file_path = '$DIN_LOC_ROOT/atm/cam/chem/ubc/f.e21.FWHISTBgcCrop.f09_f09_mg17.CMIP6-AMIP-WACCM.ensAvg123.cam.h0zm.UBC.195001-201412_c220322.nc'
#ubc_file_input_type = 'CYCLICAL'
#ubc_file_cycle_yr  = 2000

#
#!---additional gravity wave settings to make it look like SC-WACCM
#
echo "gw_apply_tndmax          = .false."        >>user_nl_cam
echo "gw_limit_tau_without_eff = .true."         >>user_nl_cam
echo "gw_lndscl_sgh            = .false."        >>user_nl_cam
echo "gw_oro_south_fac         = 2.d0"           >>user_nl_cam


echo "do_circulation_diags=.true."               >>user_nl_cam
#
# dycore settings
#
echo "fv_nsplit   =            16"               >>user_nl_cam
echo "fv_nspltrac =            8"                >>user_nl_cam
echo "fv_nspltvrm =            8"                >>user_nl_cam
#
# I/O settings
#
echo "mfilt  = 0,5,20,40,120,240,365,73,365"               >>user_nl_cam
echo "nhtfrq = 0, -24,-6,-3,-1,1,-24,-24"                  >>user_nl_cam
echo "fexcl1 = ' '  "                                      >>user_nl_cam
echo "fincl1 = 'U','V','Q','T','PSL','OMEGA','PS','PRECC','PRECL','UTGWORO','VTGWORO',"                            >>user_nl_cam
echo "         'TS', 'TAUX','TAUY','TAUBLJX','TAUBLJY','TAUGWX','TAUGWY','FLNT','FLNS','FSNS','FSNT',"             >>user_nl_cam
echo "         'LHFLX','SHFLX','TMQ','FLDS','FSDS','FSDSC','SWCF','LWCF','PRECSC','PRECSL',  'DTCOND','Z3', 'PSL'" >>user_nl_cam
echo "         'PBLH','ZMDT', 'ZMDT', 'STEND_CLUBB','RVMTEND_CLUBB','FREQZM' "                                     >>user_nl_cam
echo "fincl2 = 'TROP_T', 'TROP_P', 'Q', 'T','U850','V850','U200','V200','PRECT','PRECC','PRECL','PBLH',"           >>user_nl_cam
echo "         'OMEGA500','FLUT','Z500','T500','PS','PMID:I','TREFHTMN:M', 'TREFHTMX:X','TSMN:M', 'TSMX:X',"       >>user_nl_cam
echo "         'PBLH','ZMDT', 'ZMDT', 'STEND_CLUBB','RVMTEND_CLUBB',"                                              >>user_nl_cam
echo "         'PRECT','PRECL','U200','V200','U850','V850','FLUT','Z500','TREFHT','TS','CLDTOT','SWCF',"           >>user_nl_cam
echo "         'LWCF','PS','PSL','TMQ','LHFLX','SHFLX','T500','OMEGA500','CLDLOW'"                                 >>user_nl_cam
echo "fincl3 = 'U:I','V:I','T:I', 'OMEGA:I','PS:I','PMID:I', 'OMEGA500','PRECT','U200','U850','FLUT'"              >>user_nl_cam
echo "fincl4 = 'PRECT','PRECC'"                                                                                    >>user_nl_cam
echo "fincl8 = 'Z3:I','U850:I','V850:I','Z500:I','PS:I', 'PMID:I'"  


./case.setup
qcmd -- ./case.build
./case.submit

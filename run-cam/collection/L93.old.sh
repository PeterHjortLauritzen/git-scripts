#!/bin/tcsh
#
# 8/17/2022
#
# This script is experimental!
#
# The setup is for running the L93 model (~80km top) using the latest
# cam_development code (as of 8/16/2022):
#
# Steps:
#
# 1. git clone https://github.com/ESCOMP/CAM cam
# 2. cd cam
# 3. git checkout cam_development
# 4. ./manage_externals/checkout_externals
# 5. Edit line below executing create_newcase to your source code location
# 6. source L93.sh
#
# NOTE:
#
# The code for better upper boundary conditions is not on cam_development
# yet so the code is currently using a kluge that was used about a year
# ago by the AMP group.
#
setenv short "T"
unset proj
setenv proj "P93300642"
#setenv proj "P03010039"
unset src
setenv src "cam_development"
unset res
setenv res "ne30pg3_ne30pg3_mg17"
unset comp
setenv comp "HIST_CAM60%WCSC_CLM50%BGC-CROP_CICE%PRES_DOCN%DOM_MOSART_SGLC_SWAV"

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
/glade/scratch/pel/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $comp --res $res --driver $drv --walltime $wall --mach cheyenne --pecount $pes --project $proj --compiler intel --queue regular --run-unsupported

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

./xmlchange --append CAM_CONFIG_OPTS="-phys cam_dev -chem waccm_sc_mam4 -cppdefs -Dwaccm_debug -nlev 93"
./xmlchange RUN_STARTDATE=1979-01-01
./xmlchange DOUT_S=FALSE

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
echo "fincl8 = 'Z3:I','U850:I','V850:I','Z500:I','PS:I', 'PMID:I'"                                                 >>user_nl_cam

echo "interpolate_output = .true.,.true.,.true.,.true." >>user_nl_cam
echo "interpolate_nlat = 192,192,192,192"               >>user_nl_cam
echo "interpolate_nlon = 288,288,288,288"               >>user_nl_cam


if ($short == "T") then
  echo "se_statefreq       = 1"          >>user_nl_cam
else
  echo "se_statefreq       = 144"        >>user_nl_cam
endif

#se_nu_top = 1.25e5
echo "ncdata = '/glade/p/cesm/amwg_dev/juliob/FWsc_ne30pg3_93L_GRID_83L_10BL_Top_86km.nc'">>user_nl_cam
echo "tau_0_ubc = .true."                >>user_nl_cam
echo "qbo_use_forcing = .false."         >>user_nl_cam
echo "se_nsplit=3"                       >>user_nl_cam
echo "se_rsplit=6"                       >>user_nl_cam
echo "se_hypervis_subcycle=3"            >>user_nl_cam

#
# temporary (unphysical) fix
#
# When PR for this is done: In the UBC specifier code you would simply include 'Q->2.e-8vmr' (or whatever value is appropriate at the top of the L93 model) in the ubc_specifier namelist option. 
# Contact: F.Vitt (NCAR)
#
cp /glade/u/home/pel/git-scripts/run-cam/collection/src.cam.L93/chemistry.F90 SourceMods/src.cam/

./case.setup

qcmd -- ./case.build
./case.submit

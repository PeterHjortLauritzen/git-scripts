#!/bin/tcsh
#setenv proj "P93300642"
setenv proj "P03010039"
#setenv proj "P05010048"
#setenv src "cam6_3_006"
#setenv src "cam6_3_006.upwind"
#setenv src "cam6_3_006.dev"
#setenv src "release-cesm2.2.0"
#setenv src "cam6_3_015.clubb"
#setenv src "cam6_3_015"
#setenv src "cam6_3_020.tphysac"
#setenv src "cam6_3_034.tphysac"
#setenv src "cam6_3_035.tphysac"
#setenv src "cam6_3_036.tphysac"
#setenv src "cam6_3_036"
#setenv src "cam6_3_031"
#setenv src "cam6_3_019_plus_CESM2.2"
#setenv src "cam6_2_026.pel"
#setenv src "CESM2.2-updates"
#setenv src "cam6_3_019_plus_CESM2.2"
#setenv src "cam6_3_043"
#setenv src "cam.dribble"
#setenv src "cam6_3_058.dtsens"
unset src
setenv src "cam_development"
#setenv src "debug.cam6_3_039"
#setenv res "f19_f19_mg17"
setenv res "f09_f09_mg17"
unset res
#setenv res "ne30_ne30_mg17"
#setenv res "ne30pg3_ne30pg3_mg17"
#setenv res "ne30pg2_ne30pg2_mg17"
#setenv res "T31_g37_gl4"
#setenv res "T42_T42_mg17"
#setenv res "ne0CONUSne30x8_ne0CONUSne30x8_mt12"
#setenv res "ne0ARCTICGRISne30x8_ne0ARCTICGRISne30x8_mt12"
#setenv res "ne0ARCTICne30x4_ne0ARCTICne30x4_mt12"
#setenv res "ne120pg3_ne120pg3_mt13"
#setenv res "ne30pg3_ne30pg3_mg17"
#setenv res "ne30_ne30_mg17"
#setenv comp "FHIST"
#setenv comp "F2000dev"
#setenv comp "FADIAB"
#setenv comp "2000_CAM%DEV_CLM50%SP_CICE%PRES_DOCN%DOM_MOSART_SGLC_SWAV"
#setenv comp "2000_CAM60_CLM50%SP_CICE%PRES_DOCN%DOM_MOSART_SGLC_SWAV"
#setenv comp "F2000climo"
#setenv comp "QPC4"
#setenv comp "2000_CAM50_CLM50%SP_CICE%PRES_DOCN%DOM_MOSART_CISM2%NOEVOLVE_SWAV"
#setenv comp "HIST_CAM60%WCSC_CLM50%BGC-CROP_CICE%PRES_DOCN%DOM_MOSART_CISM2%NOEVOLVE_SWAV_SIAC_SESP"
#setenv comp "HIST_CAM60%WCSC_CLM50%BGC-CROP_CICE%PRES_DOCN%DOM_MOSART_SGLC_SWAV_SIAC_SESP"
unset comp
setenv comp "HIST_CAM60%WCSC_CLM50%BGC-CROP_CICE%PRES_DOCN%DOM_MOSART_SGLC_SWAV"
unset wall
setenv wall "01:30:00"
unset pes
setenv pes "900"
unset drv
setenv drv "nuopc"

# for nuopc
module load python/3.7.9
ncar_pylib

#setenv caze ${src}_${comp}_${res}_L58dev_${drv}_${pes}pes_`date '+%y%m%d'`_test
unset caze
setenv caze bug_baseline_fv #${src}_FWscHIST_${res}_L58dev_${drv}_${pes}pes_`date '+%y%m%d'`_wexit

#/glade/u/home/$USER/src/CLUBB-MF/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $comp --res $res --walltime $wall --mach cheyenne --pecount $pes --project $proj --compiler intel --queue regular --run-unsupported
/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $comp --res $res --driver $drv --walltime $wall --mach cheyenne --pecount $pes --project $proj --compiler intel --queue regular --run-unsupported
#/glade/u/home/$USER/src/DRIBBLING/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $comp --res $res --driver $drv --walltime $wall --mach cheyenne --pecount $pes --project $proj --compiler intel --queue regular --run-unsupported
#/glade/u/home/$USER/src/$src/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $comp --res $res --driver $drv --walltime $wall --mach cheyenne --project $proj --compiler intel --queue regular --run-unsupported
#/glade/work/hannay/cesm_tags/cam6_3_019_plus_CESM2.2/cime/scripts/create_newcase --case /glade/scratch/$USER/$caze --compset $comp --res $res --driver $drv --walltime $wall --mach cheyenne --pecount $pes --project $proj --compiler intel --queue regular --run-unsupported
cd /glade/scratch/$USER/$caze 
#./xmlchange REST_N=12
#./xmlchange REST_OPTION=nmonths
./xmlchange NTHRDS=1
./xmlchange STOP_OPTION=nmonths
./xmlchange STOP_N=2
./xmlchange RESUBMIT=0
./xmlchange DOUT_S=TRUE
#./xmlchange DEBUG=FALSE
#./xmlchange REST_OPTION=nmonths
#./xmlchange TIMER_LEVEL=10

./xmlchange RUN_STARTDATE=2011-01-01
#./xmlchange RUN_STARTDATE=1990-01-01
#./xmlchange RUN_TYPE=hybrid
#./xmlchange RUN_REFCASE=f.e21.FWscHIST.ne30_L48_BL10_cam6_3_035.tphysac_reorder_zm2.001.hf2
#./xmlchange RUN_REFDATE=1990-01-01
#./xmlchange GET_REFCASE=FALSE

#./xmlchange CAM_CONFIG_OPTS='-phys cam_dev -nlev 58' --append
./xmlchange CAM_CONFIG_OPTS='-phys cam_dev -nlev 58 -chem waccm_sc_mam4 -microphys mg2'
#./xmlchange --append CAM_CONFIG_OPTS="-cppdefs -DTRACER_CHECK" 

#echo "ncdata = '/glade/p/acom/acom-climate/jzhan166/acclip/ncdata/FCnudged_f09.mam.mar27.2000_2021.001.cam.i.2011-01-01-00000.ncne0np4_58L_cdf5.nc'">>user_nl_cam
#echo "ncdata         = '/glade/scratch/jzhan166/archive/f.e21.FCnudged_58L.ne30_ne30_mg17.cam6_3_058.dtsens.2011_fvIC_wetexit/atm/hist/f.e21.FCnudged_58L.ne30_ne30_mg17.cam6_3_058.dtsens.2011_fvIC_wetexit.cam.i.2011-05-01-00000.nc'">>user_nl_cam
#echo "ncdata = '/glade/p/cesm/amwg_dev/juliob/FWsc_ne30pg3_58L_GRID_48_taperstart10km_lowtop_BL10_v3_beta1p75_Top_43km.nc'">>user_nl_cam
#echo "ncdata = '/glade/work/aherring/tmp/f.e22.FCnudged.ne30_ne30_mg17.release-cesm2.2.0_spinup.2010_2020.001.map_TO_L58.cam.i.2011-06-01-00000.nc'">>user_nl_cam
#echo "zmconv_parcel_pbl = .false.">>user_nl_cam

#echo "history_chemistry = .true.">>user_nl_cam
#echo "history_chemspecies_srf = .true.">>user_nl_cam
#echo "history_waccm = .true.">>user_nl_cam
#echo "history_aerosol = .true.">>user_nl_cam

#./xmlchange ATM_NCPL=96
#echo "se_nsplit = 2">>user_nl_cam
#echo "se_rsplit = 3">>user_nl_cam
#echo "se_hypervis_subcycle_sponge = 1">>user_nl_cam
#echo "se_hypervis_subcycle        = 4">>user_nl_cam

#echo "l_dribble_tend_into_macmic_loop = .true.">>user_nl_cam
#echo "dribble_start_step = 1">>user_nl_cam

#echo "clubb_timestep = 150.0D0">>user_nl_cam

#echo "inithist_all      = .true.                                        ">>user_nl_cam
#echo "inithist          = 'NONE'                                         ">>user_nl_cam
#echo "se_statefreq      = 144                                            ">>user_nl_cam
#echo "se_statediag_numtrac = 300                                         ">>user_nl_cam
echo "empty_htapes      = .true.                                        ">>user_nl_cam
#echo "mfilt  = 0,5,20,40,120,240,365,73,365                                                                    ">>user_nl_cam
#echo "nhtfrq =                  0, -24,  -6,  -3,  -1,   1, -24,-24                                            ">>user_nl_cam
echo "fexcl1 = ' '                                                                                             ">>user_nl_cam
echo "fincl1 = 'N2O'                                                                                           ">>user_nl_cam

#echo "fincl2 =   'WV_phBF','WL_phBF','WI_phBF','SE_phBF','KE_phBF','TT_phBF',  ">> user_nl_cam
#echo "           'WV_phBP','WL_phBP','WI_phBP','SE_phBP','KE_phBP','TT_phBP',  ">> user_nl_cam
#echo "           'WV_phAP','WL_phAP','WI_phAP','SE_phAP','KE_phAP','TT_phAP',  ">> user_nl_cam
#echo "           'WV_phAM','WL_phAM','WI_phAM','SE_phAM','KE_phAM','TT_phAM',   ">> user_nl_cam
#  echo "         'WV_dED','WL_dED','WI_dED','SE_dED','KE_dED','TT_dED',  ">> user_nl_cam
#  echo "         'WV_dAF','WL_dAF','WI_dAF','SE_dAF','KE_dAF','TT_dAF',  ">> user_nl_cam
#  echo "         'WV_dBD','WL_dBD','WI_dBD','SE_dBD','KE_dBD','TT_dBD',  ">> user_nl_cam
#  echo "         'WV_dAD','WL_dAD','WI_dAD','SE_dAD','KE_dAD','TT_dAD',  ">> user_nl_cam
#  echo "         'WV_dAR','WL_dAR','WI_dAR','SE_dAR','KE_dAR','TT_dAR',  ">> user_nl_cam
#  echo "         'WV_dBF','WL_dBF','WI_dBF','SE_dBF','KE_dBF','TT_dBF', ">> user_nl_cam
#  echo "         'WV_dBH','WL_dBH','WI_dBH','SE_dBH','KE_dBH','TT_dBH',  ">> user_nl_cam
#  echo "         'WV_dCH','WL_dCH','WI_dCH','SE_dCH','KE_dCH','TT_dCH',  ">> user_nl_cam
#  echo "         'WV_dAH','WL_dAH','WI_dAH','SE_dAH','KE_dAH','TT_dAH',  ">> user_nl_cam
#  echo "         'WV_dBS','WL_dBS','WI_dBS','SE_dBS','KE_dBS','TT_dBS',  ">> user_nl_cam
#  echo "         'WV_dAS','WL_dAS','WI_dAS','SE_dAS','KE_dAS','TT_dAS'   ">> user_nl_cam


#echo "fincl1 = 'U','V','Q','T','PSL','OMEGA','PS','PRECC','PRECL',                                             ">>user_nl_cam
#echo "         'TS', 'TAUX','TAUY','FLNT','FLNS','FSNS','FSNT',                                                ">>user_nl_cam
#echo "         'LHFLX','SHFLX','TMQ','FLDS','FSDS','FSDSC','SWCF','LWCF','PRECSC','PRECSL','DTCOND','Z3','PSL',">>user_nl_cam
#echo "         'PBLH','ZMDT', 'ZMDT', 'STEND_CLUBB','RVMTEND_CLUBB',                                           ">>user_nl_cam
#echo "         'ZMDQ','CMFMC_DP','DPDLFLIQ','DPDLFICE','PCLDTOP','CLDTOP', 'KVH_CLUBB',                        ">>user_nl_cam
#echo "         'DTCORE','DQCORE','PTEQ','DCQ','QTGW','CT_H2O','DCQ','MPDQ'                                     ">>user_nl_cam
#echo "fincl2 = 'TROP_T', 'TROP_P', 'Q', 'T','U850','V850','U200','V200','PRECT','PRECC','PRECL','PBLH',        ">>user_nl_cam
#echo "         'OMEGA500','FLUT','Z500','T500','PS','PMID:I','TREFHTMN:M', 'TREFHTMX:X','TSMN:M', 'TSMX:X',    ">>user_nl_cam
#echo "         'PBLH','ZMDT', 'ZMDT', 'STEND_CLUBB','RVMTEND_CLUBB',                                           ">>user_nl_cam
#echo "         'PRECT','PRECL','U200','V200','U850','V850','FLUT','Z500','TREFHT','TS','CLDTOT','SWCF',        ">>user_nl_cam
#echo "         'LWCF','PS','PSL','TMQ','LHFLX','SHFLX','T500','OMEGA500','CLDLOW'                              ">>user_nl_cam
#echo "fincl3 = 'U:I','V:I','T:I', 'OMEGA:I','PS:I','PMID:I', 'OMEGA500','PRECT','U200','U850','V200','V850',   ">>user_nl_cam
#echo "         'ZMDT:I','ZMDQ:I','CMFMC_DP:I','DPDLFLIQ:I','DPDLFICE:I','PCLDTOP:I','CLDTOP:I','FLUT','Q:I'   ">>user_nl_cam
#echo "         'DTCORE:I','DQCORE:I','PTEQ:I','DCQ:I','QTGW:I','CT_H2O:I','DCQ:I','MPDQ:I'                     ">>user_nl_cam
#echo "fincl4 = 'PRECT','PRECC'                                                                                 ">>user_nl_cam
#echo "fincl8 = 'Z3:I','U850:I','V850:I','Z500:I','PS:I', 'PMID:I'                                              ">>user_nl_cam
#echo "interpolate_output = .true.,.true.,.true.,.true.                                                         ">>user_nl_cam
#echo "interpolate_nlat = 192,192,192,192                                                                       ">>user_nl_cam
#echo "interpolate_nlon = 288,288,288,288                                                                       ">>user_nl_cam


echo "avgflag_pertape(1) = 'A'                                   ">>user_nl_cam
echo "avgflag_pertape(2) = 'A'                                   ">>user_nl_cam
echo "nhtfrq             =-24,0                                    ">>user_nl_cam
#echo "mfilt              = 7                                     ">>user_nl_cam
echo "ndens              = 2                                     ">>user_nl_cam
#echo "interpolate_output = .false.                                ">>user_nl_cam     
#echo "interpolate_nlat   = 192                                   ">>user_nl_cam
#echo "interpolate_nlon   = 288                                   ">>user_nl_cam

#cp /glade/u/home/aherring/src/cam6_3_039/usr_src/camdev-dqcore/* /glade/scratch/$USER/$caze/SourceMods/src.cam/
#cp /glade/p/cesmdata/cseg/runs/cesm2_0/f.e21.FWscHIST.ne30_L48_BL10_cam6_3_035.tphysac_reorder_zm2.001.hf2/SourceMods/src.cam/* /glade/scratch/$USER/$caze/SourceMods/src.cam/ 
#cp /glade/p/cesmdata/cseg/runs/cesm2_0/f.e21.FWscHIST.ne30_L48_BL10_cam6_3_035.tphysac_reorder_zm2.001.hf2/SourceMods/src.drv/* /glade/scratch/$USER/$caze/SourceMods/src.drv/

#cp /glade/u/home/aherring/src/cam6_3_043/usr_src/nuclopt/* /glade/scratch/$USER/$caze/SourceMods/src.cam/

#cp /glade/u/home/aherring/src/CLUBB-MF/cam.clubbmf.ztopm1/usr_src/dptracer/* /glade/scratch/$USER/$caze/SourceMods/src.cam/

#cp /glade/u/home/aherring/src/cam6_3_041.dtsens/usr_src/noclubbtop/* /glade/scratch/$USER/$caze/SourceMods/src.cam/

#cp /glade/u/home/aherring/src/cam6_3_058.dtsens/usr_src/emitb4turb/* /glade/scratch/$USER/$caze/SourceMods/src.cam/
#cp /glade/u/home/aherring/src/cam6_3_058.dtsens/usr_src/pardep/* /glade/scratch/$USER/$caze/SourceMods/src.cam/
#cp /glade/u/home/aherring/src/cam6_3_058.dtsens/usr_src/ustar/* /glade/scratch/$USER/$caze/SourceMods/src.cam/

#cp /glade/u/home/aherring/src/cam6_3_058.dtsens/usr_src/noclubbtop/* /glade/scratch/$USER/$caze/SourceMods/src.cam/
#phl cp /glade/u/home/aherring/src/cam6_3_058.dtsens/usr_src/n2o/wetexit/* /glade/scratch/$USER/$caze/SourceMods/src.cam/
#cp /glade/u/home/aherring/src/cam6_3_058.dtsens/usr_src/n2o/nodpmix/* /glade/scratch/$USER/$caze/SourceMods/src.cam/

./case.setup

#cp /glade/scratch/hannay/archive/f.e21.FWscHIST.ne30_L48_BL10_cam6_3_035.tphysac_reorder_zm2.001.hf2/rest/1990-01-01-00000/* /glade/scratch/$USER/$caze/run/

qcmd -- ./case.build
#qcmd -- ./case.build --skip-provenance-check
./case.submit

#!/bin/bash 
### git clone https://github.com/jtruesdal/cesm.git
### cd cesm
### git checkout addfms
### ./manage_externals/checkout_externals -o

#
# interpolating:
#
# env SRCFILE=new.FHS94.C96_C96_mg17.cam.h0.0001-02.nc DSTFILE=2.nc ncl < /project/amp/jet/remapfv3h0.ncl
#
##########################################################################
# Modify these to setup the CASE
##########################################################################

COMPSET=FHS94
#COMPSET=FKESSLER
DEBUG='FALSE'

RES=C96_C96_mg17
#RES=C24_C24_mg16

# A cube face is decomposed into LAYOUT1 #tasks in the X-direction by LAYOUT2 #tasks in the Y-direction
# ie layout=1,1 => 1 task per face   (6 faces * 1  task per face allow 6  total mpi tasks/pes)
# ie layout=1,2 => 2 tasks per face  (6 faces * 2  task per face allow 12 total mpi tasks/pes)
# ie layout=4,4 => 16 task per face  (6 faces * 16 task per face allow 96 total mpi tasks/pes)



host="`hostname`"
if [ "${host:0:8}" == "cheyenne" ]; then
    echo "script detected machine cheyenne"
    SRC=CESM2
    SCRIPTS=/glade/u/home/$USER/src/cesm-fv3/scripts
###    CASEROOT=/glade/scratch/$USER #/glade/p/cgd/amp/jet/cases
###    CESMDIR=/glade/u/home/$USER/src/$cesm #/glade/p/cgd/amp/jet/collections/cesm2_0_fv3porttest41
    CASEROOT=/glade/p/cgd/amp/$USER/cases
    CESMDIR=/glade/p/cgd/amp/$USER/collections/cesm2_0_fv3porttest8
    CESMDATA=/glade/p/cesmdata/inputdata
    QUEUE=regular
    LAYOUT1=8                ### layout1 must divide number of x cols on tile face evenly (96 cols for C96)
    LAYOUT2=8               ### layout2 must divide number of y rows on tile face evenly (96 rows for C96)
# the number of pes and number of tasks will be layout1 * layout2 * number of tile faces
    NUMPES=$(($LAYOUT1*$LAYOUT2*6))  # NUMPES=384 for a layout1,2 of 8,8
    NTHRDS=3
    COMPILER=intel    
    if [ $(($NUMPES%36)) != 0 ]; then 
	echo "WARNING: Number of PES does not divide evenly across Cheyenne nodes ... potential waste of resources??";
    fi
elif [ "${host:0:6}" == "hobart" ] || [ "${host:0:2}" == "h0" ]; then
    echo "script detected machine hobart"
    SRC=CESM2
    SCRIPTS=/home/pel/cesm-fv3/scripts
###    SCRIPTS=/project/amp/$USER/collections/cesm-fv3/scripts
    CASEROOT=/scratch/cluster/$USER #/glade/p/cgd/amp/jet/cases
###    CESMDIR=/home/$USER/src/$SRC #/glade/p/cgd/amp/jet/collections/cesm2_0_fv3porttest41
###    CASEROOT=/project/amp/$USER/cases
###    CESMDIR=/project/amp/$USER/collections/cesm2_0_fv3porttest8
    CESMDIR=/home/pel/src/fv3
    CESMDATA=/fs/cgd/csm/inputdata
    QUEUE=short
    LAYOUT1=1                ### layout1 must divide number of x cols on tile face evenly (96 cols for C96)
    LAYOUT2=1               ### layout2 must divide number of y rows on tile face evenly (96 rows for C96)
    NUMPES=$(($LAYOUT1*$LAYOUT2*6))  # NUMPES=384 for a layout1,2 of 8,8
    NTHRDS=1
    COMPILER=intel #pgi is very slow
elif [ "${host:0:5}" == "izumi" ];  then
    echo "script detected izumi hobart"
    SRC=CESM2
    SCRIPTS=/home/pel/cesm-fv3/scripts
###    SCRIPTS=/project/amp/$USER/collections/cesm-fv3/scripts
    CASEROOT=/scratch/cluster/$USER #/glade/p/cgd/amp/jet/cases
###    CESMDIR=/home/$USER/src/$SRC #/glade/p/cgd/amp/jet/collections/cesm2_0_fv3porttest41
###    CASEROOT=/project/amp/$USER/cases
###    CESMDIR=/project/amp/$USER/collections/cesm2_0_fv3porttest8
    CESMDIR=/home/pel/src/fv3
    CESMDATA=/fs/cgd/csm/inputdata
    QUEUE=monster
    LAYOUT1=8 #8                ### layout1 must divide number of x cols on tile face evenly (96 cols for C96)
    LAYOUT2=8 #8               ### layout2 must divide number of y rows on tile face evenly (96 rows for C96)
    NUMPES=$(($LAYOUT1*$LAYOUT2*6))  # NUMPES=384 for a layout1,2 of 8,8
    NTHRDS=1
    COMPILER=intel #pgi is very slow    
else
  perr "Unknown machine, ${host}"
fi

EXPNO=h003
CASE=new.$COMPSET.$RES
#CASE=fv3.$COMPSET.$RES.$COMPILER.PE$NUMPES.THR$NTHRDS.$EXPNO

if [ $COMPSET == "FKESSLER" ]; then
#    PCNST=6                  ### number of constituents for $COMPSET
    PCNST=10                  ### number of constituents for $COMPSET with test tracers
elif [ $COMPSET == "QPC4" ]; then
    PCNST=3                 ### number of constituents for $COMPSET    
    INIDAT=$CESMDATA/atm/cam/inic/fv3/aqua_0006-01-01_C24_L26_c161020.nc
elif [ $COMPSET == "F2000climo" ]; then
    PCNST=33                 ### number of constituents for $COMPSET
    INIDAT=$CESMDATA/atm/cam/inic/fv3/cami-mam3_0000-01-01_C24_L32_c141031.nc
elif [ $COMPSET == "FHS94" ]; then
    PCNST=1                 ### number of constituents for $COMPSET
    INIDAT=/project/amp/pel/inic/cami-mam3_0000-01-01_C96_L30_c140916.nc
else
    perr "Unknown compset, ${COMPSET}"
fi    

##########################################################################



##########################################################################

TILESIZE=`echo $RES | cut -c 2-3`

if [ $(($NUMPES%6)) != 0 ]; then 
    echo "NUMPES must be a multiple of 6 ... exiting!!!";
    exit;
fi

if [ $(($TILESIZE%$LAYOUT1)) != 0 ]; then 
    echo "LAYOUT1 must be an integer divisor of $TILESIZE ... exiting!!!";
    exit;
fi

if [ $(($TILESIZE%$LAYOUT2)) != 0 ]; then 
    echo "LAYOUT2 must be an integer divisor of $TILESIZE ... exiting!!!";
    exit;
fi



#set number of elements per task for phys_loadbalance = -1 
# PCOLS = elements on a face/(layout1*layout2) 

PCOLS=$(echo "24*24/($LAYOUT1*$LAYOUT2)" | bc) 

cd $CASEROOT
$CESMDIR/cime/scripts/create_newcase --compset $COMPSET --res $RES --compiler $COMPILER --case ${CASEROOT}/${CASE} --run-unsupported --pecount $NUMPES  --queue $QUEUE

cd $CASE

RUNDIR=`./xmlquery -value RUNDIR`

##########################################################################
# Modify/add here to modify build/run options
##########################################################################
###./xmlchange --append CAM_CONFIG_OPTS="-pcols $PCOLS"
./xmlchange DEBUG=$DEBUG
./xmlchange --file env_run.xml --id BFBFLAG --val TRUE
./xmlchange NTHRDS=1
./xmlchange DOUT_S=FALSE
./xmlchange STOP_OPTION=ndays,STOP_N=1200
./xmlchange JOB_WALLCLOCK_TIME="24:00:00"
#./xmlquery CAM_CONFIG_OPTS
./xmlchange CAM_CONFIG_OPTS="-phys held_suarez -fv3core"
#./xmlchange CAM_CONFIG_OPTS="-phys held_suarez" #very important: otherwise you get PS=1000hPa initial condition
#./xmlchange --append CAM_CONFIG_OPTS="-nadv_tt=10"
###./xmlchange HIST_OPTION=nstep,HIST_N=1,INFO_DBUG=2
##########################################################################

./*.setup




##########################################################################
# specific user_nl_xxx mods go here
##########################################################################
if [ $COMPSET == "FKESSLER" ]; then
cat >> user_nl_cam << EOFcam
! Users should add all user specific namelist changes below in the form of 
! namelist_var = new_namelist_value 
 ncdata         = '$INIDAT'
 nwat                          = 3
 fv3_qsize_condensate_loading  = 3
 layout          = $LAYOUT1,$LAYOUT2
 fv_sg_adj       =  0       
 no_dycore       =  .false.       


  avgflag_pertape(1) = 'I'
  avgflag_pertape(2) = 'I'
  avgflag_pertape(3) = 'I'
  avgflag_pertape(4) = 'I'
  avgflag_pertape(5) = 'I'
  nhtfrq             = -24,-24,-24,-24,-24,-24
  ndens = 1,1,1,1,1 
  fincl1         = 'PS','PRECL'
  fincl2         = 'Q','CLDLIQ','RAINQM','T','U','V','iCLy','iCL','iCL2','OMEGA'
  fincl3         = 'TT_SLOT', 'TT_SLOT2', 'TT_SLOT3','TT_COSB', 'TT_CCOSB', 'TT_mix_lr', 'TT_mix_lo',
                   'TT_mix_lu','TT_COSB2', 'TT_CCOSB2','TT_SLOT_SUM'
  fincl4         = 'TT_SLOT', 'TT_SLOT2', 'TT_SLOT3','TT_COSB', 'TT_CCOSB', 'TT_mix_lr', 'TT_mix_lo',
                   'TT_mix_lu','TT_COSB2', 'TT_CCOSB2','TT_SLOT_SUM'		 
  test_tracer_names = 'TT_SLOT','TT_SLOT2','TT_SLOT3','TT_COSB','TT_CCOSB','TT_COSB2', 'TT_CCOSB2','TT_EM8','TT_GBALL','TT_TANH'
  ncdata               = '/fs/cgd/csm/inputdata/atm/cam/inic/fv3/cami-mam3_0000-01-01_C96_L30_c140916.nc'
EOFcam
elif [ $COMPSET == "QPC4" ]; then
cat >> user_nl_cam << EOFcam    
! Users should add all user specific namelist changes below in the form of 
! namelist_var = new_namelist_value 
 rearth         =  6.37122D6
 ncdata         = '$INIDAT'
 nwat                          = 3
 fv3_qsize_condensate_loading  = 3
 layout          = $LAYOUT1,$LAYOUT2
 fv_sg_adj       =  0       
 no_dycore       =  .false.       
 nhtfrq = 1,-24,-6
 ndens = 1,2,2
 fincl1 =  'WV_pBF:I','WL_pBF:I','WI_pBF:I','SE_pBF:I','KE_pBF:I',
           'WV_pBP:I','WL_pBP:I','WI_pBP:I','SE_pBP:I','KE_pBP:I',
           'WV_pAP:I','WL_pAP:I','WI_pAP:I','SE_pAP:I','KE_pAP:I',
           'WV_pAM:I','WL_pAM:I','WI_pAM:I','SE_pAM:I','KE_pAM:I',
           'WV_dED:I','WL_dED:I','WI_dED:I','SE_dED:I','KE_dED:I',
           'WV_dAF:I','WL_dAF:I','WI_dAF:I','SE_dAF:I','KE_dAF:I',
           'WV_dAD:I','WL_dAD:I','WI_dAD:I','SE_dAD:I','KE_dAD:I',
           'WV_dAR:I','WL_dAR:I','WI_dAR:I','SE_dAR:I','KE_dAR:I',
           'WV_dBF:I','WL_dBF:I','WI_dBF:I','SE_dBF:I','KE_dBF:I'
 fincl2 =  'MR_dED:I','MO_dED:I',
           'MR_dAF:I','MO_dAF:I',
           'MR_dAD:I','MO_dAD:I',
           'MR_dAR:I','MO_dAR:I',
           'MR_dBF:I','MO_dBF:I'
 fincl3 =  'U200:I',
	   'V200:I',
	   'PRECT:I',
	   'SHFLX:I',
	   'LHFLX:I',
	   'FSNS:I',
	   'FLNS:I'
EOFcam
elif [ $COMPSET == "FHS94" ]; then
cat >> user_nl_cam << EOFcam    
! Users should add all user specific namelist changes below in the form of 
! namelist_var = new_namelist_value 
 rearth         =  6.37122D6
 ncdata         = '$INIDAT'
 nhtfrq = 0,0
 fincl1             = 'PS','T','Z3','U','V','OMEGA','PHIS','OMEGA500','OMEGA850'
 fincl2             = 'PS'
 inithist           =  'YEARLY'
 use_topo_file      =  .true. 
 bnd_topo = '/fs/cgd/inputdata/inputdata/atm/cam/topo/fv3_C96_nc3000_Co060_Fi001_MulG_PF_nullRR_Nsw042.181018.nc'
EOFcam

elif [ $COMPSET == "F2000climo" ]; then
cat >> user_nl_cam << EOFcam    
! Users should add all user specific namelist changes below in the form of 
! namelist_var = new_namelist_value 
 ncdata         = '$INIDAT'
 nwat                          = 5
 fv3_qsize_condensate_loading  = 5
 phys_loadbalance              = -1 
 layout          = $LAYOUT1,$LAYOUT2
 fv_sg_adj       =  0       
 no_dycore       =  .false.       
 nhtfrq = 0,-24,-6
 ndens = 1,2,2
 bnd_topo		= '/glade/p/cesmdata/inputdata/atm/cam/topo/fv3_C96_nc3000_Nsw042_Nrs008_Co060_Fi001_ZR_sgh30_24km_GRNL_c170103.nc'
 fincl1 =  'WV_pBF:A','WL_pBF:A','WI_pBF:A','SE_pBF:A','KE_pBF:A',
           'WV_pBP:A','WL_pBP:A','WI_pBP:A','SE_pBP:A','KE_pBP:A',
           'WV_pAP:A','WL_pAP:A','WI_pAP:A','SE_pAP:A','KE_pAP:A',
           'WV_pAM:A','WL_pAM:A','WI_pAM:A','SE_pAM:A','KE_pAM:A',
           'WV_dED:A','WL_dED:A','WI_dED:A','SE_dED:A','KE_dED:A',
           'WV_dAF:A','WL_dAF:A','WI_dAF:A','SE_dAF:A','KE_dAF:A',
           'WV_dAD:A','WL_dAD:A','WI_dAD:A','SE_dAD:A','KE_dAD:A',
           'WV_dAR:A','WL_dAR:A','WI_dAR:A','SE_dAR:A','KE_dAR:A',
           'WV_dBF:A','WL_dBF:A','WI_dBF:A','SE_dBF:A','KE_dBF:A'
 fincl2 =  'MR_dED:A','MO_dED:A',
           'MR_dAF:A','MO_dAF:A',
           'MR_dAD:A','MO_dAD:A',
           'MR_dAR:A','MO_dAR:A',
           'MR_dBF:A','MO_dBF:A'
 fincl3 =  'U200:A',
	   'V200:A',
	   'PRECT:A',
	   'SHFLX:A',
	   'LHFLX:A',
	   'FSNS:A',
	   'FLNS:A'
EOFcam
fi




##########################################################################
# This code will setup the ascii tracer file that is required by fv3
# this will be replaced by an addition to the functionality of the 
# fv3 tracermanager.  For now sets up specific constituents for FKESSLER
# and sets all other compsets to use 5 prognostic constituents and any number
# of additional tracers.
##########################################################################


#cp $SCRIPTS/diag_table $RUNDIR

if [ "${host:0:8}" == "cheyenne" ]; then
    qcmd -- ./case.build    
else
    ./case.build
fi
./case.submit
###./*.build
###./*.submit


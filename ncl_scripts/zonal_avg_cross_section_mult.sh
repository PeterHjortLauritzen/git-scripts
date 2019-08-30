#!/bin/tcsh
set n = 1
set vname = "$argv[$n]"
#
# set paths depending on machine
#
if (`hostname` == "hobart.cgd.ucar.edu") then
  echo "You are on Hobart"
  set data_dir = "/scratch/cluster/$USER/"
  setenv ncl_dir  "/home/$USER/git-scripts/ncl_scripts"
  set line_colors = "(/"\"red\"","\"blue\"","\"sienna1\"","\"deepskyblue\""/)"  
  echo "NCL directory is"$ncl_dir
endif
if (`hostname` == "izumi.unified.ucar.edu") then
  echo "You are on Izumi"
  set data_dir = "/scratch/cluster/$USER/"
  setenv ncl_dir  "/home/$USER/git-scripts/ncl_scripts"
  echo "NCL directory is"$ncl_dir
endif
if (`hostname` == "cheyenne5") then
  module load ncl
  set data_dir = "/glade/scratch/$USER/"
  setenv ncl_dir "/glade/u/home/$USER/git-scripts/ncl_scripts"
endif
set line_colors = "(/"\"red\"","\"blue\"","\"sienna1\"","\"deepskyblue\""/)"


#set fileA  = "nu_top_0.25_trunk_FHS94_CAM_ne30_ne30_mg17_480_NTHRDS1_1200ndays.ave.h0.nc"
#set titleA = "nu_top=0.25e5"
#set fileB = "nu_top_0.5e5trunk_FHS94_CAM_ne30_ne30_mg17_480_NTHRDS1_1200ndays.ave.h0.nc"
#set titleB = "nu_top=0.5e5"
#set fileC = "nu_top_1.0e5_trunk_FHS94_CAM_ne30_ne30_mg17_480_NTHRDS1_1200ndays.ave.h0.nc"
#set titleC = "nu_top=1.0e5"
#set fileD = "nu_top_2.5e5_hypervisOnPlevsFalse_trunk_FHS94_CAM_ne30_ne30_mg17_480_NTHRDS1_1200ndays.ave.h0.nc"
#set titleD = "nu_top=2.5e5"
#set fileE = "nu_top_5.0e5_trunk_FHS94_CAM_ne30_ne30_mg17_480_NTHRDS1_1200ndays.ave.h0.nc"
#set titleE = "nu_top=5.0e5"
#set fileF = "fv.ave.h0.nc"
#set titleF = "FV"

#set file = "(/"\"$fileA\"","\"$fileB\"","\"$fileC\"","\"$fileD\"","\"$fileE\"","\"$fileF\""/)"
#set titles = "(/"\"$titleA\"","\"$titleB\"","\"$titleC\"","\"$titleD\"","\"$titleE\"","\"$titleF\""/)"

set fileA  = "nu_top_1.25e5.ave.h0.nc" 
set titleA = "nu_top=1.25e5"
set fileB  = "nu_top_1.25e5_PPMmod.ave.h0.nc"
set titleB = "nu_top=1.25e5+PPMmod"#nu_top=1.5e5+PPM modification"
set fileC  = "fv.ave.h0.nc"
set titleC = "FV"

set file = "(/"\"$fileA\"","\"$fileB\"","\"$fileC\""/)"
set titles = "(/"\"$titleA\"","\"$titleB\"","\"$titleC\""/)"

set PanelTitle="FHS94, 1000 day average"

ncl 'vname="'$vname'"' 'vertical_height = True' 'lsArg='$file'' 'titles='$titles'' 'plot_lat_section=True' 'plot_lat_section_min=-90' 'plot_lat_section_max=90' 'coslat= False' 'diff=False' 'line_colors="$line_colors"' 'lsinx = True' 'PanelTitle="'"$PanelTitle"'"' < $ncl_dir/zonal_avg_cross_section.ncl

unset file
unset titles
unset fileA
unset fileB
unset fileC
unset fileD
unset fileE
unset fileF

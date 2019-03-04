#!/bin/tcsh
if ( "$#argv" == 5) then
  set n = 1
  set titlePlotA = "$argv[$n]"
  set n = 2
  set titlePlotB = "$argv[$n]"
  set n = 3
  set filA = "$argv[$n]"  
  set n = 4
  set ref_file = "$argv[$n]"
  set n = 5
  set vname = "$argv[$n]"
  #
  # list for NCL
  #
  set file = "(/"\"$filA\"","\"$ref_file\""/)"
  set titles = "(/"\"$titlePlotA\"","\"$titlePlotB\""/)"    
else
  if ( "$#argv" != 3) then
    echo "Wrong number of arguments specified:"
    echo "  -arg 1 title for data"    
    echo "  -arg 2 file with data"
    echo "  -arg 3 variable name (e.g., U,T)"
    echo " "
    echo " or "
    echo " "    
    echo "  -arg 1 file with data"
    echo "  -arg 2 file with ref data"    
    echo "  -arg 3 variable name (e.g., U,T)"    
    exit
  endif
  set n = 1
  set titlePlotA = "$argv[$n]"  
  set n = 2
  set filA = "$argv[$n]" 
  set n = 3
  set vname = "$argv[$n]"
  #
  # list for NCL
  #
  set file = "(/"\"$filA\""/)"
  set titles = "(/"\"$titlePlotA\""/)"  
endif  
#
# set paths depending on machine
#
if (`hostname` == "hobart.cgd.ucar.edu") then
  echo "You are on Hobart"
  set data_dir = "/scratch/cluster/$USER/"
  setenv ncl_dir  "/home/$USER/git-scripts/ncl_scripts"
  set line_colors = "(/"\"red\"","\"blue\"","\"sienna1\"","\"deepskyblue\""/)"  
  echo "NCL directory is"$ncl_dir
else
if (`hostname` == "izumi.unified.ucar.edu") then
  echo "You are on Izumi"
  set data_dir = "/scratch/cluster/$USER/"
  setenv ncl_dir  "/home/$USER/git-scripts/ncl_scripts"
  echo "NCL directory is"$ncl_dir
else
  module load ncl
  set data_dir = "/glade/scratch/$USER/"
  setenv ncl_dir "/glade/u/home/$USER/git-scripts/ncl_scripts"
endif
endif

set line_colors = "(/"\"red\"","\"blue\"","\"sienna1\"","\"deepskyblue\""/)"

ncl 'vname="'$vname'"' 'vertical_height = True' 'lsArg='$file'' 'titles='$titles'' 'plot_lat_section=True' 'plot_lat_section_min=-90' 'plot_lat_section_max=90' 'coslat= False' 'diff=False' 'line_colors="$line_colors"' 'lsinx = True' < $ncl_dir/zonal_time_avg.ncl

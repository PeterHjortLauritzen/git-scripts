#!/bin/tcsh
if ( "$#argv" != 2) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 is file(s) directory"
  echo "  -arg 2 file name"
#  echo "  -arg 3 (if exists) only interpolate user-sepcified vars (hard-coded in script)"
#  echo "  -arg 2 is history file number (e.g., h0)"
  exit
endif
set n = 1
set data_dir = "$argv[$n]"
set n = 2
set filename = "$argv[$n]"
if (`hostname` == "hobart.cgd.ucar.edu") then
  set work_dir = "/scratch/cluster/$USER/work"
  setenv my_ncl_dir  "/home/$USER/git-scripts/ncl_scripts"  
else
  if (`hostname` == "izumi.unified.ucar.edu") then
    set work_dir = "/scratch/cluster/$USER/work"
    setenv my_ncl_dir  "/home/$USER/git-scripts/ncl_scripts"    
  else
    set work_dir = "/glade/scratch/$USER/work"
    setenv my_ncl_dir  "/glade/u/home/$USER/git-scripts/ncl_scripts"
  endif    
endif
set interp_dir =  "$PWD" #"$work_dir/interp-data"



set nlon  = 360
set nlat  = 180
#set interp_method = "bilinear" #patch
set interp_method = "conserve" #patch
#set interp_method = "patch" #patch
echo ""
echo "------------------------------------------------------------"
echo "This script interpolates the user specified cases located in"
echo ""
echo $data_dir 
echo ""
echo "to a lat-lon grid ($nlon longitudes and $nlat latitudes)" 
echo "using $interp_method interpolation"
echo "The interpolated files will be located in:"
echo ""
echo $interp_dir
echo ""
echo "------------------------------------------------------------"
echo ""
#
# $case.nc will be interpolated to latitude-longitude grid
#
set cases = ( "$filename" )
#set cases = ( "*h1*.nc" ) #to interpolate all h1 files in a directory
#
# DO NOT EDIT BELOW
#
if (! -e $work_dir) mkdir $work_dir
if (! -e $interp_dir) mkdir $interp_dir
foreach case ($cases)
  echo "$cases "$cases
  foreach file (`ls $data_dir/$case | grep -v ''$interp_method'_to_nlon'$nlon'xnlat'$nlat'.nc'`)
    #*********************************************
    #
    # interpolate data
    #
    #*********************************************
    setenv interpfile  {$case}.{$interp_method}_to_nlon{$nlon}xnlat{$nlat}.nc
    echo "$interpfile "$interpfile
    if (-e $interp_dir/$interpfile) then
      echo "Skipping interpolating ($interpfile exists)"
    else
      echo "Creating "$interpfile
      if (! -e $work_dir/Regrid_Maps) then
         mkdir $work_dir/Regrid_Maps
      endif
      if (-e $work_dir/$case.regrid.sh) rm $work_dir/$case.regrid.sh
      if (-e $work_dir/$case.regrid.sh.output) rm $work_dir/$case.regrid.sh.output
      echo "ncl  'case="\"$case\""' 'ingrid="\"$case\""' 'outgrid="\"nlon{$nlon}xnlat{$nlat}\""' 'interp_method="\"$interp_method\""' 'grid_dir="\"$work_dir/Regrid_Maps/\""'  'srcPath="\"$data_dir/\""' 'dstPath="\"$interp_dir/\""' 'nx=$nlon' 'ny=$nlat' < $my_ncl_dir/interp_se_to_latlon.ncl" > $work_dir/$case.regrid.sh
      source $work_dir/$case.regrid.sh > $work_dir/$case.regrid.sh.output
      if (-e abnormal_ext) then
        echo "ncl script was not successful: "$work_dir/$case.regrid.sh
        echo "see output from ncl script   : "$work_dir/$case.regrid.sh.output
        echo "ABORTING SCRIPT"
        exit
      endif
    endif
  end
end
unset n
unset case
unset n 
unset filename
unset data_dir 
unset interp_dir
unset work_dir

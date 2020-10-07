#!/bin/tcsh
#
# On Izumi: module load tool/nco/4.7.5
#
if ( "$#argv" != 3) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 is run case"
  echo "  -arg 2 is history file number (e.g., h0)"
  echo "  -arg 3 JJA, DJF or ANN"
  exit
endif
set n = 1
set case = "$argv[$n]" 
set n = 2
set hn = "$argv[$n]"
set n = 3
set season = "$argv[$n]"
if (`hostname` == "hobart.cgd.ucar.edu") then
    echo "Detected host hobart"
  set data_dir = "/scratch/cluster/$USER/"
  module load tool/nco/4.7.5
else
  if (`hostname` == "izumi.unified.ucar.edu") then
    echo "Detected host izumi"
    set data_dir = "/scratch/cluster/$USER/"
    module load tool/nco/4.7.5
  else
    #
    # Cheyenne
    #
    echo "Detected host Cheyenne"  
    module load nco
    set data_dir = "/gpfs/fs1/scratch/$USER/"
  endif
endif
if ($season == "JJA") then
  set seasonCode = "0[6-8]"
endif
if ($season == "DJF") then
  set seasonCode = "{12,01,02}"
endif
if ($season == "ANN") then
  set seasonCode = "*"
endif

echo "scratch directory is $data_dir"
echo "ls $data_dir/$case/run/$case.cam.$hn.*-$seasonCode.nc"
set files = `ls $data_dir/$case/run/$case.cam.$hn.*-$seasonCode.nc`

echo $files
ncra $files {$case}.ave.$season.$hn.nc
unset case
unset hn
unset files
unset data_dir
unset season
unset seasonCode


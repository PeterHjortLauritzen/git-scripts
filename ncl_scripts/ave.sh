#!/bin/tcsh
#
# On Izumi: module load tool/nco/4.7.5
#
if ( "$#argv" != 2) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 is run case"
  echo "  -arg 2 is history file number (e.g., h0)"
  exit
endif
set n = 1
set case = "$argv[$n]" 
set n = 2
set hn = "$argv[$n]" 
if (`hostname` == "hobart.cgd.ucar.edu") then
  set data_dir = "/scratch/cluster/$USER/"
endif
if (`hostname` == "izumi.unified.ucar.edu") then
  set data_dir = "/scratch/cluster/$USER/"
endif
if (`hostname` == "cheyenne.ucar.edu") then
  set data_dir = "/gpfs/fs1/scratch/$USER/"
endif
echo "scratch directory is $data_dir"
echo "ls $data_dir/$case/run/$case.cam.$hn.*"
set files = `ls $data_dir/$case/run/$case.cam.$hn.*`
echo $files
ncra $files {$case}.ave.$hn.nc
unset case
unset hn
unset files
unset data_dir


#!/bin/tcsh
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
#set data_dir = "/scratch/cluster/pel/"
set data_dir = "/glade/scratch/pel/"
set files = `ls $data_dir/$case/run/$case.cam.$hn.*`
echo $files
ncra $files {$case}.ave.$hn.nc
unset case
unset hn
unset files
unset data_dir


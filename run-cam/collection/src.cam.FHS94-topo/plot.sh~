#!/bin/tcsh
if ( "$#argv" != 2) then
  echo "Wrong number of arguments specified:"
  echo "  -arg 1 fname"
  echo "  -arg 2 time index to plot"
endif  
set n = 1
set fname = "$argv[$n]"
set n = 2
set time_idx = "$argv[$n]"

#if (! -d work ) then
#  mkdir work  
#else
#  rm work/*.nc
#endif
#ln -s $fname work/

#set vname = "(/"\"TT_UN\"","\"TT_UN\""/)"
set vname = "(/"\"OMEGA850\"","\"OMEGA500\""/)"
echo $vname
set hnum = "h0.ave"
set grid_descriptor_fname = "/glade/u/home/pel/git-scripts/run-cam/collection/grid_descriptor_files/SE.SCRIP.nc"
set my_ncl = "/glade/u/home/pel/git-scripts/run-cam/collection/src.cam.FHS94-topo/"
echo $cwd/$fname
echo $grid_descriptor_fname
#source set_datafile_location.sh
ncl 'time_idx="'$time_idx'"' 'vname='$vname'' 'grid_descriptor_file="'$grid_descriptor_fname'"' 'hnum="'$hnum'"' 'fname="'$fname'"' 'outfname="'OMEGA.pdf'"'  $my_ncl/plot_2column_panel.ncl
#cd work/
#pdfcrop --margins 25 OMEGA.pdf
#ls OMEGA-crop.pdf
#mv OMEGA-crop.pdf ../plots/OMEGA.pdf
#cd ..

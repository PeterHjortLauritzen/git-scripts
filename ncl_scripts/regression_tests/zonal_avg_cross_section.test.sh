#!/bin/tcsh
set out_dir = test-results
if (-e $out_dir) then
  echo "Output directory (test-results) already exists"
else
  echo "Creating directory test-results"
  mkdir $out_dir
endif
source ../zonal_avg_cross_section.sh FV data/zonal_avg_cross_section.fv.nc U
mv zonal_avg_cross_section.U.pdf $out_dir/
source ../zonal_avg_cross_section.sh FV SE data/zonal_avg_cross_section.fv.nc data/zonal_avg_cross_section.se.nc U
mv zonal_avg_cross_sections.U.pdf $out_dir/

#!/bin/tcsh
sed -i 's/<model_grid alias="ne30pg3_ne30pg3_mg17" not_compset="_POP|_CLM">/<model_grid alias="ne30pg3_ne30pg3_mg17" not_compset="_POP">/g' ~/src/$1/cime/config/cesm/config_grids.xml
#sed -i 's/<grid name="atm">ne30pg3/<grid name="atm">ne30np4.pg3/g' ~/src/$1/cime/config/cesm/config_grids.xml
#sed -i 's/<grid name="lnd">ne30pg3/<grid name="lnd">ne30np4.pg3/g' ~/src/$1/cime/config/cesm/config_grids.xml
sed -i 's/"512x1024,360x720cru,128x256/"ne30pg3,512x1024,360x720cru,128x256/g'   ~/src/$1/components/clm/bld/namelist_files/namelist_definition_ctsm.xml
sed -i 's/T341/ne30pg3/g' ~/src/$1/components/cam/cime_config/buildcpp
sed -i 's/512x1024/ne30np4.pg3/g' ~/src/$1/components/cam/cime_config/buildcpp

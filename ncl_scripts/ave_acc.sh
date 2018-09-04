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

if (`hostname` == "hobart.cgd.ucar.edu") then
  set data_dir = "/scratch/cluster/$USER/"
else
  set data_dir = "/gladce/scratch/$USER/"
endif
set hn = "h2"

echo "scratch directory is $data_dir"
echo "ls $data_dir/$case/run/$case.cam.$hn.*"

mkdir data
if (0<1) then
  set files = ("")
  @ year = 1
  while ($year <= 5) 
    @ month = 1
    @ continue = 1
    if ($year < 10) then
      set str_year = 0$year
    else
      set str_year = $year
    endif
    while ($continue > 0)
       echo "Doing "$month
       if ($month < 10) then
         set str_month = 0$month
       else 
         set str_month = $month
       endif
       set files = ("") # don't accumulate
       set files = ($files "$case.cam.$hn.00$str_year-$str_month.nc") #`ls $case.cam.$hn.*`
       echo "===============MONTH "$str_month "YEAR "$str_year"======================="
       ncra $files data/$case.ave.$str_year-$str_month.nc      
       source ~/git-scripts/ncl_scripts/budgets/te_budgets.sh data/$case.ave.$str_year-$str_month.nc
       @ month += 1
       if ($month > 12) @ continue = 0
    end
    @ year += 1  
    echo $year
  end
endif

#
# do yearly averages
#
if (0<0) then
  set files = ("")
  @ year = 2
  while ($year <= 10) 
    @ month = 1
    @ continue = 1
    if ($year < 10) then
      set str_year = 0$year
    else
      set str_year = $year
    endif
    while ($continue > 0)
       echo "Doing "$month
       if ($month < 10) then
         set str_month = 0$month
       else 
         set str_month = $month
       endif
       set files = ($files "$case.cam.$hn..00$str_year-$str_month.nc") #`ls $case.cam.$hn.*`
       @ month += 1
       if ($month > 12) @ continue = 0
    end
    echo "===============MONTH "$str_month "YEAR "$str_year"======================="
    ncra $files data/$case.yearly-ave.$str_year.nc      
    source ~/git-scripts/ncl_scripts/budgets/te_budgets.sh data/$case.yearly-ave.$str_year.nc
    source ~/git-scripts/ncl_scripts/budgets/te_budgets.sh data/$case.yearly-ave.$str_year.nc
    source ~/git-scripts/ncl_scripts/budgets/te_budgets.sh data/$case.yearly-ave.$str_year.nc
    source ~/git-scripts/ncl_scripts/budgets/te_budgets.sh data/$case.yearly-ave.$str_year.nc
    source ~/git-scripts/ncl_scripts/budgets/te_budgets.sh data/$case.yearly-ave.$str_year.nc
    source ~/git-scripts/ncl_scripts/budgets/te_budgets.sh data/$case.yearly-ave.$str_year.nc
    source ~/git-scripts/ncl_scripts/budgets/te_budgets.sh data/$case.yearly-ave.$str_year.nc
    source ~/git-scripts/ncl_scripts/budgets/te_budgets.sh data/$case.yearly-ave.$str_year.nc
    source ~/git-scripts/ncl_scripts/budgets/te_budgets.sh data/$case.yearly-ave.$str_year.nc
    source ~/git-scripts/ncl_scripts/budgets/te_budgets.sh data/$case.yearly-ave.$str_year.nc
    source ~/git-scripts/ncl_scripts/budgets/te_budgets.sh data/$case.yearly-ave.$str_year.nc
    source ~/git-scripts/ncl_scripts/budgets/te_budgets.sh data/$case.yearly-ave.$str_year.nc

    set files = ("") # do yearly average

    @ year += 1  
    echo $year
  end
endif



#set files = ($files "$case.0002-03.nc") #`ls $case.cam.$hn.*`
#echo $files
#ncra $files $case.ave.3.nc 

#set files = ("$case.0002-01.nc" "$case.0002-02.nc") #`ls $case.cam.$hn.*`
#echo $files
#ncra $files $case.ave.3.nc 



unset case
unset hn
unset files
unset data_dir


#!/bin/tcsh
if ( "$#argv" != 1) then
   echo "Wrong number of arguments specified:"
   echo " -arg 1 startup cleanup"
endif
set n   = 1
set arg = "$argv[$n]"
set argumentSupported="False"




if ( $arg == "startup" ) then   
  if(`hostname` == 'hobart.cgd.ucar.edu') then
    echo "setting up for Hobart"
    set inic="/scratch/cluster/pel/inic"
    set homedir="/home"
    set scratch="/scratch/cluster"
    set queue="monster" #short
    set compiler="intel"
    set machine="hobart"  
  endif  
  if(`hostname` == 'izumi.unified.ucar.edu') then
    echo "setting up for Izumi"  
    set inic="/scratch/cluster/pel/inic"
    set homedir="/home"
    set scratch="/scratch/cluster"
    set queue="monster"
    set compiler="intel"
#    set compiler="nag"
    set machine="izumi"
  endif
  if(`hostname` == 'cheyenne2.ib0.cheyenne.ucar.edu' || `hostname` == 'cheyenne1' || `hostname` == 'cheyenne2' || `hostname` == 'cheyenne3' || `hostname` == 'cheyenne4' || `hostname` == 'cheyenne5' || `hostname` == 'cheyenne6') then
    echo "setting up for Cheyenne"
    set inic="/glade/p/cgd/amp/pel/inic"
    set homedir="/glade/u/home"
    set scratch="/glade/scratch"
    set queue="regular"
    set compiler="intel"
    set machine="cheyenne"
    set inputdata="/glade/p/cesmdata/cseg/inputdata/"
    endif
    set argumentSupported="True"
endif

if ( $arg == "cleanup" ) then
   echo "cleanup"
   set argumentSupported="True"   
   unset inic
   unset homedir
   unset scratch
   unset queue
   unset compiler
   unset machine
   unset n
endif

if ( $argumentSupported == "False" ) then
   echo "ERROR: argument "$arg" not support"
endif
unset argumentSupported   

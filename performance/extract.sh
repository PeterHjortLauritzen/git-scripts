grep 'phys2dyn' model_timing_stats_version2 > 1
awk '{ print $6 }' 1

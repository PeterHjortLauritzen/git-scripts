#EFIX     param    DMEA     2Ddyn     fricH    elseH     1Dre
set terminal pdf
set out "dEdt_all_ape.pdf"
set grid
plot "te_budgets.txt" u 1 title "EFIX" w l lw 3,"te_budgets.txt" u 2 title "Parameterization" w l lw 3 ,"te_budgets.txt" u 3 title "DME adjust" w l lw 3,"te_budgets.txt" u 4 title "Total dynamics (excl. forcing)" w l lw 3,"te_budgets.txt" u 5 title "2D dynamics" w l lw 3,"te_budgets.txt" u 6 title "Frictional heating" w l lw 3,"te_budgets.txt" u 7 title "Hyperviscosity total" w l lw 3,"te_budgets.txt" u 8 title "Vertical remapping" w l lw 3,"te_budgets.txt" u (-$3-$4) title "Consistency check" w lp

#plot "te_budgets_yearly.txt" u 1 title "EFIX" w l lw 3,"te_budgets_yearly.txt" u 2 title "Parameterization" w l lw 3,"te_budgets_yearly.txt" u 3 title "DME adjust" w l lw 3,"te_budgets_yearly.txt" u 4 title "Total dynamics (excl. forcing)" w l lw 3,"te_budgets_yearly.txt" u 5 title "2D dynamics" w l lw 3,"te_budgets_yearly.txt" u 6 title "Frictional heating" w l lw 3,"te_budgets_yearly.txt" u 7 title "Hyperviscosity total" w l lw 3,"te_budgets_yearly.txt" u 8 title "Vertical remapping" w l lw 3


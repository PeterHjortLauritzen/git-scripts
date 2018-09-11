load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  diags_fname = "te_budgets.txt"
  print("Summary of input to ncl script:")
  print("===============================")
  print(" ")
  print("nsplit                   ="+nsplit)
  print("rsplit                   ="+rsplit)
  print("hypervis_subcycle        ="+hypervis_subcycle)
  print("ftype                    ="+ftype)
  print("qsize_condensate_loading ="+qsize_condensate_loading)
  print("lcp_moist                ="+lcp_moist)
  print("dtime                    ="+dtime)
  fname =  systemfunc("ls "+fname)
  print("File used for energy diagnostics "+fname)
  print("done input summary")
  print(" ")
  fall = addfile(fname,"r")       ; Open netCDF files.	
  ;
  ; initialization
  ;
  g = 9.80665D0
  nc        = -1
  eps       = 1.0D-13
  area      = fall->area   (:  )
  tmp       = fall->SE_dED(:,:)
  nt        = dimsizes(tmp(:,0))
  ncol      = dimsizes(tmp(0,:))
  ;
  ; check if physics-dynamics variables are present
  ;
  if (isfilevar(fall,"WI_pBF").and.isfilevar(fall,"WL_pBF")) then
    print("File appears to contain variables from a non-dry run - setting wet=True")
    wet = True
  else
    print("File appears to be from a dry run (no WL and no WI) - setting wet=False")
    wet = False
  end if

  if (isfilevar(fall,"WV_PDC")) then
    vars_pdc  = new((/4,nt,ncol/),typeof(tmp(0,0)))
    int_vars_pdc  = new((/4,nt/) ,typeof(tmp(0,0)))
    pdc_vars_present = True
    print("PDC vars are present on file")
  else
    print("No PDC vars present on file")
    pdc_vars_present = False
  end if
  ;
  ; check if physics-dynamics variables are present
  ;
  if (isfilevar(fall,"TT_pBF")) then
    TT_vars_present = True
    print("TT vars are present on file")
  else
    print("No TT vars present on file")
    TT_vars_present = False
  end if

  print(" ")
  print(" ")
  if (wet) then
    print("suffix (parameterization side)")
    print("pBF: state passed to parameterizations, before energy fixer")
    print("pBP: after energy fixer, before parameterizations")
    print("pAP: after last phys_update in parameterizations and state saved for energy fixer")
    print("pAM: after dry mass correction calculate but not used in SE")
    print(" ")
    print("history files saved off here")
  end if
  print(" ")
  print("suffix (dynamics)")
  print("dED: state from end of previous dynamics (= pBF + time sampling)")
  print("   loop over vertical remapping and physics dribbling -------- (nsplit) -------")
  print("            (dribbling and remapping always done together)                    |")
  print("          dAF: state from previous remapping                                  |")
  print("          dBD: state after physics dribble, before dynamics                   |")
  print("          loop over vertical Lagrangian dynamics --------rsplit-------------  |")
  print("              dynamics here                                                |  |")
  print("              loop over hyperviscosity ----------hypervis_sub------------  |  |")
  print("                 dBH   state before hyperviscosity                      |  |  |")
  print("                 dCH   state after hyperviscosity                       |  |  |")
  print("                 dAH   state after hyperviscosity momentum heating      |  |  |")
  print("              end hyperviscosity loop -----------------------------------  |  |")
  print("          end of vertical Lagrangian dynamics loop -------------------------  |")
  print("      dAD  state after dynamics, before vertical remapping                    |")
  print("      dAR     state after vertical remapping                                  |")
  print("   end of remapping loop ------------------------------------------------------")
  print("dBF  state passed to parameterizations = state after last remapping            ")
  print(" ")
  print(" ")
  print(" ")

  if (wet) then
    qsize = 3
    str_vars      = (/"SE","KE","WV","WL","WI"/);,"TT"/)
    str_stage     = (/"pBF","pBP","pAP","pAM","dED","dAF","dBD","dAD","dAR","dBF","dBH","dCH","dAH"/)
  else
    qsize = 0
    str_vars      = (/"SE","KE"/)
    str_stage     = (/"dED","dAF","dBD","dAD","dAR","dBF","dBH","dCH","dAH"/)
  end if

  nvars       = dimsizes(str_vars)
  nstage      = dimsizes(str_stage)
  vars        = new((/nvars,nstage,nt,ncol/),typeof(tmp(0,0)))
  subcycle    = new((/nstage/),typeof(tmp(0,0))) 

  if (wet) then
    subcycle    = (/1D0,1D0,1D0,1D0,1.0D0,nsplit,nsplit,nsplit,nsplit,1.0D0,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle/)
  else
    subcycle    = (/1.0D0,nsplit,nsplit,nsplit,nsplit,1.0D0,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle/)
  end if

  tot_energy  = new((/nstage/),typeof(tmp(0,0)))
  tracer_mass = new((/3,nstage/),typeof(tmp(0,0)))

  int_vars  = new((/nvars,nstage,nt/)     ,typeof(tmp(0,0)))
  int_vars  = 0.0D0
  ;
  ; check that variables are on file and read them
  ;
  do k=0,nvars-1
    do j=0,nstage-1
      str = str_vars(k)+"_"+str_stage(j)
      if (isfilevar(fall,str)) then
        vars(k,j,:,0:ncol-1) = fall->$str$(:,:)
      else
        print("Variable "+str+" not found")
        exit
      end if
    end do
  end do
  ;
  ; compute global integrals
  ;
  area_sphere = sum(area(0:ncol-1))
  print("Area of sphere in dataset is : "+area_sphere)
  inv_area_sphere = 1.0D0/area_sphere
  do t=0,nt-1
    do variable = 0,nvars-1
      do stages=0,nstage-1
        int_vars(variable,stages,t) = sum(area(0:ncol-1)*vars(variable,stages,t,0:ncol-1))*inv_area_sphere
      end do
    end do
  end do

  ;
  ; For code clarity define indices corresponding to the different stages
  ;
  ipBF = str_match_ind(str_stage,"pBF")
  ipBP = str_match_ind(str_stage,"pBP")
  ipAP = str_match_ind(str_stage,"pAP")
  ipAM = str_match_ind(str_stage,"pAM")
  idED = str_match_ind(str_stage,"dED")
  idAF = str_match_ind(str_stage,"dAF")
  idBD = str_match_ind(str_stage,"dBD")
  idAD = str_match_ind(str_stage,"dAD")
  idAR = str_match_ind(str_stage,"dAR")
  idBF = str_match_ind(str_stage,"dBF")
  idBH = str_match_ind(str_stage,"dBH")
  idCH = str_match_ind(str_stage,"dCH")
  idAH = str_match_ind(str_stage,"dAH")

  if (ismissing(ipBF).or.ismissing(ipBF).or.ismissing(ipAM).or.ismissing(ipAP)) then
    PhysDiags = False
    print("Physics diagnostics are not all on file")
  else
    PhysDiags = True
    print("Physics diagnostics are on file")
  end if

  do t=0,nt-1
    print("t="+t)
    do j=0,nstage-1
      tot_energy(j)  = subcycle(j)*(int_vars(0,j,t)+int_vars(1,j,t))
;      tot_energy(j)  = subcycle(j)*int_vars(0,j,t)
      if (wet) then
        idx = str_match_ind(str_vars,"WV")
        tracer_mass(0,j) = subcycle(j)*(int_vars(idx,j,t))
        idx = str_match_ind(str_vars,"WL")
        tracer_mass(1,j) = subcycle(j)*(int_vars(idx,j,t))
        idx = str_match_ind(str_vars,"WI")
        tracer_mass(2,j) = subcycle(j)*(int_vars(idx,j,t))
      end if
    end do

    
    print("  ")
    print("  ")
    print("  ")
    print("ANALYSIS_START_ANALYSIS_START_ANALYSIS_START_ANALYSIS_START_ANALYSIS_START_ANALYSIS_START")
    print("  ")
    print("  ")
    print("  ")

    te_consistent_version=False
    if (qsize_condensate_loading.eq."1") then
       if (lcp_moist.eq."false") then
         print("Using total energy consistent version: qsize_condensate_loading=1 and cp=cpdry")
         te_consistent_version=True
       else
         print("WARNING: Total energy formulaes for dynamics and physics are different:")
         print("   Dynamics (cp includes water vapor; condensates not thermodynamically active).")
         print("   Physics (cp=cp_dry in internal energy).")
       end if
    else
       print("WARNING: Total energy formulaes for dynamics and physics are different")
       print("in dynamics (cp and dp includes all water variables) and physics (cp=cp_dry in internal energy).")
    end if

   if (PhysDiags) then
      pEFIX    = (tot_energy(ipBP)-tot_energy(ipBF))/dtime
      pDMEA = (tot_energy(ipAM)-tot_energy(ipAP))/dtime
      param           = (tot_energy(ipAP)-tot_energy(ipBP))/dtime
      phys_total      = (tot_energy(ipAM)-tot_energy(ipBF))/dtime
   end if

    dyn_total       = (tot_energy(idBF)-tot_energy(idED))/dtime
    dyn_phys_total       = (tot_energy(idAD)-tot_energy(idAF))/dtime

    str_data  = new( 1, "string")
    if (PhysDiags) then
    print(" ")
    print("=================================================================================")
    print("|                                                                               |")
    print("| ANALYSIS OF ENERGY DIAGNOSTICS IN PHYSCS                                      |")
    print("|                                                                               |")
    print("=================================================================================")
    print(" ")
    print("dE/dt parameterizations (param)         (pAP-pBP) "+sprintf("%6.3g",param)     +" W/M^2")
    print("dE/dt dry mass adjustment (pwork)       (pAM-pAP) "+sprintf("%6.3g",pDMEA)     +" W/M^2")
    print("dE/dt energy fixer (efix)               (pBP-pBF) "+sprintf("%6.3g",pEFIX)     +" W/M^2")
    print("dE/dt physics total (phys)              (pAM-pBF) "+sprintf("%6.3g",phys_total)+" W/M^2")

;    print(" ")
;    value = pEFIX+pDMEA
;    print("=> dE/dt dynamical core (estimated from physics)  ")
;    print("   dE/dt energy fixer + dE/dt dry mass adjustment "+sprintf("%6.3g",value)+" W/M^2")
;    
;    print("=> dE/dt physics total                   (pAM-pBF)"+sprintf("%6.3g",phys_total)+" W/M^2")
    end if

    print(" ")
    print("=================================================================================")
    print("|                                                                               |")
    print("| ANALYSIS OF ENERGY DIAGNOSTICS IN DYNAMICS                                    |")
    print("|                                                                               |")
    print("=================================================================================")
    print(" ")

    rate_of_change_2D_dyn = (tot_energy(idAD)-tot_energy(idBD))/dtime
    rate_of_change_vertical_remapping = (tot_energy(idAR)-tot_energy(idAD))/dtime
    dADIA = rate_of_change_2D_dyn+rate_of_change_vertical_remapping
    print("dE/dt total adiabatic dynamics (adiab)            "+sprintf("%6.3g",dADIA)+" W/M^2")    
    print("dE/dt 2D dynamics (2D)                  (dAD-dBD) "+sprintf("%6.3g",rate_of_change_2D_dyn)+" W/M^2")
    print("dE/dt vertical remapping (remap)        (dAR-dAD) "+sprintf("%6.3g",rate_of_change_vertical_remapping)+" W/M^2")
    rate_of_change_physics = (tot_energy(idBD)-tot_energy(idAF))/dtime
    print("dE/dt physics tendency in dynamics      (dBD-dAF) "+sprintf("%6.3g",rate_of_change_physics)+" W/M^2")
    print(" ")
    print("Breakdown of 2D dynamics:")
    print(" ")
    rate_of_change_heating_term_put_back_in = (tot_energy(idAH)-tot_energy(idCH))/dtime
    rate_of_change_hypervis_total           = (tot_energy(idAH)-tot_energy(idBH))/dtime
    print("      dE/dt hypervis (hvis)             (dAH-dBH) "+sprintf("%6.3g",rate_of_change_hypervis_total)+" W/M^2")
    print("      dE/dt frictional heating (fheat)  (dAH-dCH) "+sprintf("%6.3g",rate_of_change_heating_term_put_back_in)+" W/M^2")
    twoDresidual = rate_of_change_2D_dyn-rate_of_change_hypervis_total
    print("      dE/dt residual (res)                        "+sprintf("%6.3g",twoDresidual)+" W/M^2")

    print(" ")
    print(" ")

    if (PhysDiags) then
      print(" ")
      print("=================================================================================")
      print("|                                                                               |")
      print("| ANALYSIS OF ENERGY DIAGNOSTICS IN DYNAMICS-PHYSICS COMBINED                   |")
      print("|                                                                               |")
      print("=================================================================================")
      print(" ")
      value_pdc = phys_total-rate_of_change_physics
      if (te_consistent_version.eq."True") then
        print("Your model is energy consistent (qsize_condensate_loading=1 and cpdry)")
        if (ftype .eq. "1") then
          print(" ")
          print("You are using ftype=1 so PDC errors should be zero:")
          print(" ")
          print("    dE/dt physics tendency in dynamics (dBD-dAF) should exactly match dE/dt physics total (pAM-pBF): "+sprintf("%6.3g",value_pdc))
          print(" ")
        else
          print(" ")
          print("You are using ftype=0 or 2 so there are PDC errors (dribbling errors):")
          print(" ")
          print("   Dribbling errors (pAM-pBF-(dBD-dAF))/dt: "+sprintf("%6.3g",value_pdc))
        end if
        discr = "0       "
        str_pdc = sprintf("%6.3g",10*value_pdc)
      else
        print("Your model is energy inconsistent (qsize_condensate_loading<>1 and/or cp<>cpdry)")
        print(" ")
        print("PDC errors can not be assesed trhough ")
        print(" ")
        print("   dE/dt physics tendency in dynamics (dBD-dAF) does not match dE/dt physics total (pAM-pBF) due to energy discrepancy:"+sprintf("%6.3g",value_pdc))
        str_pdc = "undef"
      end if
      print(" ")
      print("Some more consisitency/budget terms")
      print("===================================")
      print(" ")
      print("Energy fixer fixes dme_adjust (pDMEA), lack of energy conservation in adiabatic")
      print("dynamical core (dADIA), energy discrepancy (EDIFF) and energy lost/gained in physics-dynamics coupling")
      print(" ")
      str="dPDC+EDIFF"
      print(" ")
      print("		-pEFIX = pDMEA+dADIA+"+str)
      print("            ")
      dPDC = -pEFIX-pDMEA-dADIA
      print("          => "+str+" = -pEFIX-pDMEA-dADIA = "+sprintf("%6.3g",dPDC))
      if (te_consistent_version.eq."False") then
        discr = sprintf("%6.3g",dPDC)
      end if


      qneg  = (tot_energy(ipBF)-tot_energy(idED))/dtime
      print(" ")
      print(" qneg: "+qneg)
      print(" ")


      ;
      ; write diagnostics to file
      ;
      str1 = qsize_condensate_loading+"                       &"
      str1 = str1 + " "+lcp_moist+"   &"      
      str1 = str1 + " "+ftype+"   &"      
      str1 = str1 + " "+sprintf("%6.3g",10*param)+"&"
      str1 = str1 + " "+sprintf("%6.3g",10*pDMEA)+"&"
      str1 = str1 + " "+sprintf("%6.3g",10*pEFIX)+"&"
      str1 = str1 + " "+discr+"&"
      str1 = str1 + " "+sprintf("%6.3g",10*rate_of_change_2D_dyn)+"&"
      str1 = str1 + " "+sprintf("%6.3g",10*rate_of_change_hypervis_total)+"&"
      str1 = str1 + " "+sprintf("%6.3g",10*rate_of_change_heating_term_put_back_in)+"&"
;      str1 = str1 + " "+sprintf("%6.3g",10*twoDresidual)+"&"
      str1 = str1 + " "+sprintf("%6.3g",10*twoDresidual)+"&"
      str1 = str1 + " "+sprintf("%6.3g",10*rate_of_change_vertical_remapping)+"&"
      str1 = str1 + " "+sprintf("%6.3g",10*dADIA)+"&"
;      str1 = str1 + " "+sprintf("%6.3g",10*value_pdc)
      str1 = str1 + " "+str_pdc

      if (fileexists(diags_fname)) then
        c1 = (/str1/)
        alist   = [/c1/]
        write_table(diags_fname, "a", alist, "%s")
      else
        c1 = (/"#qsize_condensate_loading cpmoist  ftype param     pwork     efix      discr     2D         hvis       fheat     res       remap      adiab      PDC",str1/)
        alist   = [/c1/]
        write_table(diags_fname, "w", alist, "%s")
      end if


    end if

    if (qsize.gt.0) then
      print("    ")
      print("    ")
      print(" ")
      print("=================================================================================")
      print("|                                                                               |")
      print("| ANALYSIS OF WATER VAPOR, CLOUD LIQUID AND CLOUD ICE BUDGETS                   |")
      print("|                                                                               |")
      print("=================================================================================")
      print(" ")
      print(" ")
    end if
    do m_cnst=0,qsize-1
      if (m_cnst.eq.0) then 
        print("Water vapor")
        print("-----------")
      end if
      if (m_cnst.eq.1) then
        print("Cloud liquid")
        print("------------")
      end if
      if (m_cnst.eq.2) then 
        print("Cloud ice")
        print("---------")
      end if
      print(" ")

      pEFIX    = (tracer_mass(m_cnst,ipBP)-tracer_mass(m_cnst,ipBF))/dtime
      pDMEA = (tracer_mass(m_cnst,ipAM)-tracer_mass(m_cnst,ipAP))/dtime
      param           = (tracer_mass(m_cnst,ipAP)-tracer_mass(m_cnst,ipBP))/dtime
      dyn_total       = (tracer_mass(m_cnst,idBF)-tracer_mass(m_cnst,idED))/dtime
      phys_total      = (tracer_mass(m_cnst,ipAM)-tracer_mass(m_cnst,ipBF))/dtime    

      print("dMASS/dt energy fixer                      (pBP-pBF) "+sprintf("%6.3g",pEFIX)+" Pa")
      print("dMASS/dt parameterizations                 (pAP-pBP) "+sprintf("%6.3g",param)+" Pa")
      print("dMASS/dt dry mass adjustment               (pAM-pAP) "+sprintf("%6.3g",pDMEA)+" Pa")
      print(" ")
      value = pEFIX+pDMEA
      print("=> dMASS/dt dynamical core (estimated from physics)  ")
      print("   dMASS/dt energy fixer + dMASS/dt dry mass adjustment "+sprintf("%6.3g",value)+" Pa")
 
      print("=> dMASS/dt physics total                   (pAM-pBF)"+sprintf("%6.3g",phys_total)+" Pa")


      print("  ")
      print("  ")
      print("  ")

      rate_of_change_2D_dyn = (tracer_mass(m_cnst,idAD)-tracer_mass(m_cnst,idBD))/dtime
      rate_of_change_vertical_remapping = (tracer_mass(m_cnst,idAR)-tracer_mass(m_cnst,idAD))/dtime
      dADIA = rate_of_change_2D_dyn+rate_of_change_vertical_remapping
      print("dE/dt total adiabatic dynamics                    "+sprintf("%6.3g",dADIA)+" Pa")    
      print("dE/dt 2D dynamics                       (dAD-dBD) "+sprintf("%6.3g",rate_of_change_2D_dyn)+" Pa")
      print("dE/dt vertical remapping                (dAR-dAD) "+sprintf("%6.3g",rate_of_change_vertical_remapping)+" Pa")

      print(" ")
      print("Breakdown of 2D dynamics:")
      print(" ")
      rate_of_change_heating_term_put_back_in = (tracer_mass(m_cnst,idAH)-tracer_mass(m_cnst,idCH))/dtime
      rate_of_change_hypervis_total           = (tracer_mass(m_cnst,idAH)-tracer_mass(m_cnst,idBH))/dtime
      print("      dE/dt hypervis                    (dAH-dBH) "+sprintf("%6.3g",rate_of_change_hypervis_total)+" Pa")
      print("      dE/dt frictional heating          (dAH-dCH) "+sprintf("%6.3g",rate_of_change_heating_term_put_back_in)+" Pa")
      error = rate_of_change_2D_dyn-rate_of_change_hypervis_total
      print("      dE/dt residual (time truncation errors)     "+sprintf("%6.3g",error)+" Pa")

      print(" ")

      print(" ")

      rate_of_change_physics = (tracer_mass(m_cnst,idBD)-tracer_mass(m_cnst,idAF))/dtime
      print("dE/dt physics tendency in dynamics      (dBD-dAF) "+sprintf("%6.3g",rate_of_change_physics)+" Pa")
      value = phys_total-rate_of_change_physics
      if (ftype .eq. "1") then
        print(" ")
        print("      Consistency check:")
        print(" ")
        print("      dE/dt physics tendency in dynamics (dBD-dAF) should exactly match dE/dt physics total (pAM-pBF):"+sprintf("%6.3g",value))
        print(" ")
      else
        print("Dribbling errors (pAM-pBF-(dBD-dAF))"+sprintf("%6.3g",value))
      end if

      print(" ")
      print("---------------------------------------------------------------------------------------------------")
      print(" ")
     end do

 end do
end


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;;;ARH - 03/2018 - Modified to work for CAM-SE-CSLAM physics grid w/ pgx flag

begin
  print("Summary of input to ncl script:")
  print("===============================")
  print(" ")
  print("nsplit                   ="+nsplit)
  print("rsplit                   ="+rsplit)
  print("hypervis_subcycle        ="+hypervis_subcycle)
  print("ftype                    ="+ftype)
  print("qsize_condensate_loading ="+qsize_condensate_loading)
  print("dtime            ="+dtime)
  fname =  systemfunc("ls "+fname)
  print("File used for energy diagnostics "+fname)
  print("done input summary")
  print(" ")
  fall = addfile(fname,"r")       ; Open netCDF files.	
  ;
  ; check if physics-dynamics variables are present
  ;
  if (isfilevardim(fall,"SE_dED","ncol_d")) then
    print("File appears to have separate grids for physics and dynamics - setting pgx=True")
    pgx = True
  else
    print("File appears to be have the same grid for physics and dynamics - setting pgx=False")
    pgx = False
  end if
  ;
  ; initialization
  ;
  g = 9.80665D0
  nc        = -1
  eps       = 1.0D-13
  tmp       = fall->SE_dED(:,:)
  nt        = dimsizes(tmp(:,0))
  ncol      = dimsizes(tmp(0,:))
  if (pgx) then
    tmp_p     = fall->SE_pAM(:,:)
    ncol_p    = dimsizes(tmp_p(0,:))
    area_p    = fall->area   (:  )
    area      = fall->area_d (:  )
  else
    area      = fall->area   (:  )
  end if
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
  
  if (isfilevar(fall,"WV_PDC") .and. (.not.pgx)) then
    ;;; this is not consistent with pgx=True
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
  if (.not.pgx) then
    nstage      = dimsizes(str_stage)
    vars        = new((/nvars,nstage,nt,ncol/),typeof(tmp(0,0)))
    nstage_p    = 0
  else
    nstage      = 9 ;;; to do - use strongtochar, search for 'd' suffix
    vars        = new((/nvars,nstage,nt,ncol/),typeof(tmp(0,0)))
    nstage_p    = 4 ;;; to do - use strongtochar, search for 'p' suffix
    vars_p      = new((/nvars,nstage_p,nt,ncol_p/),typeof(tmp(0,0)))
  end if
  subcycle    = new((/nstage+nstage_p/),typeof(tmp(0,0)))

  if (wet) then
    subcycle    = (/1D0,1D0,1D0,1D0,1.0D0,nsplit,nsplit,nsplit,nsplit,1.0D0,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle/)
  else
    subcycle    = (/1.0D0,nsplit,nsplit,nsplit,nsplit,1.0D0,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle/)
  end if

  tot_energy  = new((/nstage+nstage_p/),typeof(tmp(0,0)))
  tracer_mass = new((/3,nstage+nstage_p/),typeof(tmp(0,0)))

  int_vars  = new((/nvars,nstage+nstage_p,nt/)     ,typeof(tmp(0,0)))
  int_vars  = 0.0D0
  ;
  ; check that variables are on file and read them
  ;
  do k=0,nvars-1
    do j=0,nstage-1
      str = str_vars(k)+"_"+str_stage(nstage_p+j)
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
        int_vars(variable,stages+nstage_p,t) = sum(area(0:ncol-1)*vars(variable,stages,t,0:ncol-1))*inv_area_sphere
      end do
    end do
  end do

  if (pgx) then
    ;
    ; check that variables are on file and read them
    ;
    do k=0,nvars-1
      do j=0,nstage_p-1
        str = str_vars(k)+"_"+str_stage(j)
        if (isfilevar(fall,str)) then
          vars_p(k,j,:,0:ncol_p-1) = fall->$str$(:,:)
        else
          print("Variable "+str+" not found")
          exit
        end if
      end do
    end do
    ;
    ; compute global integrals
    ; 
    area_sphere_p = sum(area_p(0:ncol_p-1))
    print("Area of sphere in dataset is : "+area_sphere_p)
    inv_area_sphere_p = 1.0D0/area_sphere_p 
    do t=0,nt-1
      do variable = 0,nvars-1
        do stages=0,nstage_p-1
          int_vars(variable,stages,t) = sum(area_p(0:ncol_p-1)*vars(variable,stages,t,0:ncol_p-1))*inv_area_sphere_p
        end do
      end do
    end do
    ;redefine nstage to its appropriate meeaning
    nstage = dimsizes(str_stage)
  end if
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


    if (qsize_condensate_loading.eq."1") then
       print("Since qsize_condensate_loading=1 the same less accurate formula for energy is used")
       print("in dynamics and physics (cp=cp_dry in internal energy).")
    else
       print("WARNING: Since qsize_condensate_loading>1 different formulas for dynamics and physics are used")
       print("in dynamics (cp and dp includes all water variables) and physics (cp=cp_dry in internal energy).")
    end if

   if (PhysDiags) then
      pEFIX    = (tot_energy(ipBP)-tot_energy(ipBF))/dtime
      pDMEA = (tot_energy(ipAM)-tot_energy(ipAP))/dtime
      param           = (tot_energy(ipAP)-tot_energy(ipBP))/dtime
      phys_total      = (tot_energy(ipAM)-tot_energy(ipBF))/dtime
    end if
    dyn_total       = (tot_energy(idBF)-tot_energy(idED))/dtime

    if (PhysDiags) then
    print(" ")
    print("=================================================================================")
    print("|                                                                               |")
    print("| ANALYSIS OF ENERGY DIAGNOSTICS IN PHYSCS                                      |")
    print("|                                                                               |")
    print("=================================================================================")
    print(" ")
    print("dE/dt energy fixer                      (pBP-pBF) "+sprintf("%6.4g",pEFIX)+" W/M^2")
    print("dE/dt parameterizations                 (pAP-pBP) "+sprintf("%6.4g",param)+" W/M^2")
    print("dE/dt dry mass adjustment               (pAM-pAP) "+sprintf("%6.4g",pDMEA)+" W/M^2")
    print(" ")
    value = pEFIX+pDMEA
    print("=> dE/dt dynamical core (estimated from physics)  ")
    print("   dE/dt energy fixer + dE/dt dry mass adjustment "+sprintf("%6.4g",value)+" W/M^2")
    
    print("=> dE/dt physics total                   (pAM-pBF)"+sprintf("%6.4g",phys_total)+" W/M^2")
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
    print("dE/dt total adiabatic dynamics                    "+sprintf("%6.4g",dADIA)+" W/M^2")    
    print("dE/dt 2D dynamics                       (dAD-dBD) "+sprintf("%6.4g",rate_of_change_2D_dyn)+" W/M^2")
    print("dE/dt vertical remapping                (dAR-dAD) "+sprintf("%6.4g",rate_of_change_vertical_remapping)+" W/M^2")

    print(" ")
    print("Breakdown of 2D dynamics:")
    print(" ")
    rate_of_change_heating_term_put_back_in = (tot_energy(idAH)-tot_energy(idCH))/dtime
    rate_of_change_hypervis_total           = (tot_energy(idAH)-tot_energy(idBH))/dtime
    print("      dE/dt hypervis                    (dAH-dBH) "+sprintf("%6.4g",rate_of_change_hypervis_total)+" W/M^2")
    print("      dE/dt frictional heating          (dAH-dCH) "+sprintf("%6.4g",rate_of_change_heating_term_put_back_in)+" W/M^2")
    error = rate_of_change_2D_dyn-rate_of_change_hypervis_total
    print("      dE/dt residual (time truncation errors)     "+sprintf("%6.4g",error)+" W/M^2")

    print(" ")

    print(" ")

    if (PhysDiags) then
      rate_of_change_physics = (tot_energy(idBD)-tot_energy(idAF))/dtime
      print("dE/dt physics tendency in dynamics      (dBD-dAF) "+sprintf("%6.4g",rate_of_change_physics)+" W/M^2")
      value = phys_total-rate_of_change_physics
      if (ftype .eq. "1") then
        print(" ")
        print("      Consistency check:")
        print(" ")
       print("      dE/dt physics tendency in dynamics (dBD-dAF) should exactly match dE/dt physics total (pAM-pBF):"+sprintf("%6.4g",value))
        print(" ")
      else
        print("Dribbling errors (pAM-pBF-(dBD-dAF))"+sprintf("%6.4g",value))
      end if
      print("Energy fixer fixes dme_adjust (pDMEA), lack of energy conservation in adiabatic")
      print("dynamical core (dADIA) and energy lost/gained in physics-dynamics coupling")
      if (qsize_condensate_loading.eq."1") then
        print("(dPDC):")
        str="dPDC"
      else
        print("(dPDC) and the difference between the energy definition in dynamics and physics (EDIFF):")
        str="dPDC+EDIFF"
      end if
      print(" ")
      print("		-pEFIX = pDMEA+dADIA+"+str)
      print("            ")
      dPDC = -pEFIX-pDMEA-dADIA
      print("          => "+str+" = -pEFIX-pDMEA-dADIA = "+sprintf("%6.4g",dPDC))
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

      print("dMASS/dt energy fixer                      (pBP-pBF) "+sprintf("%6.4g",pEFIX)+" Pa")
      print("dMASS/dt parameterizations                 (pAP-pBP) "+sprintf("%6.4g",param)+" Pa")
      print("dMASS/dt dry mass adjustment               (pAM-pAP) "+sprintf("%6.4g",pDMEA)+" Pa")
      print(" ")
      value = pEFIX+pDMEA
      print("=> dMASS/dt dynamical core (estimated from physics)  ")
      print("   dMASS/dt energy fixer + dMASS/dt dry mass adjustment "+sprintf("%6.4g",value)+" Pa")
 
      print("=> dMASS/dt physics total                   (pAM-pBF)"+sprintf("%6.4g",phys_total)+" Pa")


      print("  ")
      print("  ")
      print("  ")

      rate_of_change_2D_dyn = (tracer_mass(m_cnst,idAD)-tracer_mass(m_cnst,idBD))/dtime
      rate_of_change_vertical_remapping = (tracer_mass(m_cnst,idAR)-tracer_mass(m_cnst,idAD))/dtime
      dADIA = rate_of_change_2D_dyn+rate_of_change_vertical_remapping
      print("dE/dt total adiabatic dynamics                    "+sprintf("%6.4g",dADIA)+" Pa")    
      print("dE/dt 2D dynamics                       (dAD-dBD) "+sprintf("%6.4g",rate_of_change_2D_dyn)+" Pa")
      print("dE/dt vertical remapping                (dAR-dAD) "+sprintf("%6.4g",rate_of_change_vertical_remapping)+" Pa")

      print(" ")
      print("Breakdown of 2D dynamics:")
      print(" ")
      rate_of_change_heating_term_put_back_in = (tracer_mass(m_cnst,idAH)-tracer_mass(m_cnst,idCH))/dtime
      rate_of_change_hypervis_total           = (tracer_mass(m_cnst,idAH)-tracer_mass(m_cnst,idBH))/dtime
      print("      dE/dt hypervis                    (dAH-dBH) "+sprintf("%6.4g",rate_of_change_hypervis_total)+" Pa")
      print("      dE/dt frictional heating          (dAH-dCH) "+sprintf("%6.4g",rate_of_change_heating_term_put_back_in)+" Pa")
      error = rate_of_change_2D_dyn-rate_of_change_hypervis_total
      print("      dE/dt residual (time truncation errors)     "+sprintf("%6.4g",error)+" Pa")

      print(" ")

      print(" ")

      rate_of_change_physics = (tracer_mass(m_cnst,idBD)-tracer_mass(m_cnst,idAF))/dtime
      print("dE/dt physics tendency in dynamics      (dBD-dAF) "+sprintf("%6.4g",rate_of_change_physics)+" Pa")
      value = phys_total-rate_of_change_physics
      if (ftype .eq. "1") then
        print(" ")
        print("      Consistency check:")
        print(" ")
        print("      dE/dt physics tendency in dynamics (dBD-dAF) should exactly match dE/dt physics total (pAM-pBF):"+sprintf("%6.4g",value))
        print(" ")
      else
        print("Dribbling errors (pAM-pBF-(dBD-dAF))"+sprintf("%6.4g",value))
      end if

      print(" ")
      print("---------------------------------------------------------------------------------------------------")
      print(" ")
     end do

 end do
end


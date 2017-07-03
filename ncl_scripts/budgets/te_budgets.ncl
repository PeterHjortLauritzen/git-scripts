load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

undef("pass")
procedure pass(error,eps)
begin
  if(abs(error).lt.eps) then
     print("PASS")
  else
     print("FAIL") 
;     exit()
  end if
end




begin
  print("Summary of input to ncl script:")
  print("===============================")
  print("rsplit           ="+nsplit)
  print("rsplit           ="+rsplit)
  print("hypervis_subcycle="+hypervis_subcycle)
  print("ftype            ="+ftype)
  print("dtime            ="+dtime)
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
  tmp       = fall->WV_dED(:,:)
  nt        = dimsizes(tmp(:,0))
  delete(tmp)

  tmp       = fall->WV_pBF(:,:)
  nt_d      = dimsizes(tmp(:,0))
  ncol      = dimsizes(tmp(0,:))

  if (nt.ne.nt_d) then
    print("nt and nt_d not the same")
    exit()
  end if

  ;
  ; check if physics-dynamics variables are present
  ;
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
  print("suffix (parameterization side)")
  print("pBF: state passed to parameterizations, before energy fixer")
  print("pBP: after energy fixer, before parameterizations")
  print("pAP: after last phys_update in parameterizations and state saved for energy fixer")
  print("pAM: after dry mass correction calculate but not used in SE")
  print(" ")
  print("history files saved off here")
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


  str_vars      = (/"SE","KE","WV","WL","WI"/);,"TT"/)
  str_stage     = (/"pBF","pBP","pAP","pAM","dED","dAF","dBD","dAD","dAR","dBF","dBH","dCH","dAH"/)

  nvars  = dimsizes(str_vars)
  nstage = dimsizes(str_stage)
  vars      = new((/nvars,nstage,nt,ncol/),typeof(tmp(0,0)))


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

  do t=0,nt-1
    print("t="+t)
    stage          = str_match_ind(str_stage,"pBF")
    tot_energy_pBF = (int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = str_match_ind(str_stage,"pBP")
    tot_energy_pBP = (int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = str_match_ind(str_stage,"pAP")
    tot_energy_pAP = (int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = str_match_ind(str_stage,"pAM")
    tot_energy_pAM = (int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = str_match_ind(str_stage,"dED")
    tot_energy_dED = (int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = str_match_ind(str_stage,"dAF")
    tot_energy_dAF = nsplit*(int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = str_match_ind(str_stage,"dBD")
    tot_energy_dBD = nsplit*(int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = str_match_ind(str_stage,"dAD")
    tot_energy_dAD = nsplit*(int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = str_match_ind(str_stage,"dAR")
    tot_energy_dAR = nsplit*(int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = str_match_ind(str_stage,"dBF")
    tot_energy_dBF = (int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = str_match_ind(str_stage,"dBH")
    tot_energy_dBH = nsplit*rsplit*hypervis_subcycle*(int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = str_match_ind(str_stage,"dCH")
    tot_energy_dCH = nsplit*rsplit*hypervis_subcycle*(int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = str_match_ind(str_stage,"dAH")
    tot_energy_dAH = nsplit*rsplit*hypervis_subcycle*(int_vars(0,stage,t)+int_vars(1,stage,t))
    
    print("  ")
    print("  ")
    print("  ")
    print("ANALYSIS_START_ANALYSIS_START_ANALYSIS_START_ANALYSIS_START_ANALYSIS_START_ANALYSIS_START")
    print("  ")
    print("  ")
    print("  ")

    energy_fixer    = (tot_energy_pBP-tot_energy_pBF)/dtime
    phys_dme_adjust = (tot_energy_pAM-tot_energy_pAP)/dtime
    param           = (tot_energy_pAP-tot_energy_pBP)/dtime
    dyn_total       = (tot_energy_dBF-tot_energy_dED)/dtime
    phys_total      = (tot_energy_pAM-tot_energy_pBF)/dtime

    print(" ")
    print("=================================================================================")
    print("|                                                                               |")
    print("| ANALYSIS OF ENERGY DIAGNOSTICS IN PHYSCS                                      |")
    print("|                                                                               |")
    print("=================================================================================")
    print(" ")
    print("dE/dt energy fixer                      (pBP-pBF) "+sprintf("%6.4g",energy_fixer)+" W/M^2")
    print("dE/dt parameterizations                 (pAP-pBP) "+sprintf("%6.4g",param)+" W/M^2")
    print("dE/dt dry mass adjustment               (pAM-pAP) "+sprintf("%6.4g",phys_dme_adjust)+" W/M^2")
    print(" ")
    value = energy_fixer+phys_dme_adjust
    print("=> dE/dt dynamical core (estimated from physics)  ")
    print("   dE/dt energy fixer + dE/dt dry mass adjustment "+sprintf("%6.4g",value)+" W/M^2")

    print("=> dE/dt physics total                   (pAM-pBF)"+sprintf("%6.4g",phys_total)+" W/M^2")
    print(" ")
    print("=================================================================================")
    print("|                                                                               |")
    print("| ANALYSIS OF ENERGY DIAGNOSTICS IN DYNAMICS                                    |")
    print("|                                                                               |")
    print("=================================================================================")
    print(" ")

    rate_of_change_2D_dyn = (tot_energy_dAD-tot_energy_dBD)/dtime
    rate_of_change_vertical_remapping = (tot_energy_dAR-tot_energy_dAD)/dtime
    rate_of_change_adiabatic_dyn = rate_of_change_2D_dyn+rate_of_change_vertical_remapping
    print("dE/dt total adiabatic dynamics                    "+sprintf("%6.4g",rate_of_change_adiabatic_dyn)+" W/M^2")    
    print("dE/dt 2D dynamics                       (dAD-dBD) "+sprintf("%6.4g",rate_of_change_2D_dyn)+" W/M^2")
    print("dE/dt vertical remapping                (dAR-dAD) "+sprintf("%6.4g",rate_of_change_vertical_remapping)+" W/M^2")

    print(" ")
    print("Breakdown of 2D dynamics:")
    print(" ")
    rate_of_change_heating_term_put_back_in = (tot_energy_dAH-tot_energy_dCH)/dtime
    rate_of_change_hypervis_total           = (tot_energy_dAH-tot_energy_dBH)/dtime
    print("      dE/dt hypervis                    (dAH-dBH) "+sprintf("%6.4g",rate_of_change_hypervis_total)+" W/M^2")
    print("      dE/dt frictional heating          (dAH-dCH) "+sprintf("%6.4g",rate_of_change_heating_term_put_back_in)+" W/M^2")
    error = rate_of_change_2D_dyn-rate_of_change_hypervis_total
    print("      dE/dt residual (time truncation errors)     "+sprintf("%6.4g",error)+" W/M^2")

    print(" ")

    print(" ")

    rate_of_change_physics = (tot_energy_dBD-tot_energy_dAF)/dtime
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

 end do
end


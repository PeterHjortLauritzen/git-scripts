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
  fname =  systemfunc("ls "+fname)
  print("File used for energy diagnostics "+fname)
  ftype = 0
  if (ftype.eq.0) then
;    fname =  systemfunc("ls pel_energy_ftype0_001.cam.h0.2000-03.nc")
  else
;    fname =  systemfunc("ls pel_energy_ftype1_001.cam.h0.2000-03.nc")
  end if
  fall = addfile(fname,"r")       ; Open netCDF files.	


  print("ftype="+ftype)

  
  ;
  ; initialization
  ;
  g = 9.80665D0
  nsplit            = 2.0D0
  rsplit            = 3.0D0
  hypervis_subcycle = 3.0D0
  nc        = -1
  dtime     = 1800.0D0
  eps       = 1.0D-13
  area_p    = fall->area   (:  )
  if (nc.gt.0) then
    area_d    = fall->area_d (:  )
  else
    area_d = area_p
  end if
  tmp       = fall->WV_dED(:,:)
  nt        = dimsizes(tmp(:,0))
  ncol_d    = dimsizes(tmp(0,:))
  delete(tmp)

  tmp       = fall->WV_pBF(:,:)
  nt_d      = dimsizes(tmp(:,0))
  ncol_p    = dimsizes(tmp(0,:))

  if (ncol_d.gt.ncol_p)
    ncol = ncol_d
  else
    ncol = ncol_p
  end if
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


  vars      = new((/6,14,nt,ncol/),typeof(tmp(0,0)))

  int_vars  = new((/6,14,nt/)     ,typeof(tmp(0,0)))

  int_water_chg_due_to_parameterizations  = new((/nt/),typeof(tmp(0,0)))

  int_vars      = 0;xxxx .0D0

  str_vars      = (/"SE","KE","WV","WL","WI","TT"/)
  str_stage     = (/"pBF","pBP","pAP","pAM","dED","dAF","dBM","dBD","dAD","dAR","dBF","dBH","dCH","dAH"/)


  if (pdc_vars_present) then
    str_vars_pdc  = (/"WV","WL","WI","TT"/)

    vars_pdc(0,:,0:ncol_d-1) = fall->WV_PDC(:,:)
    vars_pdc(1,:,0:ncol_d-1) = fall->WL_PDC(:,:)
    vars_pdc(2,:,0:ncol_d-1) = fall->WI_PDC(:,:)
    if (TT_vars_present) then
      vars_pdc(3,:,0:ncol_d-1) = fall->TT_PDC(:,:)
    end if
  end if




  vars(0, 0,:,0:ncol_p-1) = fall->SE_pBF(:,:)
  vars(0, 1,:,0:ncol_p-1) = fall->SE_pBP(:,:)
  vars(0, 2,:,0:ncol_p-1) = fall->SE_pAP(:,:)
  vars(0, 3,:,0:ncol_p-1) = fall->SE_pAM(:,:)

  vars(0, 4,:,0:ncol_d-1) = fall->SE_dED(:,:)
  vars(0, 5,:,0:ncol_d-1) = fall->SE_dAF(:,:)
  vars(0, 6,:,0:ncol_d-1) = fall->SE_dAF(:,:) ;used to be dBM xxxxx
  vars(0, 7,:,0:ncol_d-1) = fall->SE_dBD(:,:)
  vars(0, 8,:,0:ncol_d-1) = fall->SE_dAD(:,:)
  vars(0, 9,:,0:ncol_d-1) = fall->SE_dAR(:,:)
  vars(0,10,:,0:ncol_d-1) = fall->SE_dBF(:,:)
  vars(0,11,:,0:ncol_d-1) = fall->SE_dBH(:,:)
  vars(0,12,:,0:ncol_d-1) = fall->SE_dCH(:,:)
  vars(0,13,:,0:ncol_d-1) = fall->SE_dAH(:,:)



  vars(1, 0,:,0:ncol_p-1) = fall->KE_pBF(:,:)
  vars(1, 1,:,0:ncol_p-1) = fall->KE_pBP(:,:)
  vars(1, 2,:,0:ncol_p-1) = fall->KE_pAP(:,:)
  vars(1, 3,:,0:ncol_p-1) = fall->KE_pAM(:,:)

  vars(1, 4,:,0:ncol_d-1) = fall->KE_dED(:,:)
  vars(1, 5,:,0:ncol_d-1) = fall->KE_dAF(:,:)
  vars(1, 6,:,0:ncol_d-1) = fall->KE_dAF(:,:) ;used to be dBM xxxxx
  vars(1, 7,:,0:ncol_d-1) = fall->KE_dBD(:,:)
  vars(1, 8,:,0:ncol_d-1) = fall->KE_dAD(:,:)
  vars(1, 9,:,0:ncol_d-1) = fall->KE_dAR(:,:)
  vars(1,10,:,0:ncol_d-1) = fall->KE_dBF(:,:)
  vars(1,11,:,0:ncol_d-1) = fall->KE_dBH(:,:)
  vars(1,12,:,0:ncol_d-1) = fall->KE_dCH(:,:)
  vars(1,13,:,0:ncol_d-1) = fall->KE_dAH(:,:)



  vars(2, 0,:,0:ncol_p-1) = fall->WV_pBF(:,:)
  vars(2, 1,:,0:ncol_p-1) = fall->WV_pBP(:,:)
  vars(2, 2,:,0:ncol_p-1) = fall->WV_pAP(:,:)
  vars(2, 3,:,0:ncol_p-1) = fall->WV_pAM(:,:)

  vars(2, 4,:,0:ncol_d-1) = fall->WV_dED(:,:)
  vars(2, 5,:,0:ncol_d-1) = fall->WV_dAF(:,:)
  vars(2, 6,:,0:ncol_d-1) = fall->WV_dAF(:,:) ;used to be dBM xxxxx
  vars(2, 7,:,0:ncol_d-1) = fall->WV_dBD(:,:)
  vars(2, 8,:,0:ncol_d-1) = fall->WV_dAD(:,:)
  vars(2, 9,:,0:ncol_d-1) = fall->WV_dAR(:,:)
  vars(2,10,:,0:ncol_d-1) = fall->WV_dBF(:,:)
  vars(2,11,:,0:ncol_d-1) = fall->WV_dBH(:,:)
  vars(2,12,:,0:ncol_d-1) = fall->WV_dCH(:,:)
  vars(2,13,:,0:ncol_d-1) = fall->WV_dAH(:,:)



  vars(3, 0,:,0:ncol_p-1) = fall->WL_pBF(:,:)
  vars(3, 1,:,0:ncol_p-1) = fall->WL_pBP(:,:)
  vars(3, 2,:,0:ncol_p-1) = fall->WL_pAP(:,:)
  vars(3, 3,:,0:ncol_p-1) = fall->WL_pAM(:,:)

  vars(3, 4,:,0:ncol_d-1) = fall->WL_dED(:,:)
  vars(3, 5,:,0:ncol_d-1) = fall->WL_dAF(:,:)
  vars(3, 6,:,0:ncol_d-1) = fall->WL_dAF(:,:) ;used to be dBM xxxxx
  vars(3, 7,:,0:ncol_d-1) = fall->WL_dBD(:,:)
  vars(3, 8,:,0:ncol_d-1) = fall->WL_dAD(:,:)
  vars(3, 9,:,0:ncol_d-1) = fall->WL_dAR(:,:)
  vars(3,10,:,0:ncol_d-1) = fall->WL_dBF(:,:)
  vars(3,11,:,0:ncol_d-1) = fall->WL_dBH(:,:)
  vars(3,12,:,0:ncol_d-1) = fall->WL_dCH(:,:)
  vars(3,13,:,0:ncol_d-1) = fall->WL_dAH(:,:)



  vars(4, 0,:,0:ncol_p-1) = fall->WI_pBF(:,:)
  vars(4, 1,:,0:ncol_p-1) = fall->WI_pBP(:,:)
  vars(4, 2,:,0:ncol_p-1) = fall->WI_pAP(:,:)
  vars(4, 3,:,0:ncol_p-1) = fall->WI_pAM(:,:)

  vars(4, 4,:,0:ncol_d-1) = fall->WI_dED(:,:)
  vars(4, 5,:,0:ncol_d-1) = fall->WI_dAF(:,:)
  vars(4, 6,:,0:ncol_d-1) = fall->WI_dAF(:,:) ;used to be dBM xxxxx
  vars(4, 7,:,0:ncol_d-1) = fall->WI_dBD(:,:)
  vars(4, 8,:,0:ncol_d-1) = fall->WI_dAD(:,:)
  vars(4, 9,:,0:ncol_d-1) = fall->WI_dAR(:,:)
  vars(4,10,:,0:ncol_d-1) = fall->WI_dBF(:,:)
  vars(4,11,:,0:ncol_d-1) = fall->WI_dBH(:,:)
  vars(4,12,:,0:ncol_d-1) = fall->WI_dCH(:,:)
  vars(4,13,:,0:ncol_d-1) = fall->WI_dAH(:,:)



  if (TT_vars_present) then
    vars(5, 0,:,0:ncol_p-1) = fall->TT_pBF(:,:)
    vars(5, 1,:,0:ncol_p-1) = fall->TT_pBP(:,:)
    vars(5, 2,:,0:ncol_p-1) = fall->TT_pAP(:,:)
    vars(5, 3,:,0:ncol_p-1) = fall->TT_pAM(:,:)

    vars(5, 4,:,0:ncol_d-1) = fall->TT_dED(:,:)
    vars(5, 5,:,0:ncol_d-1) = fall->TT_dAF(:,:)
    vars(5, 6,:,0:ncol_d-1) = fall->TT_dAF(:,:) ;used to be dBM xxxxx
    vars(5, 7,:,0:ncol_d-1) = fall->TT_dBD(:,:)
    vars(5, 8,:,0:ncol_d-1) = fall->TT_dAD(:,:)
    vars(5, 9,:,0:ncol_d-1) = fall->TT_dAR(:,:)
    vars(5,10,:,0:ncol_d-1) = fall->TT_dBF(:,:)
    vars(5,11,:,0:ncol_d-1) = fall->TT_dBH(:,:)
    vars(5,12,:,0:ncol_d-1) = fall->TT_dCH(:,:)
    vars(5,13,:,0:ncol_d-1) = fall->TT_dAH(:,:)
  end if
;  qflx  = fall->QFLX(:,:) ; surface water flux
;  precc = fall->PRECC(:,:)
;  precl = fall->PRECL(:,:)

  ;
  ; compute average values
  ;
  area_sphere = sum(area_p(0:ncol_p-1))
  print("Area of sphere in dataset is : "+area_sphere)
  inv_area_sphere = 1.0D0/area_sphere

;  rho_h2o = 
  do t=0,nt-1
    do variable = 0,5
      do stages=0,3
        print("var="+variable+"  stage="+stages)
        int_vars(variable,stages,t) = sum(area_p(0:ncol_p-1)*vars(variable,stages,t,0:ncol_p-1))*inv_area_sphere
      end do
      do stages=4,13
        int_vars(variable,stages,t) = sum(area_d(0:ncol_d-1)*vars(variable,stages,t,0:ncol_d-1))*inv_area_sphere
      end do
    end do
;    int_water_chg_due_to_parameterizations(t) = sum(area_d(0:ncol_d-1)*(\
;    					      qflx(t,0:ncol_d-1)-rho_h2O*(precc(t,0:ncol_d-1)+precl(t,0:ncol_d-1))))
    print("done "+t)
  end do
  if (pdc_vars_present) then
    do t=0,nt-1
      do variable = 0,3
        int_vars_pdc(variable,t) = sum(area_d(0:ncol_d-1)*vars_pdc(variable,t,0:ncol_d-1))*inv_area_sphere
      end do
    end do
  end if
  ;
  ;
  ;
  do t=0,nt-1 ;nt-1
    do variable=0,5
      print("TOTAL STAGES at t="+t)
      print("=========================")
      print(" ")
      do stages=0,13
        print(str_vars(variable)+" at "+str_stage(stages)+": "+sprintf("%17.11e",int_vars(variable,stages,t)))
        print(str_vars(variable)+" in hPa "+str_stage(stages)+": "+sprintf("%17.11e",int_vars(variable,stages,t)*g*0.01))
      end do
      if (pdc_vars_present) then
         if (variable.gt.1) then
            print(str_vars_pdc(variable-2)+" : "+sprintf("%17.11e",int_vars_pdc(variable-2,t)))
     	    d = int_vars(variable,5,t)-int_vars_pdc(variable-2,t)
            print(sprintf("%17.11e",d))
         end if
      end if
    end do
    print(" ")    
 end do
  if (pdc_vars_present) then
    do t=0,nt-1 ;nt-1
      do variable=0,3
        print("PDC vars at t="+t)
        print("=========================")
        print(" ")
        print(str_vars_pdc(variable)+" : "+int_vars_pdc(variable,t))
      end do
    end do
  end if
 ;

 ;
 do t=0,nt-1 ;nt-1
  do variable=0,4
     print("========================================================================")
     print(" ")
     print(" STARTING VARIABLE "+str_vars(variable)+" at time "+t)
     print(" ")

     if (variable.gt.1) then
       error = (int_vars(variable,3,t)-int_vars(variable,0,t))
       print("physics change absolute: "+error)
       error = ((nsplit*(int_vars(variable,7,t)-int_vars(variable,5,t))))
       print("dynamics change absolute: "+error)
       if (pdc_vars_present) then
          error = -nsplit*int_vars_pdc(variable-2,t)
          print("pdc lost absolute  : "+error)
          error = -nsplit*int_vars_pdc(variable-2,t)/int_vars(variable,0,t)
          print("pdc lost normalized: "+error)
       end if
     end if 
     error = (int_vars(variable,3,t)-int_vars(variable,0,t)-(nsplit*(int_vars(variable,7,t)-int_vars(variable,5,t))))
     if (variable.gt.1) then
       error=error-nsplit*int_vars_pdc(variable-2,t)
     end if
     error = error/int_vars(variable,0,t)

     print("Total tendency error physics versus dynamics (pAM-pBF-nsplit*(dBD-dAF)) = "+error)	
     pass(error,eps)
     print(" ")    


     error = (int_vars(variable,2,t)-int_vars(variable,0,t)-(nsplit*(int_vars(variable,6,t)-int_vars(variable,5,t))))
     if (variable.gt.1) then
       error=error-nsplit*int_vars_pdc(variable-2,t)
     end if
     error = error/int_vars(variable,0,t)

     print("Total tendency error without dry mass adjustment  (pAP-pBF-nsplit*(dBM-dAF)) - should be zero  : "+error)
     pass(error,eps)
     print(" ")    
     if (variable.gt.1) then
        print("PDC "+str_vars_pdc(variable-2)+" : "+nsplit*int_vars_pdc(variable-2,t))
        error = nsplit*int_vars_pdc(variable-2,t)/int_vars(variable,0,t)
        print("PDC "+str_vars_pdc(variable-2)+" : "+error)
     end if

 ;    physics_change_due_to_dry_mass_adj   = (int_vars(variable,3,t)-int_vars(variable,2,t));/int_vars(variable,3,t)
 ;    dynamics_change_due_to_dry_mass_adj  = nsplit*(int_vars(variable,7,t)-int_vars(variable,6,t));/int_vars(variable,7,t)
  ;   error = physics_change_due_to_dry_mass_adj-dynamics_change_due_to_dry_mass_adj
     error = (int_vars(variable,3,t)-int_vars(variable,2,t)-(nsplit*(int_vars(variable,7,t)-int_vars(variable,6,t))))
     error = error/int_vars(variable,0,t)
    
     print("Total tendency error due to dry mass adjustment  (pAM-pAP-nsplit*(dBD-dBM)) - should be zero  : "+error)
     pass(error,eps)
     print(" ")
   end do
 end do

 do t=0,nt-1 ;nt-1
;
; dED is stage 4
;
    stage          = 0
    tot_energy_pBF = (int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = 1
    tot_energy_pBP = (int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = 2
    tot_energy_pAP = (int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = 3
    tot_energy_pAM = (int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = 4
    tot_energy_dED = (int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = 5
    tot_energy_dAF = nsplit*(int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = 6
    tot_energy_dBM = nsplit*(int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = 7
    tot_energy_dBD = nsplit*(int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = 8
    tot_energy_dAD = nsplit*(int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = 9
    tot_energy_dAR = nsplit*(int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = 10
    tot_energy_dBF = (int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = 11
    tot_energy_dBH = nsplit*rsplit*hypervis_subcycle*(int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = 12
    tot_energy_dCH = nsplit*rsplit*hypervis_subcycle*(int_vars(0,stage,t)+int_vars(1,stage,t))
    stage          = 13
    tot_energy_dAH = nsplit*rsplit*hypervis_subcycle*(int_vars(0,stage,t)+int_vars(1,stage,t))
    

    rate_of_change_physicsB = (tot_energy_pBP-tot_energy_pBF)/dtime
    print("Rate of energy change in physics energy fixer          (total: pBP-pBF) "+rate_of_change_physicsB+" W/M^2")

    rate_of_change_physicsC = (tot_energy_pAP-tot_energy_pBP)/dtime
    print("Rate of energy change in physics parameterizations     (total: pAP-pBP) "+rate_of_change_physicsC+" W/M^2")

    rate_of_dry_mass_adjustment = (tot_energy_pAM-tot_energy_pAP)/dtime
    print("Rate of energy change dry mass adj.                    (total: pAM-pAP) "+rate_of_dry_mass_adjustment+" W/M^2")

    rate_of_change_physicsD = (tot_energy_pAM-tot_energy_pBF)/dtime
    print("Rate of energy change in physics TOTAL                 (total: pAM-pBF) "+rate_of_change_physicsD+" W/M^2")

    rate_of_change_physicsA = (tot_energy_pAP-tot_energy_pBF)/dtime
    print("Rate of energy change in physics physics+energy fixer  (total: pAP-pBF) "+rate_of_change_physicsA+" W/M^2")

    print("   ")

    error = rate_of_change_physicsB+rate_of_dry_mass_adjustment
    print("Rate of energy lost in dynamics estimated from physics                  "+error+" W/M^2")

    print ("  ")
    print ("-------------------------------------------------------------------")
    print ("  ")

    rate_of_change_dynamicsA = (tot_energy_dBD-tot_energy_dAF)/dtime
    print("Rate of energy change in dynamics adding param+dry mass adj. (total: dBD-dAF) "+rate_of_change_dynamicsA+" W/M^2")
    error = rate_of_change_dynamicsA-rate_of_change_physicsD
    print("Consistent with physics?                           (total: dBD-dAF-(pAM-pBF)) "+error+" W/M^2")
    rate_of_change_dynamicsE = (tot_energy_dBM-tot_energy_dAF)/dtime
    print("Breakdown: param.                                            (total: dBM-dAF) "+rate_of_change_dynamicsE+" W/M^2")
    rate_of_change_dynamicsD = (tot_energy_dBD-tot_energy_dBM)/dtime
    print("Breakdown: dry-mass adj.                           (total: dBD-dBM) "+rate_of_change_dynamicsD+" W/M^2")
    print("    ")


    rate_of_change_heating_term_put_back_in = (tot_energy_dAH-tot_energy_dCH)/dtime
    rate_of_change_hypervis_total = (tot_energy_dAH-tot_energy_dBH)/dtime
    print("Rate of energy change in hypervis                            (total: dAH-dBH) "+rate_of_change_hypervis_total+" W/M^2")

    rate_of_change_dynamicsB = (tot_energy_dAD-tot_energy_dBD)/dtime
    print("Rate of energy change in horizontal dynamics - incl. hypervis (total: dAD-dBD) "+rate_of_change_dynamicsB+" W/M^2")

    rate_of_change_vertical_remapping = (tot_energy_dAR-tot_energy_dAD)/dtime
    print("Rate of energy change due to vertical remapping               (total: dAR-dAD) "+rate_of_change_vertical_remapping+" W/M^2")

    error = rate_of_change_dynamicsB+rate_of_change_vertical_remapping
    print("Total: horizontal dynamics+vertical remaping+hypervis                          "+error)
    error = rate_of_change_dynamicsB+rate_of_change_vertical_remapping+(rate_of_change_physicsB+rate_of_dry_mass_adjustment)
    print("Consistent with physics estimate?                                              "+error)

    print("  ")

    rate_of_change_dynamics = (tot_energy_dBF-tot_energy_dED)/dtime
    print("Rate of energy change in dynamics everything                  (total: dBF-dED) "+rate_of_change_dynamics+" W/M^2")
    
    error = rate_of_change_dynamicsA+rate_of_change_dynamicsB+rate_of_change_vertical_remapping
    print("Consistency check (should match above): param+dry adj.+horiz dyn.+remap        "+error+" W/M^2")

    print("    ")

    error= rate_of_change_dynamics-rate_of_change_physicsD

    print("  "+error)

    rate_of_change_energy_fixer = (tot_energy_pBP-tot_energy_pBF)/dtime
    print("Rate of energy change in energy fixer (total: pBP-pBF) "+rate_of_change_energy_fixer+" W/M^2")
    
    rate_of_change_dynamics_tendencies = (tot_energy_dBD-tot_energy_dAF)/dtime
    print("Rate of energy change in total tendencies dynamics (total: dAD-dAF) "+rate_of_change_dynamics_tendencies+" W/M^2")



    rate_of_change_horizontal_dynamics = (tot_energy_dAD-tot_energy_dBD)/dtime
    print("Rate of energy change in horizontal dynamics (total: dAD-dBD) "+rate_of_change_horizontal_dynamics+" W/M^2")



;    error = rate_of_change_physics-rate_of_change_dynamics_tendencies
;
    if (ftype.eq.1) then
;       print("For ftype=1 pBF-pAM-(dAD-dAF) should be zero "+error)
    else
;      print("For ftype=0 pBF-pAM-(dAD-dAF) is error due to dribbling tendencies (zero for ftype=1) "+error+" W/M^2")
    end if
    print ("Rate of energy change in heating term (put back in) "+rate_of_change_heating_term_put_back_in+" W/M^2")
    print("xxx"+tot_energy_dBH+"  "+tot_energy_dAH)
    print("Rate of energy change hypervis total "+rate_of_change_hypervis_total+" W/M^2")

    print("  ")
    print("  ")
    print("  ")
    print("newnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnewnew")
    print("  ")
    print("  ")
    print("  ")

    energy_fixer    = (tot_energy_pBP-tot_energy_pBF)/dtime
    phys_dme_adjust = (tot_energy_pAM-tot_energy_pAP)/dtime
    param           = (tot_energy_pAP-tot_energy_pBP)/dtime
    dyn_total       = (tot_energy_dBF-tot_energy_dED)/dtime
    dyn_dme_adjust  = (tot_energy_dBD-tot_energy_dBM)/dtime
    dyn_forcing_no_dme = (tot_energy_dBM-tot_energy_dAF)/dtime    

    dyn_total    = (tot_energy_dBF-tot_energy_dED)/dtime


    print("Dynamics dry mass adj.       (dBD-dBF) "+dyn_dme_adjust+" W/M^2")
    error = dyn_dme_adjust-phys_dme_adjust
    print("Consistent with physics? )             "+error+" W/M^2")
    print(" ")

    print("dE/dt dynamics physics forcing (no dme_adjust) "+dyn_forcing_no_dme+" W/M^2")
    error = (tot_energy_dBM-tot_energy_dAF)/dtime -((tot_energy_pBP-tot_energy_pBF)/dtime+(tot_energy_pAP-tot_energy_pBP)/dtime)
    print("dE/dt dynamics physics forcing - (energy_fixer+parameterizations) "+error+" W/M^2")

;    print("Consistent with physics? )"+error+" W/M^2")


    print("dE/dt dynamics total "+dyn_total+" W/M^2")
    error=dyn_total-param
    print("This should equal dE/dt due to parameterizations "+error)


    error        = energy_fixer+phys_dme_adjust;-param
    print("dE/dt adiabatic dynamics predicted from physics: dE/dt energy fixer+dE/dt dme_adjust "+ error)
    print("xxxxx")
    print("    ")
    print("    ")
    print("    ")
    print("    ")
;===

    rate_of_change_2D_dyn = (tot_energy_dAD-tot_energy_dBD)/dtime
    print("Rate of energy change in horizontal dynamics - incl. hypervis (total: dAD-dBD) "+rate_of_change_2D_dyn+" W/M^2")
    print(" ")
    print("Breakdown of 2D dynamics:")
    print(" ")
    rate_of_change_heating_term_put_back_in = (tot_energy_dAH-tot_energy_dCH)/dtime
    rate_of_change_hypervis_total = (tot_energy_dAH-tot_energy_dBH)/dtime
    print("      Rate of energy change in hypervis                      (total: dAH-dBH) "+rate_of_change_hypervis_total+" W/M^2")
    print("      Rate of energy change from frictional heating rate from momentum        ")
    print("      diffusion which is added to the temperature                             "+rate_of_change_heating_term_put_back_in+" W/M^2")
    error = rate_of_change_2D_dyn-rate_of_change_hypervis_total
    print("      Residual of rate of energy change (time truncation errors)              "+error+" W/M^2")

    print(" ")
    rate_of_change_vertical_remapping = (tot_energy_dAR-tot_energy_dAD)/dtime
    print("Rate of energy change due to vertical remapping               (total: dAR-dAD) "+rate_of_change_vertical_remapping+" W/M^2")

    print(" ")

    print("Summary:")
    print(" ")

    rate_of_change_adiabatic_dyn = rate_of_change_2D_dyn+rate_of_change_vertical_remapping
    print("Adiabatic rate of energy change                (2D dynamics+vertical remaping) "+rate_of_change_adiabatic_dyn+" W/M^2")

    print(" ")

    rate_of_change_forcing_in_dyn = (tot_energy_dBM-tot_energy_dAF)/dtime
    print("Rate of energy change due to physics forcing in dynamics      (total: dBM-dAF) "+rate_of_change_forcing_in_dyn+" W/M^2")

    rate_of_change_dynamics = (tot_energy_dBF-tot_energy_dED)/dtime
    error = rate_of_change_dynamics-(rate_of_change_forcing_in_dyn+rate_of_change_2D_dyn+rate_of_change_vertical_remapping)

    print("Consistency check: total change dynamics - (adiabatic change+forcing change)   "+error+" W/M^2")

    print(" ")

    error = (tot_energy_pAM-tot_energy_pBF)/dtime-rate_of_change_forcing_in_dyn

    print("pAM-pBF-(dAD-dAF) is error due to dribbling tendencies      (zero for ftype=1) "+error+" W/M^2")

    print("  ")
 end do

; do t=0,nt-1 ;nt-1
;    do variable = 2,5
;       print("Variable = "+str_vars(variable)+" at time "+t)
;       error = (int_vars(variable,4,t)-int_vars(variable,0,t))/int_vars(variable,0,t)
;       print("Mass loss in state mapped to physics grid (pBF-dED): "+error)
;       error = (nsplit*int_vars(variable,6,t)-int_vars(variable,2,t))/int_vars(variable,2,t)
;       print("Mass loss in updating state (pBF-dBM): "+error)
;       print("sss "+int_vars(variable,6,t)+" "+int_vars(variable,2,t))
;    end do   
; end do

end


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
  diags_fname = fname+".te_budgets.txt"
  fname =  systemfunc("ls "+fname)
  fall = addfile(fname,"r")       ; Open netCDF files.  
  print("File used for energy diagnostics "+fname)
  print("done input summary")
  print(" ")  
  print("Summary of input to ncl script:")
  print("===============================")
  print(" ")
  if (dycore.eq."SE") then
    print("Your data is for the SE dycore")
    print(" ")
    print("nsplit                   ="+nsplit)
    print("rsplit                   ="+rsplit)
    print("hypervis_subcycle        ="+hypervis_subcycle)
    print("hypervis_subcycle_sponge ="+hypervis_subcycle_sponge)
    print("ftype                    ="+ftype)
    print("qsize_condensate_loading ="+qsize_condensate_loading)
    print("lcp_moist                ="+lcp_moist)
    latlon = False

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

    tmp       = fall->SE_dED(:,:)
    nt        = dimsizes(tmp(:,0))
    print("Number of time-levels = "+nt)
    ncol      = dimsizes(tmp(0,:))
    lat1d_gll     = fall->lat          ; Pull off lat/lon variable and
    lon1d_gll     = fall->lon          ; convert both to 1D.

  end if
  if (dycore.eq."FV") then
    print("Your data is for the FV dycore")  
    latlon = True
    lcp_moist = "false"
    tmp       = fall->SE_pAP(:,:,:)
    nt        = dimsizes(tmp(:,0,0))
    ncol      = -1
  end if
  if (dycore.eq."FV3") then
    print("Your data is for the FV3 dycore")
    print(" ")
    print("nsplit                   ="+nsplit)
    print("rsplit                   ="+rsplit)
    print("hypervis_subcycle        ="+hypervis_subcycle)
    print("ftype                    ="+ftype)
    print("qsize_condensate_loading ="+qsize_condensate_loading)
    print("lcp_moist                ="+lcp_moist)
    latlon = False
    pgx = False

    tmp       = fall->SE_dED(:,:)
    nt        = dimsizes(tmp(:,0))
    ncol      = dimsizes(tmp(0,:))
    lat1d_gll     = fall->lat          ; Pull off lat/lon variable and
    lon1d_gll     = fall->lon          ; convert both to 1D.

  end if


  print("dtime                    ="+dtime)

;
; check
;
  if (lcp_moist.ne."true".and.lcp_moist.ne."false") then
    print("ERROR: lcp_moist should either be true or false; lcp_moist= "+lcp_moist)
    exit()
  end if
  ;
  ; initialization
  ;
  g         = 9.80665D0
  PI        = get_pi("double")
  deg2rad   = PI/180.0
  ncol_p    = 1
  eps       = 1.0D-13
  area_sphere_p = eps
  if (latlon) then
    lat = fall->lat
    lat = deg2rad*lat
    lon = fall->lon
    lon = deg2rad*lon
    nlat=dimsizes(lat)
    nlon=dimsizes(lon)
    area  = new((/nlat,nlon/),typeof(tmp(0,0,0)))    
    dlat  = lat(3)-lat(2)
    dlat2 = 0.5*dlat    
    dlon  = lon(2)-lon(1)
    j=0
    do i=0,nlon-1
      area(j,i) = (sin(lat(j)+dlat2)-sin(lat(j)))*dlon
    end do    
    do j=1,nlat-2
      dsinlat =  (sin(lat(j)+dlat2)-sin(lat(j)-dlat2))      
      do i=0,nlon-1
        area(j,i) = dsinlat*dlon
      end do
    end do
    j=nlat-1
    do i=0,nlon-1
      area(j,i) = (sin(lat(j))-sin(lat(j)-dlat2))*dlon
    end do
    area_sphere = sum(area)
  else
    if (pgx) then
      tmp_p         = fall->SE_pAM(:,:)
      ncol_p        = dimsizes(tmp_p(0,:))
      area_p        = fall->area_fvm(:  )
      area_sphere_p = sum(area_p(0:ncol_p-1))          
      area          = fall->area_d (:  )
      area_sphere = sum(area(0:ncol-1))                
      print("Area of sphere (GLL)         : "+area_sphere)
      error = area_sphere-4.0*PI
      print("Error spanning the sphere    : "+error)
      print("Area of sphere (physgrid)    : "+area_sphere_p)
      error = area_sphere_p-4.0*PI
      print("Error spanning the sphere    : "+error)
      print("ncol_p="+ncol_p)
    else
      area      = fall->area   (:  )
      area_sphere = sum(area(0:ncol-1))          
    end if  
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
  print("              dBS   state before del2 sponge                            |  |  |")
  print("              dAS   state after del2+mom heating sponge                 |  |  |")
  print("          end of vertical Lagrangian dynamics loop -------------------------  |")
  print("      dAD  state after dynamics, before vertical remapping                    |")
  print("      dAR     state after vertical remapping                                  |")
  print("   end of remapping loop ------------------------------------------------------")
  print("dBF  state passed to parameterizations = state after last remapping            ")
  print(" ")
  print(" ")
  print(" ")

;      " end of previous dynamics                           ",& !dED
;      " from previous remapping or state passed to dynamics",& !dAF - state in beginning of nsplit loop
;      " state after applying CAM forcing                   ",& !dBD - state after applyCAMforcing
;      " before vertical remapping                          ",& !dAD - state before vertical remapping
;      " after vertical remapping                           ",& !dAR - state at end of nsplit loop
;      " state passed to parameterizations                  ",& !dBF
;      " state before hypervis                              ",& !dBH
;      " state after hypervis but before adding heating term",& !dCH
;      " state after hypervis                               ",& !dAH
;      " state before sponge layer diffusion                ",& !dBS - state before sponge del2
;      " state after sponge layer diffusion                 ",& !dAS - state after sponge del2
;      " state before two dz filter                         ",& !dBZ
;      " state after two dz filter                          ",& !dAZ
;      " phys2dyn mapping errors (requires ftype-1)         " & !p2d - for asses

  if (wet) then
    qsize = 3
    str_vars      = (/"SE","KE","WV","WL","WI"/);,"TT"/)
    if (isfilevar(fall,"SE_dED")) then
      print("Dycore diagnostics seem to be on file")
      if (dycore.eq."FV3") then
        str_stage     = (/"pBF","pBP","pAP","pAM","dED","dAP","dBD","dAT","dAF","dAD"  ,"dAR" ,"dBF"/)
        subcycle      = (/1.0D0,1.0D0,1.0D0,1.0D0,1.0D0,1.0D0,1.0D0,1.0D0,nsplit,nsplit,nsplit,1.0D0/)
;        subcycle      = (/1D0  ,1D0  ,1D0  ,1D0  ,1.0D0,1.0D0,1.0D0,1D0,1D0,1D0,1D0/)	;averaging is not being done by CAM history
      else
        str_stage     = (/"pBF","pBP","pAP","pAM","dED","dAF","dBD"  ,"dAD" ,"dAR" ,"dBF","dBH","dCH","dAH","dBS","dAS"/);,"dX1","dX2","dX3"/);,"dBZ","dAZ"/)
        subcycle    =     (/1D0,1D0  ,1D0  ,1D0  ,1.0D0,nsplit,nsplit,nsplit,nsplit,1.0D0,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit,nsplit*rsplit/);,nsplit*rsplit,nsplit*rsplit,nsplit*rsplit/);
      end if	
      dycoreDiags = True
    else
      dycoreDiags = False    
      print("No dycore diagnostics seem to be on file")
      str_stage     = (/"pBF","pBP","pAP","pAM"/)
      subcycle    = (/1D0,1D0,1D0,1D0/)          
    end if
  else
    ;
    ; dycore only diags
    ;
    qsize = 0
    str_vars      = (/"SE","KE"/)
    str_stage     = (/"dED","dAF","dBD","dAD","dAR","dBF","dBH","dCH","dAH"/)
    subcycle    = (/1.0D0,nsplit,nsplit,nsplit,nsplit,1.0D0,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle/)    
    dycoreDiags = True
  end if

  nvars       = dimsizes(str_vars)
  nstage      = dimsizes(str_stage)
  if (latlon) then
    vars        = new((/nvars,nstage,nt,nlat,nlon/),typeof(tmp(0,0,0)))
    tot_energy  = new((/nstage/),typeof(tmp(0,0,0)))
    tracer_mass = new((/nt,3,nstage/),typeof(tmp(0,0,0)))
    int_vars  = new((/nvars,nstage,nt/)     ,typeof(tmp(0,0,0)))        
  else
    vars        = new((/nvars,nstage,nt,ncol/),typeof(tmp(0,0)))
;    vars        = new((/ncol/),typeof(tmp(0,0)))
    vars_p      = new((/ncol_p/),typeof(tmp(0,0)))
    tot_energy  = new((/nt,nstage/),typeof(tmp(0,0)))
    tot_energy_t  = new((/nt,nstage/),typeof(tmp(0,0)))
    tot_energy_2d = new((/nt,nstage,ncol/),typeof(tmp(0,0)))

    tracer_mass = new((/nt,3,nstage/),typeof(tmp(0,0)))
    int_vars    = new((/nvars,nstage,nt/)     ,typeof(tmp(0,0)))    
  end if

  int_vars  = 0.0D0
  ;
  ; check that variables are on file and read them and compute global integrals
  ;
  inv_area_sphere   = 1.0D0/area_sphere
  inv_area_sphere_p = 1.0D0/area_sphere_p
  print("nvars="+nvars)
  do variable=0,nvars-1
    do stage=0,nstage-1
      str = str_vars(variable)+"_"+str_stage(stage)
      print("xxx "+str)
      if (isfilevar(fall,str)) then
        if (latlon) then
          vars(variable,stage,:,:,:) = fall->$str$(:,:,:)
          do t=0,nt-1
            int_vars(variable,stage,t) = sum(area(:,:)*vars(variable,stage,t,:,:))*inv_area_sphere		  
	  end do
	else
          fld = fall->$str$(:,:)
;xxx          vars(variable,stage,:,:) = fall->$str$(:,:)	  
	  if (dimsizes(fld(0,:)).eq.ncol_p) then
            do t=0,nt-1	      
              int_vars(variable,stage,t) = sum(area_p(0:ncol_p-1)*fld(t,0:ncol_p-1))*inv_area_sphere_p
	    end do
          else
            do t=0,nt-1	      	  
              int_vars(variable,stage,t) = sum(area(0:ncol-1)*fld(t,0:ncol-1))*inv_area_sphere
	    end do
	  end if
	  delete(fld)
   	end if
	
      else
        print("Variable "+str+" not found")
        exit
      end if
    end do
  end do
  print("Done integrals")
  ;
  ; compute global integrals
  ;

;  do t=0,nt-1
;    do variable = 0,nvars-1
;      do stages=0,nstage-1
;        if (latlon) then
;          int_vars(variable,stages,t) = sum(area(:,:)*vars(variable,stages,t,:,:))*inv_area_sphere	
;	else
;          int_vars(variable,stages,t) = sum(area(0:ncol-1)*vars(variable,stages,t,0:ncol-1))*inv_area_sphere	
;	end if
;      end do
;    end do
;  end do

  ;
  ; For code clarity define indices corresponding to the different stages
  ;
  if (isfilevar(fall,"SE_pBF")) then
    ipBF = str_match_ind(str_stage,"pBF")
  else
    iPBF = -1
  end if
  if (isfilevar(fall,"SE_pBP")) then
    ipBP = str_match_ind(str_stage,"pBP")
  else
    iPBP = -1
  end if
  if (isfilevar(fall,"SE_pAP")) then
    ipAP = str_match_ind(str_stage,"pAP")
  else
    iPAP = -1
  end if
  if (isfilevar(fall,"SE_pAM")) then
    ipAM = str_match_ind(str_stage,"pAM")
  else
    iPAM = -1
  end if
  if (isfilevar(fall,"SE_dED")) then
    idED = str_match_ind(str_stage,"dED")
  else
    idED = -1
  end if
  if (isfilevar(fall,"SE_dBD")) then
    idBD = str_match_ind(str_stage,"dBD")
  else
    idBD = -1
  end if
  if (isfilevar(fall,"SE_dAF")) then
    idAF = str_match_ind(str_stage,"dAF")
  else
    idAF = -1
  end if
  if (isfilevar(fall,"SE_dAD")) then
    idAD = str_match_ind(str_stage,"dAD")
  else
    idAD = -1
  end if
  if (isfilevar(fall,"SE_dAR")) then
    idAR = str_match_ind(str_stage,"dAR")
  else
    idAR = -1
  end if
  if (isfilevar(fall,"SE_dBF")) then
    idBF = str_match_ind(str_stage,"dBF")
  else
    idBF = -1
  end if
  if (isfilevar(fall,"SE_dBH")) then
    idBH = str_match_ind(str_stage,"dBH")
  else
    idBH = -1
  end if
  if (isfilevar(fall,"SE_dCH")) then
    idCH = str_match_ind(str_stage,"dCH")
  else
    idCH = -1
  end if                  
  if (isfilevar(fall,"SE_dAH")) then
    idAH = str_match_ind(str_stage,"dAH")
  else
    idAH = -1
  end if
  if (isfilevar(fall,"SE_dAP")) then
    idAP = str_match_ind(str_stage,"dAP")
  else
    idAP = -1
  end if

  if (isfilevar(fall,"SE_dAT")) then
    idAT = str_match_ind(str_stage,"dAT")
  else
    idAT = -1
  end if                      


  if (isfilevar(fall,"SE_dBS")) then
    idBS = str_match_ind(str_stage,"dBS")
  else
    idBS = -1
  end if                      
  if (isfilevar(fall,"SE_dAS")) then
    idAS = str_match_ind(str_stage,"dAS")
  else
    idAS = -1
  end if                      
  if (isfilevar(fall,"SE_dBZ")) then
    idBZ = str_match_ind(str_stage,"dBZ")
  else
    idBZ = -1
  end if                      
  if (isfilevar(fall,"SE_dAZ")) then
    idAZ = str_match_ind(str_stage,"dAZ")
  else
    idAZ = -1
  end if                      
  if (isfilevar(fall,"SE_dX1")) then
    idX1 = str_match_ind(str_stage,"dX1")
  else
    idX1 = -1
  end if                      
  if (isfilevar(fall,"SE_dX2")) then
    idX2 = str_match_ind(str_stage,"dX2")
  else
    idX2 = -1
  end if                      
  if (isfilevar(fall,"SE_dX3")) then
    idX3 = str_match_ind(str_stage,"dX3")
  else
    idX3 = -1
  end if                      


  if (ismissing(ipBF).or.ismissing(ipBF).or.ismissing(ipAM).or.ismissing(ipAP)) then
    PhysDiags = False
    print("Physics diagnostics are not all on file")
  else
    PhysDiags = True
    print("Physics diagnostics are on file")
  end if

  do t=0,nt-1
    do j=0,nstage-1
      tot_energy(t,j)     = subcycle(j)*(int_vars(0,j,t)+int_vars(1,j,t))
;    tot_energy(t,j)  = subcycle(j)*int_vars(0,j,t) ; thermal energy only
;     tot_energy(t,j)  = subcycle(j)*int_vars(1,j,t); K energy only	       
;      print("t="+t": "+str_stage(j)+"   "+tot_energy(t,j))

      tot_energy_2d(t,j,:) = subcycle(j)*(vars(0,j,t,0:ncol-1)); themal energy only
;     tot_energy_2d(t,j,:) = subcycle(j)*(vars(0,j,t,0:ncol-1)+vars(1,j,t,0:ncol-1))
      if (wet) then
        idx = str_match_ind(str_vars,"WV")
        tracer_mass(t,0,j) = subcycle(j)*(int_vars(idx,j,t))
        idx = str_match_ind(str_vars,"WL")
        tracer_mass(t,1,j) = subcycle(j)*(int_vars(idx,j,t))
		print("iii "+j+" "+tracer_mass(t,2,j)+" "+int_vars(idx,j,t))		
        idx = str_match_ind(str_vars,"WI")
        tracer_mass(t,2,j) = subcycle(j)*(int_vars(idx,j,t))
	print("qqq "+str_stage(j)+" "+tracer_mass(t,2,j)+" "+int_vars(idx,j,t))
      end if
    end do
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




  do t=0,nt-1
    if (PhysDiags) then
      pEFIX    = (tot_energy(t,ipBP)-tot_energy(t,ipBF))/dtime
      pDMEA = (tot_energy(t,ipAM)-tot_energy(t,ipAP))/dtime
      pwork = (tot_energy_2d(t,ipAM,:)-tot_energy_2d(t,ipAP,:))/dtime

      param   = (tot_energy(t,ipAP)-tot_energy(t,ipBP))/dtime
      dparam = (tot_energy_2d(t,ipAP,:)-tot_energy_2d(t,ipBP,:))/dtime  

      phys_total      = (tot_energy(t,ipAM)-tot_energy(t,ipBF))/dtime
    end if

    if (dycoreDiags) then
      dyn_total       = (tot_energy(t,idBF)-tot_energy(t,idED))/dtime
      dyn_phys_total       = (tot_energy(t,idAD)-tot_energy(t,idAF))/dtime
    end if
   

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
    end if
    if (dycore.eq."FV".or.dycore.eq."FV3") then
      print(" ")    
      fv_dycore = -pEFIX-pDMEA
      print("Dycore TE dissipation estimated from physics TE terms (assuming ftype=1 and no energy discretization errors is")
      print(sprintf("%6.3g",fv_dycore)     +" W/M^2")
      print(" ")      
    end if

    if (dycore.eq."FV3") then
      print(" ")
      print("=================================================================================")
      print("|                                                                               |")
      print("| ANALYSIS OF ENERGY DIAGNOSTICS IN DYNAMICS - specific for FV3 dycore          |")
      print("|                                                                               |")
      print("=================================================================================")
      print(" ")
      diff1 = (tot_energy(t,ipAM)-tot_energy(t,ipBF))/dtime
      diff2 = (tot_energy(t,idAP)-tot_energy(t,idED))/dtime
      
      diff  = diff2-diff1
      
      param_dyn= (tot_energy(t,idAP)-tot_energy(t,idED))/dtime	
      print("dE/dt parameterizations (param) in dyn on A-grid (dAP-dED) "+sprintf("%6.3g",param_dyn)     +" W/M^2")
      param_dyn_D= (tot_energy(t,idBD)-tot_energy(t,idED))/dtime	
      print("dE/dt parameterizations (param) in dyn on D-grid (dBD-dED) "+sprintf("%6.3g",param_dyn_D)     +" W/M^2")
      param_dyn_DA = (tot_energy(t,idBD)-tot_energy(t,idAP))/dtime
      print("dE/dt mapping wind tendencies from A to D grid (and back to A-grid for TE computations (dBD-dAP) "+sprintf("%6.3g",param_dyn_DA)     +" W/M^2")


      print(" Physics-dynamics coupling error (should be zero) : "+diff)
      print(" (dE/dt physics increment minus dE/dt physics increment in dynamics)")
      print(" ")


      dDycore = (tot_energy(t,idBF)-tot_energy(t,idBD))/dtime      
      dadiab  = (tot_energy_2d(t,idBF,:)-tot_energy_2d(t,idBD,:))/dtime      

      print(" dE/dt dynamical core total (dBF-dBD) = "+dDycore)
      print(" ")
      print(" Breakdown of dycore dE/dt:")
      print(" ")      

      Rayleigh = (tot_energy(t,idAT)-tot_energy(t,idBD))/dtime      
      print(" dE/dt Rayleigh friction (dAT-dBD) = "+Rayleigh)


      dDycore2d = (tot_energy(t,idAD)-tot_energy(t,idAF))/dtime
      print(" dE/dt 2D dynamical core (dAD-dAF) = "+dDycore2d)      

      dRemap = (tot_energy(t,idAR)-tot_energy(t,idAD))/dtime
      remap  = (tot_energy_2d(t,idAR,:)-tot_energy_2d(t,idAD,:))/dtime
      print(" dE/dt vertical remapping(dAR-dAD) = "+dRemap)      
      print(" ")
      diff = dDycore-(dDycore2d+dRemap+Rayleigh)
      print("Check that dE/dt 2D dynamics + vertical remapping + Rayleigh friction - dE/dt dynamical core total (should be zero)="+diff)

      hvis = remap
      hvis = 0.0

      fheat = remap
      fheat = 0.0
      
    end if

    if (dycore.eq."SE".and.dycoreDiags) then
      print(" ")
      print("=================================================================================")
      print("|                                                                               |")
      print("| ANALYSIS OF ENERGY DIAGNOSTICS IN DYNAMICS - specific for SE dycore           |")
      print("|                                                                               |")
      print("=================================================================================")
      print(" ")


      rate_of_change_2D_dyn = (tot_energy(t,idAD)-tot_energy(t,idBD))/dtime

      rate_of_change_vertical_remapping = (tot_energy(t,idAR)-tot_energy(t,idAD))/dtime

      remap = (tot_energy_2d(t,idAR,:)-tot_energy_2d(t,idAD,:))/dtime

      dADIA = rate_of_change_2D_dyn+rate_of_change_vertical_remapping

      dadiab = (tot_energy_2d(t,idAR,:)-tot_energy_2d(t,idBD,:))/dtime


;      x1       = (tot_energy(t,idX2)-tot_energy(t,idX1))/dtime
;      x2       = (tot_energy(t,idX3)-tot_energy(t,idX2))/dtime
;      print("dE/dt x1 "+sprintf("%6.3g",x1)+" W/M^2")
;      print("dE/dt x2 "+sprintf("%6.3g",x2)+" W/M^2")


      diffusion_del4       = (tot_energy(t,idCH)-tot_energy(t,idBH))/dtime
      diffusion_fric       = (tot_energy(t,idAH)-tot_energy(t,idCH))/dtime
      diffusion_del4_tot   = (tot_energy(t,idAH)-tot_energy(t,idBH))/dtime
      diffusion_sponge     = (tot_energy(t,idAS)-tot_energy(t,idBS))/dtime
      diffusion_total      = diffusion_del4_tot+diffusion_sponge

      print("dE/dt dyn total (dycore+phys tendency   (dBF-dED) "+sprintf("%6.3g",dyn_total)+" W/M^2")

      print("dE/dt total adiabatic dynamics (adiab)            "+sprintf("%6.3g",dADIA)+" W/M^2")    
      print("dE/dt 2D dynamics (2D)                  (dAD-dBD) "+sprintf("%6.3g",rate_of_change_2D_dyn)+" W/M^2")
      print("dE/dt vertical remapping (remap)        (dAR-dAD) "+sprintf("%6.3g",rate_of_change_vertical_remapping)+" W/M^2")
      rate_of_change_physics = (tot_energy(t,idBD)-tot_energy(t,idAF))/dtime
      print("dE/dt physics tendency in dynamics      (dBD-dAF) "+sprintf("%6.3g",rate_of_change_physics)+" W/M^2")
      print(" ")
      print("Breakdown of 2D dynamics:")
      print(" ")
      rate_of_change_heating_term_put_back_in = (tot_energy(t,idAH)-tot_energy(t,idCH))/dtime
      fheat = (tot_energy_2d(t,idAH,:)-tot_energy_2d(t,idCH,:))/dtime

      hvis = (tot_energy_2d(t,idAH,:)-tot_energy_2d(t,idBH,:))/dtime
      rate_of_change_hvis_sponge = (tot_energy(t,idAS)-tot_energy(t,idBS))/dtime

      print("      dE/dt hypervis del4 (hvis)             (dCH-dBH) "+sprintf("%6.3g",diffusion_del4)+" W/M^2")
      print("      dE/dt hypervis frictional heating del4 (dAH-dCH) "+sprintf("%6.3g",diffusion_fric)+" W/M^2")
      print("      dE/dt hypervis del4 total (hvis)       (dAH-dBH) "+sprintf("%6.3g",diffusion_del4_tot)+" W/M^2")
      print("      dE/dt hypervis sponge total            (dAS-dBS) "+sprintf("%6.3g",diffusion_sponge)+" W/M^2")
      print("                                                       ")
      print("      dE/dt explicit diffusion total                   "+sprintf("%6.3g",diffusion_total)+" W/M^2")


;      consistency = diffusion_del4_tot-(diffusion_del4+diffusion_fric)
;      print("      dE/dt hypervis consistency (dAH-dBH)=(dCH-dBH)+(dAH-dCH)="+sprintf("%6.3g",consistency)+" W/M^2")



      twoDresidual = rate_of_change_2D_dyn-diffusion_total
      print("      dE/dt residual (res)                        "+sprintf("%6.3g",twoDresidual)+" W/M^2")
    end if
    print(" ")
    print(" ")

    if (dycore.eq."SE".and.PhysDiags.and.dycoreDiags) then
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
	print(phys_total+"  "+rate_of_change_physics)
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


      qneg  = (tot_energy(t,ipBF)-tot_energy(t,idED))/dtime
      print(" ")
      print(" qneg: "+qneg)
      print(" ")

      ;
      ; write diagnostics to file
      ;
      str1 = qsize_condensate_loading+"                       &"
      str1 = str1 + " "+lcp_moist+"   &"      
      str1 = str1 + " "+ftype+"   &"      
      str1 = str1 + " "+sprintf("%6.3g",param)+"&"
      str1 = str1 + " "+sprintf("%6.3g",pDMEA)+"&"
      str1 = str1 + " "+sprintf("%6.3g",pEFIX)+"&"
      str1 = str1 + " "+discr+"&"
      str1 = str1 + " "+sprintf("%6.3g",rate_of_change_2D_dyn)+"&"
      str1 = str1 + " "+sprintf("%6.3g",diffusion_total)+"&"
      str1 = str1 + " "+sprintf("%6.3g",rate_of_change_heating_term_put_back_in)+"&"
 ;      str1 = str1 + " "+sprintf("%6.3g",twoDresidual)+"&"
      str1 = str1 + " "+sprintf("%6.3g",twoDresidual)+"&"
      str1 = str1 + " "+sprintf("%6.3g",rate_of_change_vertical_remapping)+"&"
      str1 = str1 + " "+sprintf("%6.3g",dADIA)+"&"
       str1 = str1 + " "+sprintf("%6.3g",value_pdc)
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
      pEFIX    = (tracer_mass(t,m_cnst,ipBP)-tracer_mass(t,m_cnst,ipBF))
      pDMEA = (tracer_mass(t,m_cnst,ipAM)-tracer_mass(t,m_cnst,ipAP))
      param           = (tracer_mass(t,m_cnst,ipAP)-tracer_mass(t,m_cnst,ipBP))
      dyn_total       = (tracer_mass(t,m_cnst,idBF)-tracer_mass(t,m_cnst,idED))
      phys_total      = (tracer_mass(t,m_cnst,ipAM)-tracer_mass(t,m_cnst,ipBF))

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

      if (idAD.ge.0.and.idBD.ge.0.and.idAR.ge.0.and.idCH.ge.0) then
        mass_change__2D_dyn = (tracer_mass(t,m_cnst,idAD)-tracer_mass(t,m_cnst,idBD))
        mass_change__vertical_remapping = (tracer_mass(t,m_cnst,idAR)-tracer_mass(t,m_cnst,idAD))
        dADIA = mass_change__2D_dyn+mass_change__vertical_remapping
        print("dE/dt total adiabatic dynamics                    "+sprintf("%6.3g",dADIA)+" Pa")
        print("dE/dt 2D dynamics                       (dAD-dBD) "+sprintf("%6.3g",mass_change__2D_dyn)+" Pa")
        print(" ")
        print("Breakdown of 2D dynamics:")
        print(" ")
        mass_change__heating_term_put_back_in = (tracer_mass(t,m_cnst,idAH)-tracer_mass(t,m_cnst,idCH))
        mass_change__hypervis_total           = (tracer_mass(t,m_cnst,idAH)-tracer_mass(t,m_cnst,idBH))
        print("      dE/dt hypervis                    (dAH-dBH) "+sprintf("%6.3g",mass_change__hypervis_total)+" Pa")
        print("      dE/dt frictional heating          (dAH-dCH) "+sprintf("%6.3g",mass_change__heating_term_put_back_in)+" Pa")
        error = mass_change__2D_dyn-mass_change__hypervis_total
        print("      dE/dt residual (time truncation errors)     "+sprintf("%6.3g",error)+" Pa")	
      end if
      if (idAR.ge.0.and.idAD.ge.0) then
        mass_change__vertical_remapping = (tracer_mass(t,m_cnst,idAR)-tracer_mass(t,m_cnst,idAD))
        print("dE/dt vertical remapping                (dAR-dAD) "+sprintf("%6.3g",mass_change__vertical_remapping)+" Pa")
      end if
      print(" ")
      print(" ")

      if (idBD.ge.0.and.idAF.ge.0) then
        mass_change__physics = (tracer_mass(t,m_cnst,idBD)-tracer_mass(t,m_cnst,idAF))
        print("dE/dt physics tendency in dynamics      (dBD-dAF) "+sprintf("%6.3g",mass_change__physics)+" Pa")
        value = phys_total-mass_change__physics
      end if
      if (idBD.ge.0.and.idAF.ge.0) then
        if (ftype .eq. "1") then
          print(" ")
          print("      Consistency check:")
          print(" ")
          print("      dE/dt physics tendency in dynamics (dBD-dAF) should exactly match dE/dt physics total (pAM-pBF):"+sprintf("%6.3g",value))
          print(" ")
        else
          print("Dribbling errors (pAM-pBF-(dBD-dAF))"+sprintf("%6.3g",value))
        end if
      end if

 
      if (dycore.eq."FV3") then
        print("Checking physics dynamics coupling")
        mass_change_phys = (tracer_mass(t,m_cnst,ipAM)-tracer_mass(t,m_cnst,ipBF))
        print("Mass change in physics:               "+mass_change_phys)
        mass_change_p_d_coupling  = (tracer_mass(t,m_cnst,idBD)-tracer_mass(t,m_cnst,idED))
        print("Mass change in d_p_coupling: "+mass_change_p_d_coupling)
	error = mass_change_p_d_coupling-mass_change_phys
	print("Error  "+error)
        mass_change_dyn  = (tracer_mass(t,m_cnst,idBF)-tracer_mass(t,m_cnst,idED))
        print("Mass change in dynamics from physics: "+mass_change_dyn)

        mass_error_in_coupling = (tracer_mass(t,m_cnst,ipAM)-tracer_mass(t,m_cnst,idBF))
        print("Mass error in coulpling "+mass_error_in_coupling)
       end if
       print(" ")
       print("---------------------------------------------------------------------------------------------------")
       print(" ")
     end do
  ;
  ;----------------------------------------------------------------------------------------------------------------
  ;
  ; plotting stuff
  ;
  ;----------------------------------------------------------------------------------------------------------------
  ;
  output_format = "pdf"
  wks = gsn_open_wks(output_format,"te")
  gsn_define_colormap(wks,"NCV_jaisnd");3gauss")      
; gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   ; choose colormap
; gsn_define_colormap(wks,"GMT_polar")
    



  res                     = True         ; plot modifications desired
  res@gsnMaximize         = False         ; Maximize size of plot in frame
  res@gsnSpreadColors     = True         ; Use full colormap, but start
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnFillOn            = True         ; Turn on contour fill
;  res@cnFillMode          = "AreaFill"   ; Style of fill. You can also
                                         ; use "CellFill" and "RasterFill"
  res@cnLinesOn           = False        ; Turn off contour lines
  res@cnLineLabelsOn      = False        ; Turn off contour line labels
  res@lbLabelAutoStride   = True         ; Clean up labelbar labels.
  res@cnFillMode="RasterFill"


;  res@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resources
;  res@cnMinLevelValF  = -30.0                        ; set the minimum contour level
;  res@cnMaxLevelValF  = 30.0                   ; set the maximum contour level
;  res@cnLevelSpacingF = 1.0                  ; set the interval between contours

;  res@mpMinLatF = -30.                   ; set the minimum latitude = -70.
;  res@mpMaxLatF = 30.                    ; set the maximum latitude = 70.

; res@mpMinLonF = -40.                    ; set the minimum latitude = -70.
;  res@mpMaxLonF = 40.

  res@gsnStringFontHeightF = 0.02
  res@tiMainFontHeightF = 0.025
  res@lbLabelFontHeightF = 0.02
  res@tmXBLabelFontHeightF = 0.015
  res@tmYLLabelFontHeightF = 0.015
  res@pmLabelBarOrthogonalPosF = 0.2

  res@lbBoxLinesOn = False

  plot = new(6,graphic) 

  res@sfXArray            = lon1d_gll
  res@sfYArray            = lat1d_gll

  res@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resources
  fmin = -150.
      fmax = 150.
  res@cnMinLevelValF  = fmin                        ; set the minimum contour level
  res@cnMaxLevelValF  = fmax                   ; set the maximum contour level
  res@cnLevelSpacingF = (fmax-fmin)/50.0                  ; set the interval between contours
  res@gsnLeftString        = "Total physics TE tendency"      

;  res@tiMainString        = " [W/m^2]"
      ;-148.2925226269828   max=1770.210548306306


  min_f = min(dparam)
  max_f = max(dparam)
  res@lbTitleString    = "global min = "+sprintf("%6.4g",min_f)+"  global  max="+sprintf("%6.4g",max_f)
  plot(0) = gsn_csm_contour_map_ce(wks,dparam,res)

  res@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  =-20.                        ; set the minimum contour level
  res@cnMaxLevelValF  = 20.                   ; set the maximum contour level
  res@cnLevelSpacingF = 0.50                  ; set the interval between contours
  res@gsnRightString       = "W/m~S~2~N"
  res@gsnLeftString        = "Pressure work error TE tendency (pwork)"
;  res@tiMainString        = "Pressure work error (pwork) [W/m^2]"


  min_f = min(pwork)
  max_f = max(pwork)
  res@lbTitleString    = "global min = "+sprintf("%6.4g",min_f)+"  global  max="+sprintf("%6.4g",max_f)
  plot(1) = gsn_csm_contour_map_ce(wks,pwork,res)

  res@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resources
  fmin   = -150.
      fmax = 150.
  res@cnMinLevelValF  = fmin                        ; set the minimum contour level
  res@cnMaxLevelValF  = fmax                   ; set the maximum contour level
  res@cnLevelSpacingF = (fmax-fmin)/50.0                  ; set the interval between contours

  res@gsnLeftString        = "Adiabatic dycore TE tendency (adiab)"      
  min_f = min((tot_energy_2d(t,idAR,:)-tot_energy_2d(t,idBD,:))/dtime)
  max_f = max((tot_energy_2d(t,idAR,:)-tot_energy_2d(t,idBD,:))/dtime)

  res@lbTitleString    = "global min = "+sprintf("%6.4g",min_f)+"  global  max="+sprintf("%6.4g",max_f)
  plot(2) = gsn_csm_contour_map_ce(wks,dadiab,res)
      printMinMax((tot_energy_2d(t,idAR,:)-tot_energy_2d(t,idBD,:))/dtime,False)
      ;min=-1489.836497456233   max=122.200959737036


  res@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -600.0                        ; set the minimum contour level
  res@cnMaxLevelValF  = 600.0                  ; set the maximum contour level
  res@cnLevelSpacingF = 10.0                  ; set the interval between contours
  res@gsnLeftString        = "Hyperviscosity TE tendency (hvis)"        



  min_f = min(hvis)
  max_f = max(hvis)
  res@lbTitleString    = "global min = "+sprintf("%6.4g",min_f)+"  global  max="+sprintf("%6.4g",max_f)

  plot(3) = gsn_csm_contour_map_ce(wks,hvis,res)	

;      average_hvis = sum(area(:)*(tot_energy_2d(t,idAH,:)-tot_energy_2d(t,idBH,:))/dtime)/(4.0*PI)
;      print("ave_hvis = "+average_hvis)
  res@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resources
 if (dycore.eq."SE") then
  res@cnMinLevelValF  = -0.1                        ; set the minimum contour level
  res@cnMaxLevelValF  = 0.1                   ; set the maximum contour level
  res@cnLevelSpacingF = 0.005                  ; set the interval between contours 
else
  res@cnMinLevelValF  = -10.0                        ; set the minimum contour level
  res@cnMaxLevelValF  = 10.0                   ; set the maximum contour level
  res@cnLevelSpacingF = 0.5                  ; set the interval between contours 
end if
  res@gsnLeftString        = "Vertical remapping TE tendency (remap)"      

  min_f = min(remap)
  max_f = max(remap)
  res@lbTitleString    = "global min = "+sprintf("%6.4g",min_f)+"  global  max="+sprintf("%6.4g",max_f)

  plot(4) = gsn_csm_contour_map_ce(wks,remap,res)


  res@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resources
  res@cnMinLevelValF  = -10.0                        ; set the minimum contour level
  res@cnMaxLevelValF  = 10.0                   ; set the maximum contour level
  res@cnLevelSpacingF = 0.5                  ; set the interval between contours
  res@gsnLeftString        = "Frictional heating TE tendency (fheat)"  

  min_f = min(fheat)
  max_f = max(fheat)
  res@lbTitleString    = "global min = "+sprintf("%6.4g",min_f)+"  global  max="+sprintf("%6.4g",max_f)

  plot(5) = gsn_csm_contour_map_ce(wks,fheat,res)
 

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  resP@gsnPanelFigureStrings = (/"a","b","c","d","e","f"/)
  resP@gsnPanelYWhiteSpacePercent = 4.0
  resP@gsnPanelXWhiteSpacePercent = 4.0

;  resP@gsnPanelLabelBar = True                   ; add common colorbar
;  resP@gsnPanelBottom   = 0.05
  if (dycore.eq."FV3") then    
     resP@txString   = "TE tendencies for the default CAM-FV3 configuration (AMIP)"
  end if
  if (dycore.eq."SE") then    
     resP@txString   = "TE tendencies for the default CAM-SE configuration (AMIP)"
  end if

     gsn_panel(wks,plot,(/3,2/),resP)               ; now draw as one plot



   txres               = True
;  txres@txFontHeightF = 0.015
;  gsn_text_ndc(wks,"Figure 1: A nifty panel plot",0.5,0.02,txres)
   frame(wks)

  end do
  if (dycore.eq."FV3") then    
    print("**************************************************")
    print("d_p_coupling check (requires instantaneous output)")
    print("**************************************************")
    print(" ")
    print("Check if state passed to physics (pBF) is the same at the state at the end of the dycore (dBF)")
    print("Note: if not working with instantaneous data there will be a sampling error!")
    print("Sampling error will be very small if working with long averages ...")
    print(" ")
    do t=0,nt-2
      yyy = (tot_energy(t,idBF)-tot_energy(t+1,ipBF))/dtime ;tot_energy(t,idBF) xxxx
      print("t="+t+": normalized difference between states (should be zero) = "+yyy)      
    end do
 
    print(" ")
    print("**************************************************")
    print("p_d_coupling check 1")
    print("**************************************************")
    print(" ")
    print("Check if state at the end of physics (pAM) is the same at the state at the beginning of the dycore (dAP)")
    print("before any tendencies have been added to the dynamics state")
    print(" ")
    do t=0,nt-1
      print("t="+t+" "+ipAM+" "+idAP)
      diff1 = (tot_energy(t,ipAM)-tot_energy(t,idAP))/dtime ;tot_energy(t,ipAM) xxx
      print("t="+t+": normalized difference between states (should be zero) = "+diff1)
    end do
    print(" ")
    print("**************************************************")
    print("p_d_coupling check 2")
    print("**************************************************")
    print(" ")
    print("Check if physics increment in physics is the same as in dynamics")
    print(" ")     
    do t=0,nt-1   
      diff1 = (tot_energy(t,ipAM)-tot_energy(t,ipBF))/dtime
      diff2 = (tot_energy(t,idAP)-tot_energy(t,idED))/dtime
      print("Physics increment is             "+diff1)
      print("Physics increment in dynamics is "+diff2)
      diff=diff2-diff1
      print("Difference is (should be zero)  ="+diff)
      print(" ")
    end do
    print(" ")
    print("**************************************************")
    print("Budget check: pEFIX = dDycore+pDMEA")
    print("**************************************************")
    print(" ")
    print("Note: if not working with instantaneous data there will be a sampling error!")
    print("Sampling error will be very small if working with long averages ...")
    print(" ")     
    do t=1,nt-1
      pEFIX   = (tot_energy(t,ipBP)-tot_energy(t,ipBF))/dtime
      pDMEA   = (tot_energy(t-1,ipAM)-tot_energy(t-1,ipAP))/dtime
      dDycore = (tot_energy(t-1,idBF)-tot_energy(t-1,idAP))/dtime
      print("dE/dt dycore (from previous time-step) ="+dDycore)
      print("dE/dt pDMEA  (from previous time-step) ="+pDMEA)
      print("dE/dt energy fixer                     ="+pEFIX)
      print(" ")
      print("Budget equation: -pEFIX(t)=dDycore(t-1)+pDMEA(t-1)")
      print(" ")
      diff = pEFIX+dDycore+pDMEA
      print("t="+t+": Is budget equation fullfilled? "+diff)
      print(" ")       
    end do
    print(" ")
    print("**************************************************")
    print("QNEG mass change")
    print("**************************************************")
    print(" ")
    do t=1,nt-1
      do m_cnst=0,2
        print("m_cnst "+m_cnst)
        mass_change_qneg = (tracer_mass(t,m_cnst,ipBF)-tracer_mass(t-1,m_cnst,idBF))
	print("xxx "+tracer_mass(t,m_cnst,ipBF)+" "+tracer_mass(t-1,m_cnst,idBF))
        print("QNEG mass change "+mass_change_qneg)
      end do
    end do
  end if
end


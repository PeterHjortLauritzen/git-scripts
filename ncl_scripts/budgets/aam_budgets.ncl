load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

undef("check_subc")
procedure check_subc(subc1,subc2)
begin
  print("Comparing "+subc1+" "+subc2)
  if(subc1.eq.subc2) then
     print("Subcycle PASS: "+subc1+" "+subc2)
  else
     print("FAIL") 
     exit()
  end if
end

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

  tempo_false = True
  if (tempo.eq."a") then
    fnames =  (/fname/) ;systemfunc("ls "+fname)
    print("File used for axial angular momentum diagnostics "+fnames)
    fall = addfiles(fnames,"r")       ; Open netCDF files.	
    tempo_false = False
  end if
  if (tempo.eq."i") then
    fnames =  systemfunc("ls "+fname+"*.nc")
    print("Files used for axial angular momentum diagnostics "+fnames)
    fall = addfiles(fnames,"r")       ; Open netCDF files.	
    tempo_false = False
  end if 
  if (tempo_false) then
    print("Not a valid value for tempo "+tempo)
    print("Valid options are i and a")
    exit()
  end if
  print("tempo ="+tempo)
  print("done input summary")
  print(" ")
  ;
  ; initialization
  ;
  g         = 9.80665D0
  nc        = -1
  eps       = 1.0D-13

  if (dycore.eq."FV3") then
    area      = fall[0]->area_d(:)  
  else
    area      = fall[0]->area(:)
  end if  
  time      = fall[:]->time
  nt        = dimsizes(time)
  tmp       = fall[0]->MO_dED(:,:)
  ncol      = dimsizes(tmp(0,:))

  wet = True
  lprint = True


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
  if (dycore.eq."SE") then    
    print("dED: state from end of previous dynamics (= pBF + time sampling)")
    print("   loop over vertical remapping------------------------------- (nsplit) -------")
    print("                                                                              |")
    print("          loop over vertical Lagrangian dynamics --------rsplit-------------  |")
    print("              dAF: state before physics dribble and previous remapping        |")
    print("              dBD: state after physics dribble, before dynamics               |")
    print("              dynamics here                                                |  |")
    print("              loop over hyperviscosity ----------hypervis_sub------------  |  |")
    print("                 dBH   state before hyperviscosity                      |  |  |")
    print("                 dCH   state after hyperviscosity                       |  |  |")
    print("                 dAH   state after hyperviscosity momentum heating      |  |  |")
    print("                 dBS   state before del2 sponge diffusion               |  |  |")
    print("                 dAS   state after del2 sponge diffusion                |  |  |")  
    print("              end hyperviscosity loop -----------------------------------  |  |")
    print("          end of vertical Lagrangian dynamics loop -------------------------  |")
    print("          dAD  state after dynamics, before vertical remapping                |")
    print("          dAR     state after vertical remapping                              |")
    print("   end of remapping loop ------------------------------------------------------")
    print("dBF  state passed to parameterizations = state after last remapping            ")
    print(" ")
    print(" ")
    print(" ")
  end if

  if (dycore.eq."FV3") then    
    print("dED: state from end of previous dynamics (= pBF + time sampling)")
    print("dAP: Update state with entire physics tendencies on A-grid                     ")
    print("dBD: Update D-grid winds with physics wind tendencies                          ")
    print("dAT: Rayleigh friction (top of atmosphere damping)                             ")
    print("   loop over vertical remapping------------------------------- (k_split)-------")
    print("   dAF:                                                                       |")
    print("                                                                              |")
    print("          loop over vertical Lagrangian dynamics --------n_split------------  |")    
    print("              dAF:                                                            |")
    print("          end of vertical Lagrangian dynamics loop -------------------------  |")
    print("          dAD  state after dynamics, before vertical remapping                |")
    print("          dAR     state after vertical remapping                              |")
    print("   end of remapping loop ------------------------------------------------------")
    print("dBF  state passed to parameterizations = state after last remapping            ")
    print(" ")
    print(" ")
    print(" ")
  end if


  qsize = 3
  str_vars      = (/"MO","MR"/)
  if (dycore.eq."FV3") then
    str_stage     = (/"dED","dAT","dAF","dAD"  ,"dAR" ,"dBF"/)
    subcycle      = (/1.0D0,1.0D0,nsplit,nsplit,nsplit,1.0D0/)
;    str_stage     = (/"pBF","pBP","pAP","pAM","dED","dAT","dAF","dAD"  ,"dAR" ,"dBF"/)
;    subcycle      = (/1.0D0,1.0D0,1.0D0,1.0D0,1.0D0,1.0D0,nsplit,nsplit,nsplit,1.0D0/)            
;    str_stage     = (/"pBF","pBP","pAP","pAM","dED","dAP","dBD","dAT","dAF","dAD"  ,"dAR" ,"dBF"/)    
;    subcycle      = (/1.0D0,1.0D0,1.0D0,1.0D0,1.0D0,1.0D0,1.0D0,1.0D0,nsplit,nsplit,nsplit,1.0D0/)    
  end if
  if (dycore.eq."SE") then  
    str_stage     = (/"pBF","pBP","pAP","pAM","dED","dAF" ,"dBD" ,"dAD" ,"dAR" ,"dBF","dBH","dCH","dAH","dBS","dAS"/)
    subcycle    =     (/1D0,1D0  ,1D0  ,1D0  ,1.0D0,nsplit,nsplit,nsplit,nsplit,1.0D0,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle,nsplit*rsplit*hypervis_subcycle_sponge,nsplit*rsplit*hypervis_subcycle_sponge/)        
  end if

  nvars       = dimsizes(str_vars)
  nstage      = dimsizes(str_stage)
  print("nstage = "+nstage)
  vars        = new((/nvars,nstage,nt,ncol/),typeof(tmp(0,0)))


  tot_aam  = new((/nstage/),typeof(tmp(0,0)))
  MO_aam   = new((/nstage/),typeof(tmp(0,0)))
  MR_aam   = new((/nstage/),typeof(tmp(0,0)))

  dmdt_dyn  = new((/nt/),typeof(tmp(0,0)))
  dmrdt_dyn  = new((/nt/),typeof(tmp(0,0)))
  dmodt_dyn  = new((/nt/),typeof(tmp(0,0)))
  dmdt_phys = new((/nt/),typeof(tmp(0,0)))
  dmrdt_phys = new((/nt/),typeof(tmp(0,0)))
  dmodt_phys = new((/nt/),typeof(tmp(0,0)))
  mo = new((/nt/),typeof(tmp(0,0)))
  mr = new((/nt/),typeof(tmp(0,0)))

  int_vars  = new((/nvars,nstage,nt/)     ,typeof(tmp(0,0)))
  int_vars  = 0.0D0
  ;
  ; check that variables are on file and read them
  ;
  do k=0,nvars-1
    do j=0,nstage-1
      str = str_vars(k)+"_"+str_stage(j)
;      delete(tmp)
;      tmp = fall[:]->$str$(:,:)
      print(str+"  "+dimsizes(tmp))
;      delete(tmp)
      if (isfilevar(fall[0],str)) then
        vars(k,j,:,0:ncol-1) = fall[:]->$str$(:,:)
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
        int_vars(variable,stages,t) = sum(area(0:ncol-1)*vars(variable,stages,t,0:ncol-1));*inv_area_sphere
      end do
    end do
  end do

  ;
  ; For code clarity define indices corresponding to the different stages
  ;
  if (isfilevar(fall[0],"MO_pBF")) then
    ipBF = str_match_ind(str_stage,"pBF")
  else
    iPBF = -1
  end if
  if (isfilevar(fall[0],"MO_pBP")) then
    ipBP = str_match_ind(str_stage,"pBP")
  else
    iPBP = -1
  end if
  if (isfilevar(fall[0],"MO_pAP")) then
    ipAP = str_match_ind(str_stage,"pAP")
  else
    iPAP = -1
  end if
  if (isfilevar(fall[0],"MO_pAM")) then
    ipAM = str_match_ind(str_stage,"pAM")
  else
    iPAM = -1
  end if
  if (isfilevar(fall[0],"MO_dED")) then
    idED = str_match_ind(str_stage,"dED")
  else
    idED = -1
  end if
  if (isfilevar(fall[0],"MO_dBB")) then
    idBB = str_match_ind(str_stage,"dBB")
  else
    idBB = -1
  end if  
  if (isfilevar(fall[0],"MO_dBD")) then
    idBD = str_match_ind(str_stage,"dBD")
  else
    idBD = -1
  end if
  if (isfilevar(fall[0],"MO_dBK")) then
    idBK = str_match_ind(str_stage,"dBK")
  else
    idBK = -1
  end if
  if (isfilevar(fall[0],"MO_dAK")) then
    idAK = str_match_ind(str_stage,"dAK")
  else
    idAK = -1
  end if    
  if (isfilevar(fall[0],"MO_dAF")) then
    idAF = str_match_ind(str_stage,"dAF")
  else
    idAF = -1
  end if
  if (isfilevar(fall[0],"MO_dAD")) then
    idAD = str_match_ind(str_stage,"dAD")
  else
    idAD = -1
  end if
  if (isfilevar(fall[0],"MO_dAR")) then
    idAR = str_match_ind(str_stage,"dAR")
  else
    idAR = -1
  end if
  if (isfilevar(fall[0],"MO_dBF")) then
    idBF = str_match_ind(str_stage,"dBF")
  else
    idBF = -1
  end if
  if (isfilevar(fall[0],"MO_dBH")) then
    idBH = str_match_ind(str_stage,"dBH")
  else
    idBH = -1
  end if
  if (isfilevar(fall[0],"MO_dCH")) then
    idCH = str_match_ind(str_stage,"dCH")
  else
    idCH = -1
  end if
  if (isfilevar(fall[0],"MO_dBS")) then
    idBS = str_match_ind(str_stage,"dBS")
  else
    idBS = -1
  end if
  if (isfilevar(fall[0],"MO_dAS")) then
    idAS = str_match_ind(str_stage,"dAS")
  else
    idAS = -1
  end if                    
  if (isfilevar(fall[0],"MO_dAH")) then
    idAH = str_match_ind(str_stage,"dAH")
  else
    idAH = -1
  end if
  if (isfilevar(fall[0],"MO_dAP")) then
    idAP = str_match_ind(str_stage,"dAP")
  else
    idAP = -1
  end if
  if (isfilevar(fall[0],"MO_dAT")) then
    idAT = str_match_ind(str_stage,"dAT")
  else
    idAT = -1
  end if  


  do t=0,nt-1
    do j=0,nstage-1
      tot_aam(j)  = subcycle(j)*(int_vars(0,j,t)+int_vars(1,j,t))
      MO_aam(j)   = subcycle(j)*int_vars(0,j,t)
      MR_aam(j)   = subcycle(j)*int_vars(1,j,t)
    end do
    if (dycore.eq."SE") then      
      ;
      ;
      ; total dynamics incl. physics dribble
      ;
      print("idBF : "+idBF)
      print("idED : "+idED)      
      check_subc(subcycle(idBF),subcycle(idED))
      dyn_total         = (tot_aam(idBF)-tot_aam(idED))/dtime

      check_subc(subcycle(idBD),subcycle(idAF))
      phys_in_dyn_total = (tot_aam(idBD)-tot_aam(idAF))/dtime
      

      dADIA = dyn_total-phys_in_dyn_total


      rate_of_change_2D_dyn = (tot_aam(idAD)-tot_aam(idBD))/dtime
      check_subc(subcycle(idAR),subcycle(idAD))
      rate_of_change_vertical_remapping = (tot_aam(idAR)-tot_aam(idAD))/dtime

      check_subc(subcycle(idAH),subcycle(idCH))
      rate_of_change_heating_term_put_back_in = (tot_aam(idAH)-tot_aam(idCH))/dtime
      check_subc(subcycle(idAH),subcycle(idBH))
      rate_of_change_hypervis_total               = (tot_aam(idAH)-tot_aam(idBH))/dtime

      MR_phys = (MR_aam(idBD)-MR_aam(idAF))/dtime
      print("1Physics torque in dynamics dMR/dt="+MR_phys+" "+MR_aam(idBD)+"  "+MR_aam(idAF))
      MO_phys = (MO_aam(idBD)-MO_aam(idAF))/dtime
      print("2Physics torque in dynamics dMO/dt="+MO_phys+" "+MO_aam(idBD)+"  "+MO_aam(idAF))      

      dmdt_dyn(t)  = dADIA
      dmrdt_dyn(t) = (MR_aam(idBF)-MR_aam(idED)-(MR_aam(idBD)-MR_aam(idAF)))/dtime
      dmodt_dyn(t) = (MO_aam(idBF)-MO_aam(idED)-(MO_aam(idBD)-MO_aam(idAF)))/dtime
      
      check_subc(subcycle(idAF),subcycle(idBD))
      rate_of_change_phys = (tot_aam(idBD)-tot_aam(idAF))/dtime

      dmdt_phys(t) = rate_of_change_phys
      dmrdt_phys(t) = (MR_aam(idBD)-MR_aam(idAF))/dtime
      dmodt_phys(t) = (MO_aam(idBD)-MO_aam(idAF))/dtime

;      dmdt_phys(t)  = (tot_aam(ipAM)-tot_aam(ipBF))/dtime
;      dmrdt_phys(t) = (MR_aam(ipAM)-MR_aam(ipBF))/dtime
;      dmodt_phys(t) = (MO_aam(ipAM)-MO_aam(ipBF))/dtime

      mo(t) = MO_aam(idED)
      mr(t) = MR_aam(idED)

      if (lprint) then
      print(" ")
      print("=================================================================================")
      print("|                                                                                                ")
    print("| ANALYSIS OF AXIAL ANGULAR MOMENTUM DIAGNOSTICS IN DYNAMICS at time index="+t    )
    print("|                                                                                ")
      print("=================================================================================")
      print(" ")

      print("dM/dt total adiabatic dynamics                    "+sprintf("%6.4g",dADIA)+" kg*m^2/s^2")    
      print("dM/dt 2D dynamics                       (dAD-dBD) "+sprintf("%6.4g",rate_of_change_2D_dyn)+" kg*m^2/s^2")
      print("dM/dt vertical remapping                (dAR-dAD) "+sprintf("%6.4g",rate_of_change_vertical_remapping)+" kg*m^2/s^2")

      print(" ")
      print("Breakdown of 2D dynamics:")
      print(" ")

      print("      dM/dt hypervis                    (dAH-dBH) "+sprintf("%6.4g",rate_of_change_hypervis_total)+" kg*m^2/s^2")
      print("      dM/dt frictional heating          (dAH-dCH) "+sprintf("%6.4g",rate_of_change_heating_term_put_back_in)+" kg*m^2/s^2")
      error = rate_of_change_2D_dyn-rate_of_change_hypervis_total
    print("      dM/dt residual (time truncation errors)     "+sprintf("%6.4g",error)+" kg*m^2/s^2")

      print(" ")
      print("      dM/dt physics     "+sprintf("%6.4g",rate_of_change_phys)+" kg*m^2/s^2")
      print(" ")
      end if
    end if

    if (dycore.eq."FV3") then      
      check_subc(subcycle(idBF),subcycle(idAT))
      dADIA = (tot_aam(idBF)-tot_aam(idAT))/dtime

      dmdt_dyn(t)  = dADIA
      print("idBF="+idBF+"  "+"idAT="+idAT)      
      dmrdt_dyn(t) = (MR_aam(idBF)-MR_aam(idAT))/dtime
      dmodt_dyn(t) = (MO_aam(idBF)-MO_aam(idAT))/dtime

      check_subc(subcycle(idED),subcycle(idAT))
      rate_of_change_phys = (tot_aam(idAT)-tot_aam(idED))/dtime

      dmdt_phys(t) = rate_of_change_phys
      dmrdt_phys(t) = (MR_aam(idAT)-MR_aam(idED))/dtime
      dmodt_phys(t) = (MO_aam(idAT)-MO_aam(idED))/dtime

      mo(t) = MO_aam(idED)
      mr(t) = MR_aam(idED)
    end if
  end do
  ;
  ; write integrals to file
  ;
  dmdt_dyn!0 = "time"
  dmdt_dyn&time = time
  dmrdt_dyn!0 = "time"
  dmrdt_dyn&time = time
  dmodt_dyn!0 = "time"
  dmodt_dyn&time = time
  dmdt_phys!0 = "time"
  dmdt_phys&time = time
  dmodt_phys!0 = "time"
  dmodt_phys&time = time
  dmrdt_phys!0 = "time"
  dmrdt_phys&time = time
  mo!0 = "time"
  mo&time = time
  mr!0 = "time"
  mr&time = time

  fname_out    = "dmdt.nc"
  ncdf     = addfile(fname_out ,"c")  ; open output netCDF file
  ;
  ncdf->dmdt_dyn   = dmdt_dyn
  ncdf->dmrdt_dyn  = dmrdt_dyn
  ncdf->dmodt_dyn  = dmodt_dyn
  ncdf->dmdt_phys  = dmdt_phys
  ncdf->dmrdt_phys = dmrdt_phys
  ncdf->dmodt_phys = dmodt_phys
  ncdf->mo   = mo
  ncdf->mr   = mr
end


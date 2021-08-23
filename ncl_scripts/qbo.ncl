;
; 1) Take zonal mean U (monthly mean)
; 2) Average between 5S and 5N
; 3) Plot as timeseries:
;


;**************************************
;zonals.ncl
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************
begin
;****************************************
  fnames = (/fname/)
  print("fnames="+fnames)
  nfiles = dimsizes(fnames)
  secpday = 60.*60.*24;
  pi = 3.14159265358979
  g = 9.80616 ;m/s2
  p0 = 1.e5 ;Pa



;---Start the graphics
  wks = gsn_open_wks("pdf","temp")
  plot = new((/1/),graphic)

;  gsn_define_colormap(wks,"NCV_blu_red")ncl_default
  gsn_define_colormap(wks,"ncl_default")

;---Plotting options for time series plot
  res             = True
  ;res@gsnMaximize = True
  res@gsnPaperOrientation = "landscape"

  res@gsnDraw     = True; False      ; Will draw later, after overlaying
  res@gsnFrame    = True;False      ; all plots

  res@vpWidthF   = .90
   res@vpHeightF  = .35 
   res@vpXF       = .10

;  res@xyLineThicknesses = 5
;  res@vpWidthF    = 0.8        ; Make plots wider
;  res@vpHeightF   = 0.5

;  res@tmBorderThicknessF = 4 ;axes thickness

;  ls_command = "ls "+"*cam.h0.200*-*.nc" ;dir+"/"+case+".cam."+h_number+".*.nc"
;
; MPAS
;
;  ls_command = "ls "+"*cam.h0.*-*lat-lon.nc" ;dir+"/"+case+".cam."+h_number+".*.nc" ;default
;
; SE
;
  ls_command = "ls "+"*cam.h0.*-*.nc" ;dir+"/"+case+".cam."+h_number+".*.nc" ;default
;  ls_command = "ls "+"*cam.h0.1996-*.nc" ;dir+"/"+case+".cam."+h_number+".*.nc" ;default

;  ls_command = "ls "+"*cam.h0.00[0][2-4]-*.nc"
;  ls_command = "ls "+"*cam.h0.00[0][0-9]-*.nc" ; first 10 years
;  ls_command = "ls "+"*cam.h0.00[2][0-9]-*.nc" ;  year 20-29
;  ls_command = "ls "+"*cam.h0.00[1-2][0-9]-*.nc" ;  year 10-19
;  ls_command = "ls "+"*cam.h0.199*-*.nc" ;  year 10-19
  all_files = systemfunc (ls_command)

  print("addfiles "+all_files)
  f  = addfiles (all_files,"r")
  ListSetType(f,"cat")
;
; MPAS
;
;  fphis  = addfile ("PHIS.nc","r")
;
; SE
;
  fphis  = addfile ("/glade/p/cesmdata/cseg/inputdata/atm/cam/topo/fv_0.9x1.25_nc3000_Nsw042_Co060_Fi001_GRNL_c170405.nc","r")
  ;
  ; interpolate to pressure levels
  ;
  vartmp = f[:]->$vname$
  printVarSummary (vartmp)
  nlev   = dimsizes(vartmp&lev)
  print("====")
  PSFC   = f[:]->PS
  PSFC   = PSFC/100.0
  P0mb   = 1000.0
  tbot   = f[:]->T(:,nlev-1,:,:)
  PHIS   = fphis->PHIS
  hyam   = f[0]->hyam
  hybm   = f[0]->hybm
  lev  = new(nlev,double)
  do k=0,nlev-1
    lev(k) = hyam(k)*P0mb+hybm(k)*P0mb
  end do
  if (isfilevar(f[0], "PMID"))
    PRESI  = f[:]->PMID
    PRESI  = PRESI/100.0
  else
    print("PMID not present on file - deriving from hyam,hybm and PS")
    PRESI   = f[:]->T(:,:,:,:)
    P0TMP   = PSFC
    nlon = dimsizes(PRESI(0,0,0,:))
    nlat = dimsizes(PRESI(0,0,:,0))
    ntim = dimsizes(PRESI(:,0,0,0))
    print("asdfasdf")
    printVarSummary(hyam)

    do k=0,nlev-1
        PRESI(:,k,:,:) = doubletofloat(hyam(k)*1000e0+hybm(k)*PSFC(:,:,:))
      end do
    delete(P0TMP)
  end if




  intyp = 1                             ; 1=linear, 2=log, 3=log-log
  kxtrp = True                          ; True=extrapolate
  varflg = 0 
  nmonths = dimsizes(vartmp(:,1,1,1))
  var = vartmp
  do k=0,nmonths-1
    var(k,:,:,:) = vintp2p_ecmwf(vartmp(k,:,:,:), PRESI(k,:,:,:),lev,PSFC(k,:,:),intyp,1,kxtrp,varflg,tbot(k,:,:),PHIS)
  end do

  printVarSummary (var)

  
  lat = f[0]->lat
  ntime = dimsizes(f[:]->time)
  lat   = f[0]->lat
;  lev   = f[0]->lev
  time  = f[:]->time
  date = f[:]->date  
  delete(f)

  lat_min_idx=ind_nearest_coord (-5, lat, 0)
  lat_max_idx=ind_nearest_coord ( 5, lat, 0)
  print("index closest to -5 is "+lat_min_idx+" which is latitude "+lat(lat_min_idx))
  print("index closest to -5 is "+lat_max_idx+" which is latitude "+lat(lat_max_idx))

  plev_min_idx=ind_nearest_coord (0.5, lev, 0)
  plev_max_idx=dimsizes(lev)-1;ind_nearest_coord (100, lev, 0)
;  plev_max_idx=ind_nearest_coord (100, lev, 0)
  print("plev_min_idx = "+plev_min_idx)
  print("plev_max_idx = "+plev_max_idx)


  eq_band_var  = var(:,plev_min_idx:plev_max_idx,lat_min_idx:lat_max_idx,:)
  delete(var)
  yearfrac = cd_calendar(time,  4)


;time = 1.0+time/365.0

  print("zonal avg...")
  ;;; zonal average
  UQBO = dim_avg_Wrap(dim_avg_Wrap(eq_band_var))
;  var_qbo = dim_avg(eq_band_var)

 printVarSummary (UQBO)

 ntim = dimsizes(date)
 klev = plev_max_idx-plev_min_idx+1
 print("klev="+klev)
 ntim = dimsizes(UQBO(:,1))
 print("ntim="+ntim)
 U    = new ( (/klev,ntim/), typeof(UQBO), getFillValue(UQBO)) 

 U(:,:) = (/ UQBO(lev_p|: , time|:) /) 
 U!0  = "plev"
 U!1  = "time"
 lev@units = "hPa"
 U&plev = lev(plev_min_idx:plev_max_idx)
 U&time = yearfrac ;time
 printVarSummary (U)

 

 res@tmXTOn               = False
 res@tmXBMode             = "Explicit"     
  res@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resources
 res@cnLineLabelsOn       = False 
 res@cnInfoLabelOn        = False      ; Turn off info label.
 res@cnMinLevelValF       = -40.
 res@cnMaxLevelValF       =  40.
 res@cnLevelSpacingF      =  5.
 res@gsnMaximize = True
 res@cnFillOn             = True
; res@cnLinesOn = False ;-- turn off contour lines
; res@cnFillPalette        = "amwg"     ; set color
 res@gsnContourZeroLineThicknessF = 2.	
 res@tiYAxisString       = "Pressure (hPa)"
; res@tiXAxisString       = "Time (years)"
 res@lbLabelBarOn        = True
 res@lbTitleString       = "zonal wind speed [m/s]"
 res@lbTitleFontHeightF= 0.015 
 res@lbLabelFontHeightF= 0.015
 res@pmLabelBarOrthogonalPosF = .1
; res@lbJustification     = "Bottom"
 res@gsnLeftStringFontHeightF = 0.02
 res@gsnLeftString = leftstring;"WACCM6-SE-CSLAM, "+dimsizes(lev)+" levels"
; res@gsnRightString = "compset: FWscHIST"
 res@gsnRightStringFontHeightF = 0.02
 res@gsnRightString = rightstring;"PPM vertical remap of u,v,T"
 res@tiMainString        = "Quasi-Biennial Oscillation (QBO) simulations"
 res@tmXLLabelFontHeightF = 0.024
  res@tmYLMode   = "Explicit"
  res@tmYLValues = (/ 800 , 700 , 600 , 500 , 400 , 300 , 200 , 150 , 100 , 50 , 30 , 10,1/)
  res@tmYLLabels = (/"800","   ","   ","500","   ","300","200","   ","100","50","30","10","1"/)
 plot(0) = gsn_csm_pres_hgt (wks, U(:,:),res)


;*****************************************************
; Plot panel
;*****************************************************

;  resP                  = True                   ; modify the panel plot
;  resP@gsnFrame         = False                  ; don't advance panel plot
;  ;resP@gsnPaperOrientation = "portrait"
;  resP@gsnPanelBottom   = 0.05
;  ;resP@gsnPanelFigureStrings = (/ "a","b","c","d" /)
;  ;resP@gsnPanelFigureStringsPerimOn     = True
;  ;resP@gsnPanelFigureStringsBackgroundFillColor = "white"
;  ;resP@amJust           = "TopRight"
;  resP@txString = "WACCM ne30pg3, COMPSET=FWscHIST, "+dimsizes(lev)+" levels"
;;  resP@txString = "WACCM ne30pg3, COMPSET=FWsc2000climo, "+dimsizes(lev)+" levels"
;;  resP@txString = "WACCM fv09, COMPSET=FWsc2000climo, "+dimsizes(lev)+" levels"
;  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

;  frame(wks)

end

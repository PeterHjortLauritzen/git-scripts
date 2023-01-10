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
;  vname="PRECT"
;  fname = (/"cpdry_but_T_mapping_internal_energy.nc","no_fric_heat.ave.h0.nc","dp.ave.h0.nc"/)
  colors = (/"blue","darkorchid4","blue","green","deepskyblue1"/)
  nfiles = dimsizes(fnames)
  labels = (/"no frictional heating","cpcnst in RK5"/)
  secpday = 60.*60.*24;
  pi = 3.14159265358979
  g = 9.80616 ;m/s2
  p0 = 1.e5 ;Pa



;---Start the graphics
  wks = gsn_open_wks("pdf","temp")
  plot = new((/1/),graphic)

;---Plotting options for time series plot
  res             = True
  ;res@gsnMaximize = True
  res@gsnPaperOrientation = "landscape"

  res@gsnDraw     = False      ; Will draw later, after overlaying
  res@gsnFrame    = False      ; all plots
  res@xyLineThicknesses = 5
  res@vpWidthF    = 0.8        ; Make plots wider
  res@vpHeightF   = 0.5

  res@tmBorderThicknessF = 4 ;axes thickness
  res@tmXBMajorOutwardLengthF = 0.
  res@tmYLMajorOutwardLengthF = 0.
  res@tmXBMinorOutwardLengthF = 0.
  res@tmYLMinorOutwardLengthF = 0.
  res@tmXTMajorOutwardLengthF = 0.
  res@tmYRMajorOutwardLengthF = 0.
  res@tmXTMinorOutwardLengthF = 0.
  res@tmYRMinorOutwardLengthF = 0.

  res@trXMinF     = -1.
  res@trXMaxF     = 1.
  res@tmXBMode        = "Explicit"
  res@tmXBValues      = (/-1,sin(-80*pi/180),sin(-70*pi/180),sin(-60*pi/180),sin(-50*pi/180),sin(-40*pi/180),sin(-30*pi/180),sin(-20*pi/180),sin(-10*pi/180),0.,sin(10*pi/180),sin(20*pi/180),sin(30*pi/180),sin(40*pi/180),sin(50*pi/180),sin(60*pi/180),sin(70*pi/180),sin(80*pi/180),1./)
  res@tmXBLabels      = (/"","-80","","-60","","-40","","-20","","0","","20","","40","","60","","80",""/)

do n = 0,nfiles-1
  print(n)
  files = systemfunc ("ls "+fnames(n))
  ;nhist = dimsizes(files)
  nhist = 1
  print("addfiles "+files)
  f  = addfiles (files(nhist-1),"r")
  ListSetType(f,"cat")
  delete(files)

  print("grabbing var...")
  if (vname.eq."PRECT") then
    print("Variable is PRECT")
    var = (f[:]->PRECC) + (f[:]->PRECL)
    yaxis = "Precipitation Rate (mm/day)"
    ;convert mm/day
    var = var*secpday*1000.  
  else
    var = f[:]->$vname$
    yaxis = "Precipitation Rate (mm/day)"
  end if
  lat = f[0]->lat
  ntime = dimsizes(f[:]->time)

  delete(f)

  print("zonal avg...")
  ;;; zonal average
  var_zon = dim_avg(var)
  delete(var)

  res@xyLineColors           = colors(n)

  if (n.eq.0) then
    res@trYMinF     = 0.
    res@trYMaxF     = 18.
    res@tiYAxisString          = yaxis
    plot(0) = gsn_csm_xy(wks,sin(lat*pi/180.),var_zon,res)
    delete(res@tiYAxisString)
  else
    dum = gsn_csm_xy(wks,sin(lat*pi/180.),var_zon,res)
    overlay(plot(0),dum)
    delete(dum)
  end if

  delete(var_zon)

  print("done with file " + n)
end do ;nfiles

;*****************************************************
; Plot panel
;*****************************************************

  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
  ;resP@gsnPaperOrientation = "portrait"
  resP@gsnPanelBottom   = 0.05
  ;resP@gsnPanelFigureStrings = (/ "a","b","c","d" /)
  ;resP@gsnPanelFigureStringsPerimOn     = True
  ;resP@gsnPanelFigureStringsBackgroundFillColor = "white"
  ;resP@amJust           = "TopRight"
  resP@txString = "ne60pg2, QPC6, 2 yr ave, new mapping code"
  gsn_panel(wks,plot,(/1,1/),resP)               ; now draw as one plot

  frame(wks)

end

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$ncl_dir/contour-levels.ncl"
begin
  system("touch abnormal_exit_zonal_time_avg") 
  print(lsArg)
;  case="test"

  case=titles
  pi = 4.*atan(1.0)
  
  fnames=lsArg

  print(fnames)
  fnum_files = dimsizes(fnames)
  output_format = "pdf"
  print(fnum_files)
  if (fnum_files.eq.1)
    plotfile_name = "zonal_time_avg_"+vname+"_"+case(0)
  else
    plotfile_name = "zonal_time_avg_"+vname
  end if
  wks = gsn_open_wks(output_format,plotfile_name)

  fall = addfiles(fnames,"r")       ; Open netCDF files.	
  print("Numner of files: "+fnum_files)

  fcnt = fnum_files

  f=fall[0]
  ntimes   = dimsizes(f&time)
  nlev     = dimsizes(f&lev)
  nlat     = dimsizes(f&lat)
  nlon     = dimsizes(f&lon)
  time     = f->time

  degrees2radians = atan(1.0)/45.0

  ;
  ; is this a 2d or 3d variable
  ;
  dNames=getfilevardims(f,vname)
  print("vname="+vname)
  nrank =dimsizes(dNames)               ; determine the number of dimensions
  print("dnames "+dNames)
  l2d=True
  if (vname.eq."ALBEDO") then
    ; since ALBEDO is a derived variable we need this if-statement
    l2d=True
  else
    do jj=0,nrank-1
       if(str_lower(dNames(jj)).eq."lev") then
         l2d=False
       end if
    end do
  end if
  print("xxxxxxxx")
  print("variable is 2D? "+l2d)

;  if (plot_lat_section) then
;    print("plot_lat_section_min"+plot_lat_section_min)
;    lat   = f->lat
;    lat_min_idx=ind_nearest_coord (plot_lat_section_min, lat, 0)
;    lat_max_idx=ind_nearest_coord (plot_lat_section_max, lat, 0)
;    print("min"+lat_min_idx)
;    print("max"+lat_max_idx)
;    delete(lat)
;  end if

  gsn_define_colormap(wks,"BlWhRe")                ; choose colormap

  if (l2d) then
;    line_colors_list = (/"red","blue","green","purple"/) ;  "orange","red","blue","green","purple"

    ;
    ;  zonal average plot 2d
    ;
    pll = new((/fcnt,nlat/),double)
    p2d = new((/fcnt,nlat,nlon/),double)
    print("fcnt="+fcnt)
    resxy = True
    resxy@gsnFrame = False
    resxy@tiMainString   = vname+" "+case
    resxy@tiXAxisString  = "latitude"
    resxy@xyLineColors   = line_colors
    thck = 4.0
    resxy@xyLineThicknesses = (/thck,thck,thck,thck,thck,thck,thck,thck/)
    resxy@xyMonoDashPattern = True
    do k=0,fcnt-1
      f=fall[k];
      printVarSummary(f)
      if (vname.eq."ALBEDO") then
        solin =f->SOLIN(0,:,:)
        fsnt  =f->FSNT (0,:,:)
        alb = (solin-fsnt)/(fsnt+1.d-5)
        varll = dim_avg_Wrap(alb)
        var2d = alb
      else
        var2d = f->$vname$(0,:,:)
        varll =dim_avg_Wrap(var2d)
         
      end if     
      pll(k,0:nlat-1) = varll
      p2d(k,:,:) = var2d
      delete(varll)
    end do 
    lat = f->lat

    if (vname.eq."PRECT") then 
      pll              = 1000.0*24.0*3600.0*pll ;convert from m/s to mm/day
      p2d              = p2d*1000.0*24.0*3600.0
      resxy@tiYAxisString          = "mm/day"
      resxy@tiMainString = "Zonal-time averaged total precipitation rate"
    end if
    if (vname.eq."CLDTOT") then
      resxy@tiYAxisString = "fraction"
      resxy@tiMainString  = "Zonal-time averaged total cloud"
    end if
    if (vname.eq."ALBEDO") then
      resxy@tiYAxisString = "fraction"
      resxy@tiMainString  = "Zonal-time averaged albedo"
    end if
    if (vname.eq."PS") then
      resxy@tiYAxisString = "hPa"
      resxy@tiMainString  = "Zonal-time averaged PS"
      pll = pll/100.0
      p2d = p2d/100.0
    end if


    if (plot_lat_section) then
      if (lsinx) then
        resxy@trXMinF=sin(plot_lat_section_min*pi/180.)
        resxy@trXMaxF=sin(plot_lat_section_max*pi/180.)

        resxy@tmXBMode = "Explicit"    ; with sine lat and hemispheric
        resxy@tmXBLabels = (/"0",""  ,"20","",  "40","",  "60","",  "80" /)
        resxy@tmXBValues = (/ 0., 10., 20. ,30., 40., 50., 60., 70., 80. /)
        resxy@tmXBMinorValues = (/10., 20., 30., 50., 60., 70., 90. /)
        resxy@tmXBValues = sin((resxy@tmXBValues)*pi/180.)
        resxy@tmXBMinorValues = sin((resxy@tmXBMinorValues)*pi/180.)
      else
        resxy@trXMinF=plot_lat_section_min
        resxy@trXMaxF=plot_lat_section_max
      end if
        resxy@trXReverse    = True                        ; reverse X axis
    end if

;    resxy@sfXArray = sin(lat*pi/180.)

    if (lsinx) then
      plot = gsn_xy(wks,sin(fall[0]&lat*pi/180.0),pll(:,:),resxy)
    else
      plot = gsn_xy(wks,fall[0]&lat,pll(:,:),resxy)
    end if

    ; 
    ; Legend
    ;
    lgres = True
    lgres@pmLegendDisplayMode    = "Always"            ; turn on legend

  ;  resxy@pmLegendSide           = "Left"               ; Change location of 
    lgres@lgTitleAngleF = 90.0
    lgres@xyExplicitLegendLabels = case
    lgres@lgAutoManage = False
    lgres@lgLabelFontHeightF = 0.3
    lgres@vpWidthF           = 0.24                   ; width of legend (NDC)
    lgres@vpHeightF          = 0.16                   ; height of legend (NDC)
    lgres@lgPerimOn          = False                 ; turn off perimeter
    lgres@lgLineColors       = line_colors
    lgres@lgDashIndexes      = (/0,0,0,0,0,0,0,0,0,0,0,0/)              ; dash indexes
    lgres@lgLineThicknessF = 4.0
    lgres@pmLegendParallelPosF = 1.4
    gsn_legend_ndc(wks,dimsizes(case),case,0.25,0.55,lgres)

    frame(wks)

    ;
    ; do 2D plot
    ;
    plot2d = new(fnum_files,graphic)
    res             = True
    res@mpFillOn    = False; turn map fill off
    res@mpOutlineOn = True; turn the map outline on
;      res@cnLevelSelectionMode = "ExplicitLevels"    ; set explicit contour levels
;res@cnLevels    = (/ -10.,-8.,-6.,-4.,-2.,-1.,1.,2.,4.,6.,8.,10./); set levels
    res@cnFillOn    = True   ; turn on color fill
    res@cnLinesOn   = False   ; turn off the contour lines
;res@cnFillColors = (/ 13,23,30,36,41,45,-1,59,63,68,74,81,91/); set the colors to be used
    res@cnLineLabelsOn = False; turn the line labels off
    res@gsnDraw              = False
    res@gsnFrame             = False 

    wks2d = gsn_open_wks(output_format,"2d_"+vname)
    gsn_define_colormap(wks2d,"BlWhRe")                ; choose colormap
    do i=0,fnum_files-1
      res@tiMainString = case(i);fnames(i)
      if (diff) then
        res@lbLabelBarOn = True
        if (i.eq.0) then
          setContourLevels (res, vname,False)
          var2d_ref = p2d(i,:,:)
        else
          setContourLevels (res, vname,diff)
          p2d(i,:,:) = p2d(i,:,:)-var2d_ref
        end if
      else
         setContourLevels (res, vname,False)

;        res@lbLabelBarOn = False
      end if
      plot2d(i) = gsn_csm_contour_map_ce(wks2d,p2d(i,:,:),res)  
    end do
    pres = True
    if (diff) then
      pres@gsnPanelLabelBar = False                   ; add common colorbar
    else
      pres@gsnPanelLabelBar = True
    end if
;    pres@gsnPanelBottom   = 0.05
    pres@txString = "Time averaged "+vname 
    if (fnum_files.ne.1) then
       gsn_panel(wks2d,plot2d,(/2,2/),pres)
    else
       gsn_panel(wks2d,plot2d,(/1,1/),pres)
    end if
  else
    ;
    ;  zonal average plot (3d field)
    ;  
    plot = new(fnum_files,graphic)
    do i=0,fnum_files-1
      f     = fall[i]
      printVarSummary(f)

;      if (plot_lat_section) then
;        f3d   = f->$vname$(0,:,lat_min_idx:lat_max_idx,:)
;        PS    = f->PS(0,lat_min_idx:lat_max_idx,:)                              ; get pressure                         
;        lat   = f->lat(lat_min_idx:lat_max_idx)
;      else
      f3d   = f->$vname$(0,:,:,:)
      PS    = f->PS(0,:,:)                                ; get pressure                                              
      lat   = f->lat
;      end if

      lev   = f->lev



      hyam  = f->hyam
      hybm  = f->hybm

      nlev  = dimsizes(hyam)

;      ps0   = f->P0
      ps0 =  100000.0
      ; data must be on pressure levels
      P0mb =ps0/100.0

     ;************************************************ 
     ; define other arguments required by vinth2p
     ;************************************************                   
     ; type of interpolation: 1 = linear, 2 = log, 3 = loglog
     interp = 2
 
     ; is extrapolation desired if data is outside the range of PS
     extrap = False
 
     ; create an array of desired pressure levels:
     if (vertical_height) then
       minP = 10.0
     else
       minP = 1.0
     end if
     minP = 1.0
     maxP = 1000.0
     dp   = (maxP-minP)/(nlev-1)
     pnew = new(nlev,double)
     do k=0,nlev-1
  ;     pnew(k) = hyam(k)*ps0+hybm(k)*ps0
        pnew(k) = minP+(k)*dp
     end do
     ;   pnew(0) = 100.0
     ;   pnew(nlev) = 100000.0
     pnew!0         = "pnew"                  ; variable/dim name
     pnew&pnew      =  pnew                   ; create coordinate variable
     pnew@long_name = "pressure"               ; attach some attributes
     pnew@units     = "hPa"
     pnew@positive  = "down"
  ;  pnew = pnew/100.0
     print(pnew)
  ;   pnew = (/ 850.0,700.0,500.0,300.0,200.0 /)
    ;************************************************
    ; calculate field on pressure levels
    ;************************************************       
    ; note, the 7th argument is not used, and so is set to 1.
    ;************************************************
     fonP = vinth2p(f3d,hyam,hybm,pnew,PS,interp,P0mb,1,extrap)
  
    ;************************************************
    ;  calculate zonal average of 3d variable
  
    zonal_fonP =  dim_avg(fonP)                             ; calculate zonal ave

    if (diff) then
      if (i.eq.0) then
         zonal_ref = zonal_fonP
      else
         zonal_fonP = zonal_fonP-zonal_ref
      end if
    end if

    if (vname.eq."Q") then
      zonal_fonP = zonal_fonP*1000.0
      zonal_fonP@units = "g/kg"
    else
      zonal_fonP@units = f3d@units
    end if

    if (vname.eq."PTEQ") then
      zonal_fonP = zonal_fonP*1000.0*24.0*3600
      zonal_fonP@units = "g/kg/day"
    else
      zonal_fonP@units = f3d@units
    end if

    if (vname.eq."PTTEND") then
      zonal_fonP = zonal_fonP*24.0*3600
      zonal_fonP@units = "K/day"
    else
      zonal_fonP@units = f3d@units
    end if

    if (vname.eq."OMEGA") then
      zonal_fonP = zonal_fonP*100.0
      zonal_fonP@units = "hPa/s"
    else
      zonal_fonP@units = f3d@units
    end if

    if (coslat) then
      cos_lat = lat*cos(degrees2radians*lat)
      print("coslat"+cos_lat)  
      print("lat"+lat)
      zonal_fonP!1 = "cos_lat"
      zonal_fonP&cos_lat = cos_lat
    else 
      zonal_fonP!1 = "lat"
      zonal_fonP&lat = lat
    end if
    zonal_fonP!0 = "pnew"
    zonal_fonP&pnew = pnew





 
  ; color plot
  ; =========================== 
    res                      = True                  ; plot mods desired
    if (plot_lat_section) then
      res@trXMinF=plot_lat_section_min
      res@trXMaxF=plot_lat_section_max
    end if
    if (fnum_files.eq.1) then
      res@tiMainString         = "Zonal-time averaged "+vname +" ("+case(i)+")"       ; title
;       res@gsnCenterString = "Zonal-time averaged "+vname +" ("+case(i)+")"
    else
       res@gsnLeftString = case(i)
;      res@tiMainString         = case(i)       ; title
    end if

    if (i.eq.0) then
      setContourLevels (res, vname,False)
    else
      setContourLevels (res, vname,diff)
    end if




    if (vname.eq."Q") then
      res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
;      res@cnLevelSpacingF      = 0.05                   ; contour interval
;      res@cnMinLevelValF       =  0.0                  ; min level
;      res@cnMaxLevelValF       =  0.020                  ; max level
    end if


;  res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
;  res@cnLevelSpacingF      = 4.0                   ; contour interval
;  res@cnMinLevelValF       = -24.                  ; min level
;  res@cnMaxLevelValF       =  32.                  ; max level

;   res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
;   res@cnLevelSpacingF      = 5.0                   ; contour interval
;   res@cnMinLevelValF       =  190.                  ; min level
;   res@cnMaxLevelValF       =  310.                  ; max level

  if (diff) then
    res@lbLabelBarOn = True
  else
    res@lbLabelBarOn = False
  end if
  res@cnLineLabelsOn       = False                  ; turn on line labels
  res@cnFillOn             = True                  ; turn on color fill
  res@gsnDraw              = False
  res@gsnFrame             = False 
  res@cnInfoLabelOn        = False


    if (vertical_height) then



;---This resource not needed in V6.1.0
      res@gsnSpreadColors      = True                  ; use full range of colors

;---This resource defaults to True in NCL V6.1.0                                   
      res@lbLabelAutoStride    = True                  ; optimal labels

      
      plot(i) = gsn_csm_pres_hgt(wks,zonal_fonP,res)

      nlev = dimsizes(hyam)
      plres = True
      plres@gsLineColor = "white"
      hybrid_lev = new((/2,nlev/),double)
      xcoord     = new(2,double)
      xcoord(0) = -90.0;YYYYMMDD(nn_start)
      xcoord(1) = 90.0;YYYYMMDD(Fnum-1)
      if (i.eq.0) then
        dum = new((/nlev/),graphic)
        do k = 0 ,nlev-1
          hybrid_lev(0,k) = hyam(k)*1000.0+hybm(k)*1000.0
          hybrid_lev(1,k) = hyam(k)*1000.0+hybm(k)*1000.0
        end do
        do k = 0 ,nlev-1
          dum(k) = gsn_add_polyline(wks,plot(i),xcoord,hybrid_lev(:,k),plres)
        end do
      end if			
    
  
    else
;      stop
      res               = True
;      res@tiXAxisString = "latitude"                  ; x-axis label
      res@tiYAxisString = "Pressure [hPa]"                ; y-axis label
      if (coslat) then
        res@sfXArray      = cos_lat;zonal_fonP&lat                    ; put lat on x axis
      else
        res@sfXArray      = zonal_fonP&lat                    ; put lat on x axis
      end if
      res@sfYArray      = pnew                         ; put eta on y axis
;      zonal_fonP@units =  f3d@units
;      zonal_fonP!0 = "hPa"
      res@trYReverse    = True                        ; reverses y axi
      res@trXReverse    = True                        ; reverse X axis
      plot(i)=gsn_csm_contour(wks,zonal_fonP,res)           ; plot zonal ave
    end if
;    draw(plot)
      delete(PS)
      delete(f3d)
    end do
    pres = True
    if (.not.diff) then
       pres@gsnPanelLabelBar = True                   ; add common colorbar
       pres@gsnPanelBottom   = 0.05
    end if
;    pres@txString = "Zonal-time averaged "+vname 
    if (fnum_files.ne.1) then
       gsn_panel(wks,plot,(/2,2/),pres)
    else
       gsn_panel(wks,plot,(/1,1/),pres)
    end if
  end if
  system("\rm abnormal_exit_zonal_time_avg") 
end

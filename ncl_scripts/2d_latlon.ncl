load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;  vname = "Tgll_dbg"
;  fnames =  systemfunc("ls NE30NP4_APE.3yr_ave.6month_spinup.nc")
;  fnames =  systemfunc("ls NE30NP4NC3_APE.2yr_ave.3month_spinup.nc")
  fnames =  systemfunc("ls "+lsArg)
  output_format = "pdf"

  wks = gsn_open_wks(output_format,plot_dir+"2d_"+case+vname)
  fall = addfiles(fnames,"r")       ; Open netCDF files.	
  fcnt = dimsizes(fnames)
  print(fnames)

  lon = fall[0]->lon
  lat = fall[0]->lat
  nlon=dimsizes(lon)
  nlat=dimsizes(lat)

  pi = 3.14159265358979323846264338327D0
  deg2rad = pi/180.0
;  lat1d=lat1d*180.0/pi
;  lon1d=lon1d*180.0/pi


;******************************************************
; create plot
;******************************************************

  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   ; choose colormap


  res                     = True         ; plot modifications desired
  res@gsnMaximize         = True         ; Maximize size of plot in frame
  res@gsnSpreadColors     = True         ; Use full colormap, but start
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnFillOn            = True         ; Turn on contour fill
;  res@cnFillMode          = "AreaFill"   ; Style of fill. You can also
                                         ; use "CellFill" and "RasterFill"
  res@cnLinesOn           = False        ; Turn off contour lines
  res@cnLineLabelsOn      = False        ; Turn off contour line labels
  res@lbLabelAutoStride   = True         ; Clean up labelbar labels.
  res@mpOutlineOn     = False       ; No continents
;  res@cnFillMode="RasterFill"


;  res@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resources
;  res@cnMinLevelValF  = -2.0                        ; set the minimum contour level
;  res@cnMaxLevelValF  = 2.0                   ; set the maximum contour level
;  res@cnLevelSpacingF = 0.2                  ; set the interval between contours

  res@mpMinLatF = -80.                   ; set the minimum latitude = -70.
  res@mpMaxLatF = 80.                    ; set the maximum latitude = 70.

; res@mpMinLonF = -40.                    ; set the minimum latitude = -70.
;  res@mpMaxLonF = 40.

  plot = new(fcnt,graphic) 
  do k=0,fcnt-1
    print("plot "+k)
;    lat1d = fall[k]->lat          ; Pull off lat/lon variable and
;    lon1d = fall[k]->lon          ; convert both to 1D.

    var  = fall[k]->$vname$(0,1,:,:)    ; Read some data; convert to 1D.i
    do i=0,nlon-1
      var(:,i) = var(:,i)/100.0;-100.0*(2.0D0+cos(deg2rad*lat(:)))
    end do
;    var=var-99.9999999999D0
    do j=0,nlat-1
      do i=0,nlon-1
;        if (var(j,i).lt.0.0) then
;          var(j,i) =  0.0
;        end if
;        if (var(j,i).gt.100.0) then
;;          var(j,i) =  0.0
;          print("asdfasdf "+var(j,i))
;        end if

      end do  
    end do
    res@tiMainString        = case(k)
;    res@sfXArray            = lon1d        ; Required to tell NCL where to
;    res@sfYArray            = lat1d        ; overlay data on globe.

    if (vname.eq."PRECT") then
      var = 1000*24*3600*var ;convert from m/s to mm/day  
      res@cnLevelSelectionMode = "ManualLevels"
      res@cnMinLevelValF  = 0.0
      res@cnMaxLevelValF  = 24.0               
      res@cnLevelSpacingF = 2.0              
      res@gsnRightString = "mm/day"
    end if
    res@mpCenterLonF = 180.0           ; Rotate the projection.

;      res@cnLevelSelectionMode = "ManualLevels"
;      res@cnMinLevelValF  = -20.0
;      res@cnMaxLevelValF  = 120.0               
;      res@cnLevelSpacingF = 10.0              


    plot(k) = gsn_csm_contour_map_ce(wks,var,res)
;    delete(lon1d)
;    delete(lat1d)
    delete(var)
;    delete(res@sfXArray)
;    delete(res@sfYArray)
  end do

;************************************************
; create panel
;************************************************
  resP                  = True                   ; modify the panel plot
  resP@gsnFrame         = False                  ; don't advance panel plot
;  resP@gsnPanelLabelBar = True                   ; add common colorbar
;  resP@gsnPanelBottom   = 0.05
;  resP@txString   = "A common title"
  gsn_panel(wks,plot,(/1,fcnt/),resP)               ; now draw as one plot


  txres               = True
;  txres@txFontHeightF = 0.015
;  gsn_text_ndc(wks,"Figure 1: A nifty panel plot",0.5,0.02,txres)
  frame(wks)
end

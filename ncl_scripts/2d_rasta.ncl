load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;  vname = "PRECT"
;  fnames =  systemfunc("ls NE30NP4_APE.3yr_ave.6month_spinup.nc")
;  fnames =  systemfunc("ls NE30NP4NC3_APE.2yr_ave.3month_spinup.nc")
  fnames =  systemfunc("ls "+fname)
  output_format = "pdf"

  wks = gsn_open_wks(output_format,"2d_rasta_"+vname)
  fall = addfiles(fnames,"r")       ; Open netCDF files.	
  fcnt = dimsizes(fnames)
  print(fnames)



;  pi = 3.14159265358979323846264338327
;  lat1d=lat1d*180.0/pi
;  lon1d=lon1d*180.0/pi


;******************************************************
; create plot
;******************************************************

;  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")   ; choose colormap
   gsn_define_colormap(wks,"temp_diff_18lev")

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
  res@cnFillMode          ="RasterFill"


;  res@mpFillOn            = True
  res@mpOutlineOn         = False

;  res@cnLevelSelectionMode = "ManualLevels"    ; manually set the contour levels with the following 3 resources
;  res@cnMinLevelValF  = -1000.0                        ; set the minimum contour level
;  res@cnMaxLevelValF  = 6000                   ; set the maximum contour level
;  res@cnLevelSpacingF = 200.0                  ; set the interval between contours

   res@mpCenterLonF = 180. 

;  res@mpMinLatF = -30.                   ; set the minimum latitude = -70.
;  res@mpMaxLatF = 30.                    ; set the maximum latitude = 70.

; res@mpMinLonF = -40.                    ; set the minimum latitude = -70.
;  res@mpMaxLonF = 40.

  nt = tointeger(ntime)
  

  plot = new(fcnt,graphic) 
  do k=0,fcnt-1
    print("plot "+k)

    time = fall[k]->time          ; Pull off lat/lon variable and
    print("Plotting time "+time(nt))

    lat1d = fall[k]->lat          ; Pull off lat/lon variable and
    lon1d = fall[k]->lon          ; convert both to 1D.    
    if (latlon.eq."True") then
      if (threeD.eq."True") then
        var   = fall[k]->$vname$(nt,tointeger(ilev),:,:)    ; Read some data; convert to 1D.
      else
        var   = fall[k]->$vname$(nt,:,:)    ; Read some data; convert to 1D.        
      end if
    else
      if (threeD.eq."True") then    
        var  = fall[k]->$vname$(nt,tointeger(ilev),:)    ; Read some data; convert to 1D.i
      else
        var  = fall[k]->$vname$(nt,:)    ; Read some data; convert to 1D.i          
      end if
    end if
    if (threeD.eq."True") then    
      res@tiMainString        = "level "+ilev+ " day "+time(nt)
    else
      res@tiMainString        = "Day "+time(nt)    
    end if
    if (latlon.eq."True") then
    else
      res@sfXArray            = lon1d        ; Required to tell NCL where to
      res@sfYArray            = lat1d        ; overlay data on globe.
    end if  

    if (vname.eq."PRECT") then
      var = 1000*24*3600*var ;convert from m/s to mm/day  
      res@cnLevelSelectionMode = "ManualLevels"
      res@cnMinLevelValF  = 0.0
      res@cnMaxLevelValF  = 24.0               
      res@cnLevelSpacingF = 2.0              
      res@gsnRightString = "mm/day"
    end if

    if (vname.eq."TT_SLOT_SUM") then
      res@cnLevelSelectionMode = "ManualLevels"
      res@cnMinLevelValF  = 0.92
      res@cnMaxLevelValF  = 1.08
      res@cnLevelSpacingF = 0.01
    end if

    if (vname.eq."iCLy") then
       res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
;      res@cnLevels    = (/3E-6,3.7E-6,3.8E-7,3.90E-6,3.91E-6,3.92E-6,3.93E-6,3.94E-6,3.95E-6,3.96E-6,3.97E-6,3.98E-6,3.99E-6,4.01E-6,4.02E-6,4.03E-6,4.04E-6,4.05E-6,4.06E-6,4.07E-6,4.08E-6,4.09E-6,4.1E-6,4.2E-6,4.3E-6,5E-6/)
      res@cnLevels    = (/3.90E-6,3.91E-6,3.92E-6,3.93E-6,3.94E-6,3.95E-6,3.96E-6,3.97E-6,3.98E-6,3.99E-6,4.01E-6,4.02E-6,4.03E-6,4.04E-6,4.05E-6,4.06E-6,4.07E-6,4.08E-6,4.09E-6,4.1E-6/)        
;      res@cnLevelSelectionMode = "ManualLevels"
;      res@cnMinLevelValF  = 3.91E-6
;      res@cnMaxLevelValF  = 4.11E-6               
;      res@cnLevelSpacingF = 0.1E-8
;      res@gsnRightString = "Column integrated CLy"
    end if

    plot(k) = gsn_csm_contour_map_ce(wks,var,res)
    delete(res)
    delete(time)
    delete(lon1d)
    delete(lat1d)
    delete(var)
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

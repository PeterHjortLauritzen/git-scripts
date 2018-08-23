load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;************************************************
begin
  fname =  "dmdt.nc"
  fall  = addfile(fname,"r")       ; Open netCDF files.	

  dmdt_dyn    = fall->dmdt_dyn
  dmrdt_dyn   = fall->dmrdt_dyn
  dmodt_dyn   = fall->dmodt_dyn
  dmdt_phys   = fall->dmdt_phys
  dmrdt_phys  = fall->dmrdt_phys
  dmodt_phys  = fall->dmodt_phys
  mo          = fall->mo
  mr          = fall->mr
  time        = fall->time

  plot=new(9,graphic)

  wks   = gsn_open_wks ("pdf","aam_plot")     ; open workstation

  res                  = True                     ; plot mods desired
  res@gsnDraw          = False        ; do not draw picture
  res@gsnFrame         = False        ; do not advance frame

  res@tiXAxisString  = " "
  res@xyLineColors = (/"blue","red","green","blue","red","green"/)  ; 3 different colors 
  res@xyDashPatterns = (/0,0,0,2,2,2/)

  res@trYMinF  =  -7.0 ;1.037E28                 ; min value on y-axis
  res@trYMaxF  =   7.0
  res@tiMainFontHeightF = 0.04                   ; max value on y-axis
  res@tiMainString     = "Total torque dynamics"
  res@tiYAxisString    = "~F1~(dM/dt)~B~dyn~N~~F1~ [10~S~19~N~ kg m ~S~2~N~ s~S~-2~N~]"
  plot(3)  = gsn_csm_xy (wks,time,dmdt_dyn/1.0E19,res) ; create plot

  res2 = True
  res2@gsnFrame  = False
  res2@gsnDraw   = False        ; do not draw picture
  res2@vpXF      = 0.18
  res2@vpYF      = 0.46;46 ;6 phl 
  res2@vpWidthF  = 0.15
  res2@vpHeightF = 0.1
  res2@xyLineColors = (/"blue","red","green","blue","red","green"/)  ; 3 different colors 
  res2@xyDashPatterns = (/0,0,0,2,2,2/)
  res2@tiYAxisString    = "[10~S~17~N~ kg m ~S~2~N~ s~S~-2~N~]"
  res2@tiXAxisString = ""
  res2@tmXBLabelsOn = False
  plotOverlay = gsn_csm_xy(wks,time,dmdt_dyn/1.0E17,res2)
  draw(plotOverlay)

  res@trYMinF  =  -7.0 ;1.037E28                 ; min value on y-axis
  res@trYMaxF  =   7.0                   ; max value on y-axiss   
  res@tiMainString     = "Wind torque dynamics"
  res@tiYAxisString    = "~F1~(dM~B~r~N~~F1~/dt)~B~dyn~N~~F1~ [10~S~19~N~ kg m ~S~2~N~ s~S~-2~N~]"
  plot(4)  = gsn_csm_xy (wks,time,dmrdt_dyn/1.0E19,res) ; create plot
   
  res@tiMainString     = "Mass torque dynamics"
  res@tiYAxisString    = "~F1~(dM~B~~F8~W~N~~F1~/dt)~B~dyn~N~~F1~ [10~S~19~N~ kg m ~S~2~N~ s~S~-2~N~]"
  res@trYMinF  =  -7.0 ;1.037E28                 ; min value on y-axis
  res@trYMaxF  =   7.0                   ; max value on y-axiss   
  plot(5)  = gsn_csm_xy (wks,time,dmodt_dyn/1.0E19,res) ; create plot

  res@vpXF      = 0.2
  res@vpYF      = 0.8
  res@vpWidthF  = 0.6
  res@vpWidthF  = 0.6

  res@trYMinF  =  -7.0;
  res@trYMaxF  =   7.0;
  res@tiMainString     = "Total torque physics" 
  res@tiYAxisString    = "~F1~(dM~B~~F8~W~N~~F1~/dt)~B~phys~N~~F1~ [10~S~19~N~ kg m ~S~2~N~ s~S~-2~N~]"
  res@tiXAxisString  = "Time [days]"
  plot(6)  = gsn_csm_xy (wks,time,dmdt_phys/1.0E19,res) ; create plot
  res@tiMainString     = "Wind torque physics"
  res@tiYAxisString    = "~F1~(dM~B~r~N~~F1~/dt)~B~phys~N~~F1~ [10~S~19~N~ kg m ~S~2~N~ s~S~-2~N~]"
  plot(7)  = gsn_csm_xy (wks,time,dmrdt_phys/1.0E19,res) ; create plot
  res@tiMainString     = "Mass torque physics"
  res@tiYAxisString    = "~F1~(dM~B~~F8~W~N~~F1~/dt)~B~phys~N~~F1~ [10~S~19~N~ kg m ~S~2~N~ s~S~-2~N~]"
  plot(8)  = gsn_csm_xy (wks,time,dmodt_phys/1.0E19,res) ; create plot

  res@tiXAxisString  = " "
  res@tiMainString     = "Total AAM"
  res@tiYAxisString    = "~F1~(M~B~~F8~W~N~~F1~) [10~S~25~N~ kg m ~S~2~N~ s~S~-1~N~]"
  res@trYMinF  =  tofloat(min(mo+mr)/1.0D25)-1.0
  res@trYMaxF  =  tofloat(max(mo+mr)/1.0D25)+1.0
  plot(0)  = gsn_csm_xy (wks,time,(mo+mr)/1.0E25,res) ; create plot
  res@tiMainString     = "Wind AAM dynamics"
  res@trYMinF  =  tofloat(min(mr)/1.0D25)-1.0
  res@trYMaxF  =  tofloat(max(mr)/1.0D25)+1.0
  plot(1)  = gsn_csm_xy (wks,time,(mr)/1.0E25,res) ; create plot
  res@tiMainString     = "Mass AAM dynamics"
  res@trYMinF  =  tofloat(min(mo)/1.0D25)-1.0
  res@trYMaxF  =  tofloat(max(mo)/1.0D25)+1.0
  plot(2)  = gsn_csm_xy (wks,time,(mo)/1.0E25,res) ; create plot


   resP                 = True
  resP@gsnPanelYWhiteSpacePercent = 2
;  resP@gsnPanelXWhiteSpacePercent = 3
  resP@txString         = "Dynamical core Axial Angular Momentum (AAM) diagnostics for CAM-SE"

  resP@gsnMaximize        = True                   ; use full page

; ---------- create tiny meta data in ndc coordinates ---------------------;
; ----The following section could be replaced by the "infoTimeStamp"-------;
; --------------function which resides in "shea_util.ncl"------------------;
;  infoTimeStamp (wks, 0.010,"NCAR data source; fspj01s & fspj02 ('97)") 
; This long way is included to illustrate how to use "gsn_text_ndc"--------;

   txres               = True         ; additional info
   txres@txFontHeightF = 0.010        ; size of meta data
   txres@txJust        = "CenterLeft"
   txres@txAngleF = 90.0
   TimeStamp           = systemfunc( "date" )
   gsn_text_ndc  (wks,"Plot produced by Peter Hjort Lauritzen (pel@ucar.edu), National Center for Atmospheric Research (NCAR), on "+TimeStamp \
                     ,0.99 , 0.02, txres)
                                       ; note when plotted

   txres@txJust        = "CenterRight"

   gsn_text_ndc  (wks,"Created: "+TimeStamp,0.01,0.3, txres)




   gsn_panel(wks,plot(:),(/3,3/),resP)


end

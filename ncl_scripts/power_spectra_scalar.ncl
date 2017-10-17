
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
  dir = "./"

;  all_files = (/"fv_0.9x1.25_nc3000_Nsw042_Nrs008_Co060_Fi001_ZR_160505.nc","/fs/cgd/csm/inputdata/atm/cam/topo/fv_0.9x1.25-gmted2010_modis-cam_fv_smooth-intermediate_ncube3000-no_anisoSGH_c151029.nc","ne30.nc","ne30_interp_method0.nc","ne30_cam5.nc"/)
;  flegend = (/"CAM6 topo (f09)","CAM5 topo (f09)","CAM6 topo (ne30)","CAM6 topo (ne30); interp_method0","CAM5 topo (ne30)"/)
;  fcnt=4

;  all_files = (/"/fs/cgd/csm/inputdata/atm/cam/topo/fv_0.9x1.25-gmted2010_modis-cam_fv_smooth-intermediate_ncube3000-no_aniso;SGH_c151029.nc","fv_0.9x1.25_nc3000_Nsw042_Nrs008_Co060_Fi001_ZR_160505.nc","/project/amp/pel/release/topo/fv-c30_nc3000_Co03;0_Fi001_MulG_PF_nullRR_Nsw021_20170620.nc"/)
;  flegend = (/"CAM6 (C30 smoothing)","CAM5 (f09)","CAM6 (f09)"/)


   all_files = (/fname/)
   flegend = (/fname/)

   fall      = addfiles (all_files, "r")   ; note the "s" of addfile

   print(all_files)

   fcnt    = dimsizes(fall)
   print("fcnt="+fcnt)


   res          = True
   res@xyXStyle = "Log"
   res@xyYStyle = "Log"
   res@tmXBMinorPerMajor = 8   
   res@tmXTMinorPerMajor = 8   
   res@tmYRMinorPerMajor = 8   
   res@tmYLMinorPerMajor = 8   
  
   res@tiMainString      = "Elevation power spectra"
   res@tiXAxisString     = "Spherical wavenumber k"
   res@tiYAxisString     = "Compensated energy (E*k^2)"
   res@gsnFrame          = False
;  res@xyLineThicknessF  = 2.0
   


  colors = (/"DarkGreen","Orange","Blue","Green","Red",             \
  "DarkTurquoise","Black",          \
  "gold","greenyellow","GoldenRod","DarkGoldenRod1",  \
  "lightgoldenrod1","lightyellow","lightgoldenrodyellow","khaki1"/)

  lthick = (/3.0,3.0,3.0,6.0,3.0,3.0,6.0,3.0/) 
                           ; create custom color map
   ymin = 1e2
   ymax = 1e7       


     res@trXMinF = 1       
     res@trXMaxF = 600       
     res@trYMinF = ymin 
     res@trYMaxF = ymax  

     res@xyDashPattern = 0
   
     xref    = (/15.,300./)
     spc_ref = 5*(xref/15)^(-3) ; make it 6 @ k=15
     
     polyres                  = True
;     polyres@gsLineThicknessF = lthick(ff)
     polyres@gsLineColor      = "black"
  ;
  ; done plot stuff 
  ;

   ;
   ; to compute "climatology"
   ;

  wks        = gsn_open_wks("pdf","power_topo.pdf")

  g = 9.80665
  ypos=10000 ; legend position

  res@xyLineThicknessF  = 2.0
  do ff=0,fcnt-1
     print("Processing "+ff)
     var_in   = fall[ff]->PHIS(:,:)
     removek=1;140
     print("Diving by g")
     var_in = var_in/g
     power  = wave_number_spc (var_in, "F") ;
     nlat   = dimsizes(power)-1
     print("nlat="+nlat)
     k      = ispan(0,nlat,1)*1.0+1.0
     k!0    = "k"
     power  = power*k^(2.)
     res@xyLineColors  = (/colors(ff),colors(ff)/) 
     polyres@xyLineThicknesses = 2.0
     polyres@gsLineColor = res@xyLineColors(0)
     plot    = gsn_csm_xy (wks,k(1:nlat-removek),power(1:nlat-removek),res) ; create plot    
     polytext = True
     polytext@txFontHeightF      = 0.020                 ; change text size
     polytext@txJust             = "CenterLeft"          ; text justification
     ypos = ypos/2
     polytext@txFontHeightF      = 0.020                 ; change text size
     gsn_text(wks    ,plot,flegend(ff),3,ypos,polytext); add text
     legend_x = (/1.5,2.5/) 
     legend_y = (/ypos,ypos/)
     polyres@gsLineThicknessF = 3.0
     gsn_polyline(wks,plot,legend_x,legend_y,polyres)              ; add polyline
     delete(nlat)
     delete(power)
     delete(k)
     delete(var_in)
  end do
  circumference = 40074.275;

  hundred_km_wavenumber = circumference/(200.0)
  xx = (/hundred_km_wavenumber,hundred_km_wavenumber/)
  yy = (/ymin,ymax/)
  polyres@gsLineThicknessF = 4
  polyres@gsLineColor = "gray75" ;res@xyLineColors(0)
  gsn_polyline(wks,plot,xx,yy,polyres)              ; add polyline

  txres               = True                            
  txres@txFontHeightF = 0.017
  xcoord = hundred_km_wavenumber + 110.0
  ycoord = ymax - 2980000.0
  text = gsn_add_text(wks,plot,"200km",xcoord,ycoord ,txres)

  eighthundred_km_wavenumber = circumference/(800.0)
  xx = (/eighthundred_km_wavenumber,eighthundred_km_wavenumber/)
  yy = (/ymin,ymax/)
  polyres@gsLineThicknessF = 4
  polyres@gsLineColor = "gray75" ;res@xyLineColors(0)
  gsn_polyline(wks,plot,xx,yy,polyres)              ; add polyline

  txres               = True                            
  txres@txFontHeightF = 0.017
  xcoord = eighthundred_km_wavenumber + 27.0
  ycoord = ymax - 2980000.0
  text = gsn_add_text(wks,plot,"800km",xcoord,ycoord ,txres)
                                        
  draw(plot)
  frame(wks)
end






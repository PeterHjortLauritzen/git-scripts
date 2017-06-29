load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;
;  read spectra.nc  (computed from history output with ke.ncl)
;  plot from spectra.nc with ke2.ncl
;

begin
  if (ls_option) then
    fnames = systemfunc ("ls *.nc")
    print(fnames)
    xi = ispan(0,dimsizes(fnames)-1,1)
    print(xi)
    legends=fnames
  else
    print("dir ="+dir)
    print("case="+case)
    fnames =  (/dir+"/"+case+".tke_250hPa.nc"/)
    print("fnames="+fnames)
    xi=(/0/)
    legends=(/case/)
  end if
  lcompensated = False
  ltsu = True

  titletxt = "CESM2.0 CAM3 APE"

  avespc   = addfiles(fnames,"r")       ; Open netCDF files.	
  print("fnames = "+fnames)
  output_format = "pdf"
  out_fname = "tke"

  ntime=avespc[0]->ntime
  print("Number of time samples in average: "+ntime)

  if (lcompensated) then
    out_fname=out_fname+"_compensated"
  end if
  wks = gsn_open_wks(output_format,out_fname)

  fcnt = dimsizes(xi)
  print(fcnt)
  nlat=dimsizes(avespc[0]->spc_avg);
  print(nlat)
  cut = 120
  cutoff = nlat-cut
 print("cut-off"+cutoff)

spc =   new ( (/fcnt,cutoff/), "double")
spc = spc@_FillValue
x   = new ( (/fcnt,cutoff/), "double")
x = x@_FillValue
spc = 0.0
do i=0,fcnt-1
   fk=xi(i)
   x(i,:) = avespc[fk]->x_avg(0:cutoff-1)
   spc(i,:)=avespc[fk]->spc_avg(0:cutoff-1)
   if (lcompensated) then
     spc(i,:) = spc(i,:)*(x(i,:)^(3.))
   end if
end do




  do fk=0,fcnt-1

     tmax=nlat
    ; dont plot wave numbers above tmax
    do i=tmax,nlat-1
       spc(fk,i)=spc@_FillValue
    end do         
  end do  

  athick=4
  lthick=4

  res=True
  ;res@gsLineThicknessF = 3.0
  res@xyXStyle ="Log"
  res@xyYStyle ="Log"
  res@tmXBMinorPerMajor = 8   
  res@tmXTMinorPerMajor = 8   
  res@tmYRMinorPerMajor = 8   
  res@tmYLMinorPerMajor = 8   
  res@tmXMajorGridThicknessF = athick
  res@tmYLLabelFont = 21    ;  21 = helvetica
  res@tmXBLabelFont = 21    ;  22 = helvetica-bold 

  res@tmXBMajorThicknessF = athick
  res@tmYLMajorThicknessF = athick
  res@tmXBMinorThicknessF = athick 
  res@tmYLMinorThicknessF = athick 
  res@tmBorderThicknessF = athick
  res@tiMainString           = "Average of "+ntime+" instantaneous 250mb (u,v)"
;  res@tiMainString           = "Average of 200 six-hourly instantaneous 250mb (u,v)"
  res@tiXAxisString          = "Spherical Wavenumber k"
  if (lcompensated) then
    res@tiYAxisString          = "Compensated Total Kinetic Energy E(k)*k^3"
  else
    res@tiYAxisString          = "Total Kinetic Energy E(k)"
  end if
  res@gsnFrame = False
  res@xyLineThicknessF = lthick

  colors = (/"white","black","OrangeRed4","Red3",\
"red1","Red3","Red4","Blue","green",\
"OrangeRed1","OrangeRed2","OrangeRed3","OrangeRed4","DarkOrange",\
"red1","red2","red3","red4",\
"DarkTurquoise","Turquoise","Cyan","blue",\
"gold","greenyellow",\
"GoldenRod","DarkGoldenRod1","lightgoldenrod1","lightyellow","lightgoldenrodyellow","khaki1"\
/)
  gsn_define_colormap(wks, colors)

  res@xyLineColors = (/"blue","green","DarkGoldenRod1","red3","DarkTurquoise","OrangeRed4","black"/)
;  res@xyDashPatterns = (/0,1,0,1,0,1,0,1/)
  res@xyDashPattern = 0

  res@trXMinF = 1       
  res@trXMaxF = 500       
;  res@trXMaxF = 2500       
  if (lcompensated) then
    res@trYMinF = 1e1      
    res@trYMaxF = 1e6   	
  else
    res@trYMinF = 1e-6      
    res@trYMaxF = 1e4   
  end if

  plot  = gsn_xy (wks,x(:,1:cutoff-1),spc(:,1:cutoff-1),res) ; create plot
  
  xref = (/10.,300./)
  if (lcompensated)
    spc_ref = (/60000.,60000./)
  else
    spc_ref = 50*(xref/10)^(-3) ; make it 6 @ k=15
;    spc_ref = 50*(xref/10)^(-5./3.) ; make it 6 @ k=15
  end if
  polyres                  = True
  polyres@gsLineThicknessF = 2.0
  polyres@gsLineColor = "black"
  gsn_polyline(wks,plot,xref,spc_ref,polyres)              ; add polyline


  polytext = True
  polytext@txFontHeightF      = 0.02                 ; change text size
  polytext@txJust             = "CenterLeft"          ; text justification

  if (lcompensated) then
    gsn_text(wks,plot,"k^-3",30.,90000.,polytext); add text
  else
    gsn_text(wks,plot,"k^-3",80.,1.0,polytext); add text
  end if

  if (lcompensated) then
    xpos = 90.3
    ypos = 200.0
  else
    xpos = 1.3
    ypos=0.01  
  end if

;
  do fk=0,fcnt-1
    if (lcompensated) then
      xx = (/50,70/)
      ypos = ypos/1.8
    else
      xx = (/6,18/)
      ypos = ypos/3
    end if
;    xx = (/1,10/)

    yy = (/ypos,ypos/)
    polyres@gsLineThicknessF = lthick
    polyres@gsLineColor = res@xyLineColors(fk)
    gsn_polyline(wks,plot,xx,yy,polyres)              ; add polyline
    gsn_text(wks,plot,legends(fk),xpos,ypos,polytext); add text
    print(fk+" legend = "+legends(fk))
  end do 
  polytext@txJust             = "BottomCenter"          ; text justification
  if (ltsu) then
    gsn_text_ndc(wks, titletxt,.5,.805,polytext); add text
  else
    gsn_text_ndc(wks,titletxt,.5,.805,polytext); add text
  end if

  frame(wks)                                     ; now advance


;  do n1=0,tmax-1
;    spc(:,n1) = spc(:,n1)*(n1^3)
;  end do
;  res@tiYAxisString          = ":F21:Compensated Kinetic Energy"
;  res@trYMinF = 1e3
;;  res@trYMinF = 1e1
;  res@trYMaxF = 2e5   
;  plot  = gsn_xy (wks,x,spc,res) ; create plot
;  xref = (/10.,300./)
;  spc_ref = (xref^3)*100*(xref/10)^(-3) ; make it 6 @ k=15
;  polyres@gsLineThicknessF = 2.0
;  polyres@gsLineColor = "black"
;  gsn_polyline(wks,plot,xref,spc_ref,polyres)              ; add polyline
;  frame(wks)                                     ; now advance 


end

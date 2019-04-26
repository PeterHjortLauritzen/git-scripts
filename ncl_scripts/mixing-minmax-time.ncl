;**************************************
;
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************
undef ("chg_filename_to_string")
function chg_filename_to_string(str)
local r
begin
  cslam = str_match(str,"ne30pg3")
  se    = str_match(str,"ne30")
  fv    = str_match(str,"f09")
  fv3   = str_match(str,"C96")      

  if (.not.ismissing(cslam)) then
    str_out = "CAM-SE-CSLAM"
  elseif (.not.ismissing(se)) then
    str_out = "CAM-SE"
  elseif (.not.ismissing(fv)) then
    str_out = "CAM-FV"
  elseif (.not.ismissing(fv3)) then
    str_out = "CAM-FV3 hydrost."
  else
    str_out = str
  end if
  return (str_out)
end 


begin
  vname = (/"min1_val","max1_val","min2_val","max2_val"/)


  fils = systemfunc ("ls *.nc") ; file paths
  print("fils="+fils)
  f    = addfiles (fils, "r") 
  num_files = dimsizes(fils)
  print("num_files = "+num_files)


  str1 = (/"Min tracer 1","Max tracer 1","Min tracer 2","Max tracer 2"/)
  out_fname = "mixing_minmax_norms"
  ;
  ; good range for day 0-15
  ;
;  maxDay = 10.0
;  minY=(/0.0,0.0,0.0/)
;  maxY=(/0.01,0.001,0.001/)  
  ;
  ; good range for day 0-8
  ;
  maxDay = 10.0
  minY=(/0.081,0.95,0.09,0.892/)
  maxY=(/0.102,1.01,0.24,0.9/);
  ;
  ; good range for day 0-4
  ;
;  maxDay = 4  
;  minY=(/0.0,0.0,0.0/)
;  maxY=(/0.0001,0.00001,0.000005/)



  wks   = gsn_open_wks ("pdf",out_fname)
  plot = new(4,graphic)
  dum2 = new(10*num_files+1,graphic)
  colors  = (/"blue","red","green","black"/) ; 3 different colors    
  ;
  ; setup plot details
  ;
  res_lines                  = True
  res_lines@gsLineThicknessF = 6.0

  res                   = True                     ; plot mods desired
;  res@gsnMaximize       = True                     ; maximize plot
  res@gsnDraw           = False           ; don't draw
  res@gsnFrame          = False
  res@xyLineThicknesses = 6.0
  res@tmYLFormat = "0*+^e"
  res@tiMainFontHeightF = 0.06
  res@tmXBLabelFontHeightF = 0.04                 ; resize tick labels
  res@tmYLLabelFontHeightF = 0.04
  res@tiXAxisFontHeightF = 0.05
  res@tiXAxisString     = "time [days]"
  
  txres               = True
  txres@txFontHeightF = 0.04
  txres@txJust        = "CenterLeft"
  do pl=0,3
    k=0  
    res@xyLineColor      = colors(k)

    res@tiMainString     = str1(pl)
  
    res@trYMinF          = minY(pl)
    res@trYMaxF          = maxY(pl)

    res@trXMinF          = 0.0
    res@trXMaxF          = maxDay

    vn = vname(pl)
    l_error = f[0]->$vn$
    time    = f[0]->time

    plot(pl)  = gsn_csm_xy (wks,time,l_error,res)                    ; create plot

    txres@txFontColor  = colors(k)

    if (pl.eq.0) then
      ;
      ; for text location
      ;
      txtY_start = minY(pl)+(maxY(pl)-minY(pl))/1.6
      txtY_intvl = (maxY(pl)-minY(pl))/10.0   ;
      print("xx"+txtY_start)
      dum = gsn_add_text(wks,plot(pl),chg_filename_to_string(fils(k)),0.5,txtY_start,txres)
    end if      
    do k=1,num_files-1
      delete(time)
      delete(l_error)
      l_error = f[k]->$vname(pl)$
      time    = f[k]->time
      res_lines@gsLineColor = colors(k)
      if (pl.eq.0) then
        txres@txFontColor  = colors(k)
        dum = gsn_add_text(wks,plot(pl),chg_filename_to_string(fils(k)),0.5,txtY_start+k*txtY_intvl,txres)
      end if
      print(k+pl*(num_files-1))
      dum2(k+pl*(num_files-1))=gsn_add_polyline(wks,plot(pl),time,l_error,res_lines)      
    end do
    delete(time)
    delete(l_error)
  end do



  resP=True
  resP@gsnPanelMainString = "Correlated Cosine Bells identical in all levels - results for level 13"  
  gsn_panel(wks,plot,(/2,2/),resP)    
  draw(plot)
  frame(wks)
end
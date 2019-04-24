;**************************************
;
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************

undef ("get_area_FV_from_lat_lon")
function get_area_FV_from_lat_lon(lat_in,lon_in)
local area,deg2rad,pi,i,j,lat,lon,nlat,nlon,dlon,dlat,lat_edge,dslat,dlat_local
begin
 pi=3.14159265358979D0
 deg2rad = pi/180.0D0
 nlat = dimsizes(lat_in)
 nlon = dimsizes(lon_in)
 if (max(lon_in).ge.6.0D0) then
   lon = lon_in*deg2rad
   lat = lat_in*deg2rad   
 end if
 dlon = lon(2)-lon(1)
 area = new((/dimsizes(lat),dimsizes(lon)/),(/typeof(lon),typeof(lon)/))
 dlon = lon(2)-lon(1)
 dlat = lat(2)-lat(1) 
 do j=0,nlat-1
   if (j.eq.0) then
     lat_edge = lat(0)
     dlat_local = 0.5D0*dlat      
   elseif (j.eq.nlat-1) then
     dlat_local = 0.5D0*dlat
     lat_edge = lat(nlat-2)+dlat_local
   else
     lat_edge = 0.5D0*(lat(j)+lat(j-1))
     dlat_local = dlat
   end if
   dslat = sin(lat_edge+dlat_local)-sin(lat_edge)
   do i=0,nlon-1
     area(j,i) = dlon*dslat
   end do
 end do
 return (area)
end 

undef ("total_area")
function total_area(area)
local out,i,j
begin
 if (dimsizes(dimsizes(area)).eq.1) then
   out = sum(area)
 elseif (dimsizes(dimsizes(area)).eq.2) then
   out = 0.0D0
   do j=0,dimsizes(area(1,:))-1
     do i=0,dimsizes(area(:,1))-1
       out = out+area(i,j)
     end do
   end do
 else
   print("not supported")
   exit
 end if
 return (out)
end 

undef ("corr_fct")
function corr_fct(x)
local corr
begin
  corr = -0.8*x*x+0.9
  return(corr)
end  

;
; check that area spans unit sphere
;
undef ("check_total_area")
function check_total_area(area)
local error,pi,out
begin
  pi=3.14159265358979D0
  error = abs((total_area(area)-4.0*pi)/(4.0*pi))
  if (error.gt.1.0D-7) then
    print("Sum of area's does not equal 4*pi: relative error= "+error+"; sum of areas = "+total_area(area))
    out = True
  else
    print("Area spans unit sphere "+error)
    out = False
  end if
  return(out)
end  

undef ("lf")
function lf(fld,area,threshold)
local out,i,j,k,nx,ny,nz
begin
  pi=3.14159265358979D0
  out = 0.0D0
  ;
  ;
  ; 2D data
  ;
  if (dimsizes(dimsizes(fld)).eq.2) then
    nz = dimsizes(fld(:,1)) ; level
    nx = dimsizes(fld(1,:)) ; ncol
    do j=0,nz-1
      do i=0,nx-1
        if (fld(j,i).ge.threshold) then
          out = out+area(i)
        end if
      end do
    end do
    out=out/nz
  ;
  ;
  ; 3D data
  ;
   elseif (dimsizes(dimsizes(fld)).eq.3) then
    nx = dimsizes(fld(:,1,1));lon
    ny = dimsizes(fld(1,:,1));lat
    nz = dimsizes(fld(1,1,:));k
    do k=0,ny-1   
      do j=0,ny-1
        do i=0,nx-1
          if (fld(i,j,k).ge.threshold) then
            out = out+area(i,j)
          end if
        end do
      end do  
    end do   
  else
    print("not supported")
    out = -1
    exit
  end if
  out=out/(4.0D0*pi)
  return (out)
end 

begin
;****************************************
  
  print("fname = "+fname)
  ffname = systemfunc("ls "+fname)
  f  = addfile (ffname,"r") 

  print("grabbing ..."+vname1+" and "+vname2)

  var1 = f->$vname1$
  var2 = f->$vname2$

  if (vname1.eq."TT_COSB") then
    lo = f->TT_COSB_lo
    lr = f->TT_COSB_lr
    lu = f->TT_COSB_lu
  elseif (vname1.eq."TT_COSB2") then
    lo = f->TT_COSB2_lo
    lr = f->TT_COSB2_lr
    lu = f->TT_COSB2_lu
  else
    print("Mixing diagnostics variables not found on file")
    exit
  end if

  time = f->time

  print("nstep_start="+nstep_start)
  print("nstep_stop="+nstep_stop)  
  n1=tointeger(nstep_start)
  n2=tointeger(nstep_stop)
  if (n1.le.-1) then
    n1 = 0
    n2 = dimsizes(time)-1
  end if
  ;
  ; create file name and directories
  ;
  if (n2.gt.dimsizes(time)) then
    print("nstep_stop larger than time array size "+dimesizes(time))
    exit
  end if
  if (n1.eq.n2) then
    lani = False
    out_fname = "scatter_day"+time(n1)+"_"+vname1+"_"+resolution
    wks   = gsn_open_wks ("pdf",out_fname)           ; send graphics to PNG file    
  else
    print("Making png animation")
    lani = True
    dirname = "animation_frames"
    ret = systemfunc("test -d "+dirname+"; echo $?")
    if (ret.eq.1) then
      print("Creating directory "+dirname)
      system("mkdir "+dirname)
    else
      print("Directory "+dirname+" exists")
      print("Delete directory and rerun script!")
      exit
    end if
    out_fname = dirname+"/scatter_animation_"+vname1+"_"+resolution
    wks   = gsn_open_wks ("png",out_fname)           ; send graphics to PNG file
  end if

  ;
  ; setup plot details
  ;
  res                   = True                     ; plot mods desired
  res@gsnMaximize       = True                     ; maximize plot
  res@gsnFrame          = False
  res@xyMarkLineMode    = "Markers"                ; choose to use markers
  res@xyMarkers         =  16                      ; choose type of marker  
  res@xyMarkerColor     = "NavyBlue"               ; Marker color
  res@xyMarkerSizeF     = 0.002                     ; Marker size (default 0.01)

  res@tiXAxisString     = vname1
  res@tiYAxisString     = vname2

  res@trXMinF          = 0.0
  res@trXMaxF          = 1.05
  res@trYMinF          = 0.0
  res@trYMaxF          = 1.0  
  ;
  ; convex hull lines for plot
  ;
  npts   = 100
  xx  = 0.1+0.9*((1.0/npts)*ispan(1,npts,1))
  yy  = corr_fct(xx)

  res_lines = True
  res_lines@gsLineThicknessF = 6.0
  res_lines@gsLineColor      = "orange"

  xxx  = 1.0*ispan(1,2,1)
  xxx(0)  = 0.1
  xxx(1)  = 1.0  
  yyy  = corr_fct(xxx)

  res_lines2 = True
  res_lines2@gsLineThicknessF = 4.0
  res_lines2@gsLineColor      = "orange"
  ;
  ; for error norms printed on plot
  ;
  txres               = True
  txres@txFontHeightF = 0.03
  ;
  ; start time loop
  ;
  count=0
  do nt=n1,n2
    res@tiMainString      = "Day "+time(nt)+" with "+resolution           ; add title  
    if (latlon.eq."True") then
      var1_1d = ndtooned(var1(nt,19,:,:))
      var2_1d = ndtooned(var2(nt,19,:,:))
      lr_1d   = ndtooned(lr  (nt,19,:,:))
      lu_1d   = ndtooned(lu  (nt,19,:,:))
      lo_1d   = ndtooned(lo  (nt,19,:,:))

      lat = f->lat
      lon = f->lon

      area_2d = get_area_FV_from_lat_lon(lat,lon)
      area_1d = ndtooned(area_2d)

      ncol = dimsizes(var1_1d)
      scatter = new((/2,ncol/),typeof(var1_1d(1)))
      scatter(0,:) = var1_1d
      scatter(1,:) = var2_1d
    else
      var1_1d = ndtooned(var1(nt,19,:))
      var2_1d = ndtooned(var2(nt,19,:))
      lr_1d   = ndtooned(lr  (nt,19,:))
      lu_1d   = ndtooned(lu  (nt,19,:))
      lo_1d   = ndtooned(lo  (nt,19,:))    
      area_1d = f->area

      ncol = dimsizes(var1_1d)
      scatter = new((/2,ncol/),typeof(var1_1d(1)))
      scatter(0,:) = var1_1d
      scatter(1,:) = var2_1d   
    end if

    if (count.eq.0) then
      print("ncol="+ncol)
    
      lr_error   = new((/n2-n1+1/),typeof(lr_1d(1)))
      lo_error   = new((/n2-n1+1/),typeof(lr_1d(1)))
      lu_error   = new((/n2-n1+1/),typeof(lr_1d(1)))
      min1_val   = new((/n2-n1+1/),typeof(lr_1d(1)))
      min2_val   = new((/n2-n1+1/),typeof(lr_1d(1)))
      max1_val   = new((/n2-n1+1/),typeof(lr_1d(1)))      
      max2_val   = new((/n2-n1+1/),typeof(lr_1d(1)))
      if (check_total_area(area_1d)) then
        print("STOP")
        exit
      end if
      sum_area_inv = 1.0D0/sum(area_1d)      
    end if
    ;
    ; compute mixing diagnostics
    ;
    lr_error(count) = sum(area_1d*lr_1d)*sum_area_inv
    lo_error(count) = sum(area_1d*lo_1d)*sum_area_inv
    lu_error(count) = sum(area_1d*lu_1d)*sum_area_inv

    min1_val(count) = min(var1_1d)
    min2_val(count) = min(var2_1d)    
    max1_val(count) = max(var1_1d)
    max2_val(count) = max(var2_1d)    

    plot  = gsn_csm_xy (wks,scatter(0,:),scatter(1,:),res)                    ; create plot
    gsn_polyline(wks,plot,xx,yy,res_lines)
    p = gsn_add_polyline(wks,plot,xxx,yyy,res_lines2)

    str1 = "l~B~r~N~="+sprintf("%6.2e", lr_error(count)) 
    str2 = "l~B~u~N~="+sprintf("%6.2e", lu_error(count))
    str3 = "l~B~o~N~="+sprintf("%6.2e", lo_error(count))
    dum = gsn_add_text(wks,plot,str1,0.215,0.3,txres)
    dum = gsn_add_text(wks,plot,str2,0.217,0.2,txres)
    dum = gsn_add_text(wks,plot,str3,0.22,0.1,txres) 

    count=count+1

    print("Done time = "+time(nt))

    draw(plot)
    frame(wks)
 end do

 print(lr_error)
 print(lu_error)
 print(lo_error)
 print(min1_val)
 print(min2_val)	
 print(max1_val)
 print(max2_val)

 out_fname = "scatter_time"+"_"+vname1+"_"+resolution+".nc"
 system("/bin/rm -f "+out_fname)
 ncdf = addfile(out_fname ,"c")  ; open output netCDF file
 ncdf->lr_error=lr_error
 ncdf->lu_error=lu_error
 ncdf->lo_error=lo_error
 ncdf->min1_val=min1_val
 ncdf->min2_val=min2_val
 ncdf->max1_val=max1_val
 ncdf->max2_val=max2_val  
 ncdf->time=time(n1:n2)
 print("Converting png files into gif animation")
 out_fname = "scatter_time"+"_"+vname1+"_"+resolution+".gif"
 system("convert -delay 40 "+dirname+"/scatter_animation_* "+out_fname)
end
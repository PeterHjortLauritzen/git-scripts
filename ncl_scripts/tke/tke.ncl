script_name = "tke.ncl"

;**************************************************
;
; Compute total kinetic energy spectrum and output
; the data in netCDF file.
;
; This script is based on input from Mark Taylor 
; and Brian Medeiros.
;
; 
; June 2017
; Peter Hjort Lauritzen
; Climate and Global Dynamics Laboratory
; National Center for Atmospheric Research
; Boulder, Colorado
;
;**************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

function kespec(U, V,fname)
;; Returns average kinetic energy spectrum using spherical harmonics and writes the spectral coefficients to file fname.
;; assumes U and V are zonal and meridional wind components at a single level,
;; and that they have been put on a regular grid, i.e., (time, lat, lon)
local udims, udimsize, nlat, nlon, ntime, maxlat, spc_vdo, x, vr_eul, dv_eul, var, var2, ab_vro_eul, ab_dvo_eul, cr, ci, pwr_vro_eul, pwr_dvo_eul, pwr_size, re2, n1, factor, AvgSpc, debug
begin

  debug = False ;; turns off print statements if False
    
  ;; check on dimensions
  udims = getvardims( U )
  udimsize = dimsizes(U) ;; expects ( ntime, nlat, nlon ) ... time doesn't *have* to be time, could be different files or whatever.
  nlat = udimsize( ind(udims.eq."lat") )
  nlon = udimsize( ind(udims.eq."lon") )
  ntime = udimsize(0) ;; <--- could be fragile, but I don't want to insist on "time" if is "ncl_join" or something.
  ;; the number of waves depends on latitude and longitude sizes.
  if nlon%2 .eq. 0 then
    maxlat  = min( (/ nlat, (nlon+2)/2 /) )
  else
    maxlat = min( (/ nlat,  (nlon+1)/2 /) )
  end if
  ;; allocate the variables
  spc_vdo = new ( (/ntime,maxlat/), "double" )  ;; maxlat will be the number of spherical wavenumbers
  spc_vor = new ( (/ntime,maxlat/), "double" )  ;; maxlat will be the number of spherical wavenumbers
  spc_div = new ( (/ntime,maxlat/), "double" )  ;; maxlat will be the number of spherical wavenumbers
  x       = new (         maxlat  , "double" )  ;; This is the "X-axis" on the plot, "Spherical wavenumber"

  if debug then
    print( str_join( (/"ntime="+ntime, "nlat="+nlat, "nlon="+nlon, "MaxLat="+maxlat/), " ; ") )
  end if
    
  ;; derive vorticity and divergence from winds
  vr_eul = uv2vrF_Wrap (U, V) ; vorticity = zeta
  dv_eul = uv2dvF_Wrap (U, V) ; divergence = delta

  var  = vr_eul
  var2 = dv_eul
 ; print ("vr min/max = "+min(var(:,:))+", "+max(var(:,:)) )
 ; print ("dv min/max = "+min(var2(:,:))+", "+max(var2(:,:)) )

  print ("computing scalar spherical harmonic transform...")

  ab_vro_eul = shaeC (var) ; returns [2,ntime,nlat,~nlon/2]
  ab_dvo_eul = shaeC (var2) ;; Computes spherical harmonic analysis of a scalar field on a fixed grid via spherical harmonics.
  if debug then
    print ("done. ")
    printVarSummary(ab_vro_eul)
  end if
  ;
  ; compute energy in vort and div components, 
  ;
  cr          = ab_vro_eul(0,:,:,:)  ; real coef  (nlat,nlat) vort
  ci          = ab_vro_eul(1,:,:,:)  ; imaginary  (nlat,nlat) vort
  pwr_vro_eul = (cr^2 + ci^2)        ; (nlat,nlat)  array - POWER IN ROTATIONAL COMPONENT (?)
  cr          = ab_dvo_eul(0,:,:,:)  ; real coef  (nlat,nlat) div
  ci          = ab_dvo_eul(1,:,:,:)  ; imaginary  (nlat,nlat) div
  pwr_dvo_eul = (cr^2 + ci^2)        ; (nlat,nlat)  array - POWER IN DIVERGENT COMPONENT(?)
  if debug then
    printVarSummary( pwr_vro_eul ) ;; ACTUALLY nTIMExnLATxMAXLAT
                                   ;;            nt x N  x M
  end if
  pwr_size = dimsizes( pwr_vro_eul )
  
  re2 = 6371229.^2 ;; PLANETARY RADIUS IN METERS

  ;; for clarity use do loops
  do n1=0,maxlat-1 ;; loops over number of latitudes, which is actually spherical wavenumber, n.
    ;; [most people (Taylor, Jablonowski, Reed, etc) use this]    factor = (4. * n1*(n1+1)) ;; this comes from tech note, but is wrong:
    factor = (16. * n1*(n1+1)) ;; Williamson worked out that this is correct.

  ;    ;; ORIGINAL WAY - EVERYBODY DOES THIS:
  ;    spc_vdo(:,n1) = pwr_vro_eul(:,n1,0) + pwr_dvo_eul(:,n1,0)  ;; start with power at wavenumber zero / zeta^2(0) + delta^2(0)
  ;    do m=1,n1
  ;      spc_vdo(:,n1) = spc_vdo(:,n1) + 2.*(pwr_vro_eul(:,n1,m) + pwr_dvo_eul(:,n1,m)) ;; add 2xPowerAtWavenumber m
  ;    end do

    ;; VECTORIZE INNER LOOP, BUT SPECIAL CASES FIRST:
    ;; GIVES THE SAME ANSWER.
    spc_vdo(:,n1) = pwr_vro_eul(:,n1,0) + pwr_dvo_eul(:,n1,0)  ;; m = 0
    if n1.gt.0 then
      spc_vdo(:,n1) = spc_vdo(:,n1) + 2.*( dim_sum( pwr_vro_eul(:,n1,1:n1)) + dim_sum( pwr_dvo_eul(:,n1,1:n1)) )
    end if
    
    if (n1 .ne. 0) then
      spc_vdo(:,n1) = re2/factor * spc_vdo(:,n1)  ; scaling from NCAR/TN-388+STR
    end if
    x(n1) = n1
    ;
    ; Divergence
    ;
    spc_div(:,n1) = pwr_dvo_eul(:,n1,0)  ;; m = 0
    if n1.gt.0 then
      spc_div(:,n1) = spc_div(:,n1) + 2.*dim_sum(pwr_dvo_eul(:,n1,1:n1))
    end if
    
    if (n1 .ne. 0) then
      spc_div(:,n1) = re2/factor * spc_div(:,n1)  ; scaling from NCAR/TN-388+STR
    end if
    ;
    ; Vorticity
    ;
    spc_vor(:,n1) = pwr_vro_eul(:,n1,0) ;; m = 0
    if n1.gt.0 then
      spc_vor(:,n1) = spc_vor(:,n1) + 2.*dim_sum( pwr_vro_eul(:,n1,1:n1))
    end if
    
    if (n1 .ne. 0) then
      spc_vor(:,n1) = re2/factor * spc_vor(:,n1)  ; scaling from NCAR/TN-388+STR
    end if
  end do
  ;; OUTPUT ... FOR SIMPLEST CASE, WE REALLY ONLY NEED TO PLOT:
  ;; y-axis is average power: 
  AvgSpc = dim_avg_n(spc_vdo,0)
  ;; x-axis is spherical w


;; afterward:  xx = where( x.le.0, x@_FillValue, x )
  AvgSpc!0 = "wavenumber"
  AvgSpc&wavenumber = x

  ncdf     = addfile(fname ,"c")  ; open output netCDF file
  ; make time and UNLIMITED dimension      ; recommended  for most applications
  filedimdef(ncdf,"time",-1,True) 

  ;
  ; output variables directly
  ;
  ncdf->x_avg       = AvgSpc&wavenumber
  ncdf->spc_avg     = dim_avg_n(spc_vdo,0)
  ncdf->spc_avg_div = dim_avg_n(spc_div,0)
  ncdf->spc_avg_rot = dim_avg_n(spc_vor,0)
  ncdf->ntime=ntime
  return(AvgSpc)
end

begin
;++++++++++++++++++++++++++++++++++++++++++++++++
; user-specified variables
;++++++++++++++++++++++++++++++++++++++++++++++++

;  dir = "./"
;  fname = case+"/"+case+".nc"
;  all_files = (/fname/)

  ls_command = "ls "+dir+"/"+case+".cam."+h_number+".*.nc"
  all_files = systemfunc (ls_command)
  print(all_files)

  fall      = addfiles (all_files, "r")   ; note the "s" of addfile

  ListSetType (fall, "cat")             ; concatenate or "merge" (default)

  firsttime = 0
  lasttime  = dimsizes(fall[:]->time)-1
  print("Total number of time samples "+lasttime)

  plvl    =  200.0                ; default  [hPa] 
;  plvl    =  10.0                ; default  [hPa] 

  timeinc   = 1
  cut =1 ;how many wavelengths are cut off

;++++++++++++++++++++++++++++++++++++++++++++++++
; End user=specified variables
;++++++++++++++++++++++++++++++++++++++++++++++++
  
;************************************************
; read in netCDF file
;************************************************

  uplev   = fall[:]->U(firsttime:lasttime,0,:,:)
  vplev   = fall[:]->V(firsttime:lasttime,0,:,:)
  pplev   = vplev(firsttime,:,:)
  pplev = 100000.0
  ;
  ; map to pressure level
  ;
  interp = 2    ; type of interpolation: 1 = linear, 2 = log, 3 = loglog
  extrap = True  ; is extrapolation desired if data is outside the range of PS
  P0mb   = 1000. ; yes, this argument must be in mb     

  do time=firsttime,lasttime,timeinc   
    print ("interpolating time "+time)
    nps = time

    u   = fall[:]->U(nps,:,:,:)
    v   = fall[:]->V(nps,:,:,:)

;    ps  = fall[:]->PS(nps,:,:)
    ps = pplev
    ps@units = "Pa"

    if (.not.(ps@units.eq."Pa" .or. ps@units.eq."Pascals") ) then
      print("converting ps to Pascals")
      ps       = ps*100
      ps@units ="Pa"
    end if

    hyam = fall[0]->hyam
    hybm = fall[0]->hybm

    pnew   = (/ plvl /)  ; interpolate to plvl hPa
     
    U  = vinth2p(u,hyam,hybm,pnew,ps,interp,P0mb,1,extrap)
    V  = vinth2p(v,hyam,hybm,pnew,ps,interp,P0mb,1,extrap)

    uplev(nps,:,:) = U
    vplev(nps,:,:) = V
  end do  ; loop over time level
  fname = dir+"/"+case+".tke_"+plvl+"hPa.nc"
  spc_avg_mad = kespec(uplev, vplev, fname)
;;   system("rm -f tmp/*.nc")   ; remove any pre-existing file

end

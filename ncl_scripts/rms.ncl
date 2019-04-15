;**************************************
;
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************

begin
;   out = 

  
  print(fname)
  print("xx"+fname)
  ffname = systemfunc("ls "+fname)
;  
  print("addfile "+ffname)
  f  = addfile (ffname,"r") 
;
;
  time = f->time
  v1 = f->$vname1$
  v2 = f->$vname2$

  ntot = dimsizes(v1(:,1,1))



  do t=0,ntot-1
    var1 = ndtooned(v1(t,:,:))    
    var2 = ndtooned(v2(t,:,:))    
    rms  = dim_rmsd(var1,var2)
    print("Rms at time "+time(t)+" is "+rms)
  end do

  diff = v1(ntot-1,:,:)
  diff = v1(ntot-1,:,:)-v2(ntot-1,:,:)

  name = time(ntot-1)+".pdf"
  wks = gsn_open_wks("pdf",name)

  res              = True
  res@gsnMaximize  = True     ; maximize plot in frame
  res@cnFillOn     = True     ; turn on contour fill
  res@cnLinesOn    = False    ; turn off contour fill
  res@tiMainString = "Plotting rectilinear data"

  plot = gsn_csm_contour_map(wks,diff,res)

  res@mpProjection = "Robinson"
  plot = gsn_csm_contour_map(wks,diff,res)

end


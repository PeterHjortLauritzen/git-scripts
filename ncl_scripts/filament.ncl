;**************************************
;
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************

undef ("total_area")
function total_area(area)
local out,i,j
begin
 if (dimsizes(dimsizes(area)).eq.1) then
   out = sum(area)
 elseif (dimsizes(dimsizes(area)).eq.2) then
   out = 0.0
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

;
; check that area spans unit sphere
;
undef ("check_total_area")
function check_total_area(area)
local error,pi,out
begin
  pi=3.14159265358979D0
  error = abs((total_area(area)-4.0*pi)/(4.0*pi))
  if (error.gt.1.0E-7) then
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
  lf_threshold = (/0.1D0,0.2D0,0.3D0,0.4D0,0.5D0,0.6D0,0.7D0,0.8D0,0.9D0,1.0D0/) ;, 0.3D0/)
  
  print(fname)
  print("xx"+fname)
  ffname = systemfunc("ls "+fname)
;  
  print("addfile "+ffname)
  f  = addfile (ffname,"r") 
;
;
  area = f->area
  print(typeof(area))
  if (check_total_area(area)) then
    exit
  end if

  print("grabbing var..."+vname)
  var = f->$vname$
  

  lf_size      = dimsizes(lf_threshold)
  lf_ref_vals  = new(lf_size,typeof(lf_threshold(0)))
  lf_vals      = new((/lf_size,2/),(/typeof(lf_threshold(0)),typeof(lf_threshold(0))/))  
  do h=0,lf_size-1
    print("Threshold = "+lf_threshold(h))
    lf_ref_vals(h) = lf(var(0,:,:),area,lf_threshold(h))
    
    print(lf_ref_vals(h))
  end do

  do h=0,lf_size-1
    print("Threshold = "+lf_threshold(h))
    lf_vals(h,0) = lf_threshold(h)
    lf_vals(h,1) = 100.0D0*lf(var(1,:,:),area,lf_threshold(h))/lf_ref_vals(h)
    
    print("xxx "+lf_vals(h,1))
  end do
  opt=True
  opt@fout = "filament.dat"
  write_matrix(lf_vals, "f12.8,1x,f12.8",opt)	
;  asciiwrite("filament.dat",lf_vals) 
;






end


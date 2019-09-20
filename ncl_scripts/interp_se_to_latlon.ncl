load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$my_ncl_dir/ESMF_regridding.ncl"

begin
  system("touch abnormal_exit") 
  ;nx           =240
  ;ny           =120
  ; Get the list of filenames
  ;---------------------------

  Flist =  systemfunc("ls "+srcPath+case)
  caselist =  case

  Fnum=dimsizes(Flist)
  print("Number of Files to process="+Fnum)
  print(Flist)
  ; Loop over and regrid each file
  ;--------------------------------
  do nn=0,(Fnum-1)
    FileName=Flist(nn)
    ; set the source/destination file names, 
    ; open the source file for reading, 
    ; create a destination file for regridded data.
    ;------------------------------------------------
    srcFileName=FileName
    dstFileName=dstPath+caselist(nn)+"."+interp_method+"_to_"+outgrid+".nc"

    print(" ")
    print("source file name     : "+srcFileName)
    print("destination file name: "+dstFileName)
    if(isfilepresent(dstFileName)) then
      system("rm "+dstFileName)
    end if
    src_file=addfile(srcFileName,"r")
    dst_file=addfile(dstFileName,"c")

    ;
    ; 1. Generate a description file (SCRIP or ESMF) 
    ;    for the source grid.
    ;---------------------------------------------------
     ;
    ; CREATE ESMF DESTINATION (LATLON) GRID DESCRIPTOR FILE
    ;
    dstGridName = grid_dir+"/dstgrid_"+outgrid+"_SCRIP.nc"
    if(isfilepresent(dstGridName)) then
      print("Found dstGrid description "+dstGridName)
    else
      print("Creating dstGrid description "+dstGridName)
      Opt               =True
      Opt@ForceOverWrite=True
      Opt@PrintTimings  =True
      Opt@Debug         =False ; True
      lats              =latGlobeF(ny,"lat","latitude" ,"degrees_north")
      lons              =lonGlobeF(nx,"lon","longitude","degrees_east" )
      rectilinear_to_SCRIP(dstGridName,lats,lons,Opt)
      delete(lats)
      delete(lons)
      delete(Opt)
    end if
    ;
    ; is this a physGrid file? (contains two different grids)
    ;
    vdims = getvardims(src_file)   
    grid_options = (/"ncol_d","ncol_fvm","ncol"/)
    lat_name     = (/"lat_d" ,"lat_fvm","lat"/)
    lon_name     = (/"lon_d" ,"lon_fvm","lon"/)
    print("Generating ESMF grid descriptor files")
    do jj=0,dimsizes(vdims)-1
      ;
      ; CREATE ESMF SOURCE GRID DESCRIPTOR FILE
      ;
      do igrid=0,2
        print("vdims(jj)="+vdims(jj)+" "+lat_name(igrid))
        if(str_lower(vdims(jj)).eq.grid_options(igrid)) then
	  ESMF_srcGridName=grid_dir+"/srcgrid_"+grid_options(igrid)+"_ESMF.nc"
          if(isfilepresent(ESMF_srcGridName)) then
            print("Found ESMF grid file: "+ESMF_srcGridName)
          else
            print("Creating srcGrid description "+ESMF_srcGridName)
            Opt               =True
            Opt@ForceOverWrite=True
            Opt@PrintTimings  =True
            Opt@Title         =grid_options(igrid)+" grid"  
            Opt@Debug         =True ; False
            unstructured_to_ESMF(ESMF_srcGridName,src_file->$lat_name(igrid)$,src_file->$lon_name(igrid)$,Opt)
            delete(Opt)
          end if
	  ;
	  ; GENERATE THE WEIGHT FILES
	  ;
          wgtFileName  = grid_dir+"/"+grid_options(igrid)+"_"+ingrid+"_to_"+outgrid+"_"+interp_method+".nc"
          if(isfilepresent(wgtFileName)) then
             print("Found WeightFile "+wgtFileName)
          else
             print("Creating WeightFile "+wgtFileName)
             Opt               =True
             Opt@InterpMethod  =interp_method ;"bilinear"  "patch", "conserve"
             Opt@ForceOverWrite=True
             Opt@PrintTimings  =True
             Opt@SrcESMF       =True   
             Opt@Debug         =False ; True
             ESMF_regrid_gen_weights(ESMF_srcGridName,dstGridName,wgtFileName,Opt)
             delete(Opt)
	    end if
	  end if
      end do
    end do
    ; 
    ; 4. Setup output file dimensions, coordinates, etc..
    ;-------------------------------------------------------
    dstlat=retrieve_SCRIP_lat(dstGridName)
    dstlon=retrieve_SCRIP_lon(dstGridName)
    lats  =dstlat(:,0)    ; This is a rectilinear grid, so
    lons  =dstlon(0,:)    ; we only need a 1D sub-selection.
    dst_lat      =lats
    dst_lon      =lons
    dst_lat@units="degrees_north"
    dst_lon@units="degrees_east"
    dst_lat!0    ="lat"
    dst_lon!0    ="lon"
    dst_lat&lat  =lats
    dst_lon&lon  =lons
  
    filedimdef(dst_file,"time",-1,True) ; define time unlimited
    fileattdef(dst_file,src_file) 
    dst_file->lat =dst_lat
    dst_file->lon =dst_lon

    ;
    ; 5. Apply the weights to the data you want to regrid.
    ;----------------------------------------------------------------------
    Opt             =True
    Opt@Debug       =True
    Opt@PrintTimings=True
    Opt@SrcESMF     =True   
 
    ; select all the variables in the file
    ;----------------------------------------------------------------------
    vname = getfilevarnames(src_file)    
    print("vname  "+vname)
    do ii=0,dimsizes(vname)-1
      print("Looking at variable "+vname(ii)) 
      ; Skip variables that do not apply
      ;-----------------------------------
      if(str_lower(vname(ii)).eq."lat" ) then continue end if
      if(str_lower(vname(ii)).eq."lat_d") then continue end if
      if(str_lower(vname(ii)).eq."lat_fvm") then continue end if
      if(str_lower(vname(ii)).eq."lon" ) then continue end if
      if(str_lower(vname(ii)).eq."lon_d" ) then continue end if
      if(str_lower(vname(ii)).eq."lon_fvm" ) then continue end if
      if(str_lower(vname(ii)).eq."lev" ) then continue end if
      if(str_lower(vname(ii)).eq."ilev") then continue end if
      if(str_lower(vname(ii)).eq."ncol_fvm") then continue end if
      if(str_lower(vname(ii)).eq."ncol") then continue end if
      if(str_lower(vname(ii)).eq."time") then continue end if
      if(str_lower(vname(ii)).eq."area") then continue end if
      if(str_lower(vname(ii)).eq."area_d") then continue end if
      if(str_lower(vname(ii)).eq."area_fvm") then continue end if
      if(str_lower(vname(ii)).eq."nrdg") then continue end if

      ; Get dimensions for this variable, look for 'ncol' dimension
      ;-------------------------------------------------------------
      dNames=getfilevardims(src_file,vname(ii))  
      nrank =dimsizes(dNames)               ; determine the number of dimensions
      do jj=0,nrank-1
        remapvar  =False
        newlatdim=-999
        newlondim=-999
        do igrid=0,2
          if(str_lower(dNames(jj)).eq.grid_options(igrid)) then 
             wgtFileName  = grid_dir+"/"+grid_options(igrid)+"_"+ingrid+"_to_"+outgrid+"_"+interp_method+".nc"
             remapvar=True
             newlatdim=jj
             newlondim=jj+1
          end if
        end do
      end do ; jj=0,nrank-1

      ; if needed map 'ncol' into 'lat' and 'lon', otherwise 
      ; just copy the variable
      ;-------------------------------------------------------
      if(remapvar) then             
        print("Interpolating "+vname(ii))
        ; read variable to memory and regrid values
        ;--------------------------------------------
        print("1")
        Vold=src_file->$vname(ii)$ 
        ;Vnew=ESMF_regrid_with_weights(Vold,wgtFileName,Opt)

       
        if(typeof(Vold).eq."float") then
           print("wgt"+wgtFileName)
           VnewD=ESMF_regrid_with_weights(Vold,wgtFileName,Opt)
           printVarSummary(VnewD)
           Vnew=doubletofloat(VnewD)
           delete(VnewD)
        else
           Vnew=ESMF_regrid_with_weights(Vold,wgtFileName,Opt)
        end if 
        ; Copy attributes and adjust dimensions
        ;--------------------------------------
        copy_VarAtts (Vold,Vnew)
        print("copy attributes")
        do jj=0,newlatdim-1
          Vnew!jj          =Vold!jj
;xxx          Vnew&$dNames(jj)$=Vold&$dNames(jj)$
        end do
        Vnew!newlatdim="lat"
        Vnew!newlondim="lon"
        Vnew&lat      =dstlat(:,0)    ; This is a rectilinear grid, so
        Vnew&lon      =dstlon(0,:)    ; we only need a 1D sub-selection.
        print("nrank")
        do jj=newlondim+1,nrank
          Vnew!jj   = Vold!jj-1
          Vnew&$dNames(jj-1)$ = Vold&$dNames(jj-1)$
        end do
        delete(Vold)
      else
        Vnew=src_file->$vname(ii)$
      end if
      dst_file->$vname(ii)$=Vnew 
      delete(Vnew)
      delete(dNames)  
      delete(nrank)
    end do ; ii=0,dimsizes(vname)-1

    ; clean up everything for next iteration
    ;----------------------------------------
    delete(FileName)
    delete(srcFileName)
    delete(dstFileName)
    delete(src_file)
    delete(dst_file)
    delete(ESMF_srcGridName)
    delete(dstGridName)
    delete(wgtFileName)
    delete(dstlat)
    delete(dstlon)
    delete(lats)
    delete(lons)
    delete(dst_lat)
    delete(dst_lon)
    delete(vname)
    delete(vdims)
    delete(remapvar)
    delete(newlatdim)
    delete(newlondim)

  end do ;nn=0,(Fnum-1)
  system("\rm abnormal_exit") 
end

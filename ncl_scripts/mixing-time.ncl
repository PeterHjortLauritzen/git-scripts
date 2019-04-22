;**************************************
;
;**************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;**************************************
begin

 out_fname = "scatter_time"+"_"+vname1+"_"+resolution
 wks   = gsn_open_wks ("pdf",out_fname)
 ;
 ; setup plot details
 ;
 res                   = True                     ; plot mods desired
 res@gsnMaximize       = True                     ; maximize plot
 res@gsnFrame          = False
 res@xyMarkLineMode    = "MarkLines"               ; Markers *and* lines
 res@xyMarkers         = 6                        ; 3 different markers
 res@xyMarkerColors   := "blue"; 3 different colors

 plot  = gsn_csm_xy (wks,time(n1:n2),lr_error,res)                    ; create plot
 draw(plot)
 frame(wks)

end
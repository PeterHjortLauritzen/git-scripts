undef("setContourLevels")
procedure setContourLevels (res:logical, vname:string,diff:logical)
begin
    if (vname.eq."U") then
      res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
      if (diff) then
        res@cnLevelSpacingF      = 2.0                   ; contour interval
        res@cnMinLevelValF       =-20.0                  ; min level
        res@cnMaxLevelValF       =20.0                  ; max level
      else
     ;
     ; AMIP - CAM
     ;
        res@cnLevelSpacingF      = 5.0                   ; contour interval
        res@cnMinLevelValF       =  -10.0                  ; min level
        res@cnMaxLevelValF       =  65.0                  ; max level
;        res@cnLevelSpacingF      = 10.0                   ; contour interval
;        res@cnMinLevelValF       =  -40.0                  ; min level
;        res@cnMaxLevelValF       =  200.0                  ; max level

;
; Held-Suarez
;
;        res@cnLevelSpacingF      = 5.0                   ; contour interval
;        res@cnMinLevelValF       =  -50.0                  ; min level
;        res@cnMaxLevelValF       =  50.0                  ; max level	
     end if
   end if

    if (vname.eq."PS") then
      res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
      if (diff) then
        res@cnLevelSpacingF      = 1.0                   ; contour interval
        res@cnMinLevelValF       = -4.0                  ; min level
        res@cnMaxLevelValF       = 10.0                  ; max level
      else
        res@cnLevelSpacingF      = 2.0                   ; contour interval
        res@cnMinLevelValF       = 996.0                  ; min level
        res@cnMaxLevelValF       =1020.0                  ; max level
     end if
   end if

    if (vname.eq."PRECT") then
      res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
      if (diff) then
        res@cnLevelSpacingF      = 0.5                   ; contour interval
        res@cnMinLevelValF       = -3.5                  ; min level
        res@cnMaxLevelValF       =  4.5                  ; max level
      else
        res@cnLevelSpacingF      = 2.0                   ; contour interval
        res@cnMinLevelValF       = 0.0                  ; min level
        res@cnMaxLevelValF       = 20.0                  ; max level
     end if
   end if

    if (vname.eq."CLDTOT") then
      res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
      if (diff) then
        res@cnLevelSpacingF      = 0.02                   ; contour interval
        res@cnMinLevelValF       = -0.12                  ; min level
        res@cnMaxLevelValF       =  0.06                  ; max level
      else
        res@cnLevelSpacingF      = 0.05                   ; contour interval
        res@cnMinLevelValF       = 0.4                  ; min level
        res@cnMaxLevelValF       = 0.75                  ; max level
     end if
   end if


    if (vname.eq."V") then
      res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
      if (diff) then
        res@cnLevelSpacingF      = 0.1                   ; contour interval
        res@cnMinLevelValF       =  -1.0                  ; min level
        res@cnMaxLevelValF       =   1.0                  ; max level
      else
        res@cnLevelSpacingF      = 1.0                   ; contour interval
        res@cnMinLevelValF       = -5.0                  ; min level
        res@cnMaxLevelValF       =  5.0                  ; max level
      end if
    end if

    if (vname.eq."Q") then
      res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
      if (diff) then
          res@cnLevelSpacingF      = 0.02                   ; contour interval
          res@cnMinLevelValF       =  -0.02                  ; min level
          res@cnMaxLevelValF       =   0.3                  ; max level
        else
          res@cnLevelSpacingF      = 1.0                   ; contour interval
          res@cnMinLevelValF       = 0.0                  ; min level
          res@cnMaxLevelValF       = 16.0                  ; max level
        end if
    end if


    if (vname.eq."CLOUD") then
      res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
      if (diff) then
          res@cnLevelSpacingF      = 0.01                   ; contour interval
          res@cnMinLevelValF       =  -0.04                  ; min level
          res@cnMaxLevelValF       =   0.06                  ; max level
        else
;          res@cnLevelSpacingF      = 0.025                   ; contour interval
          res@cnMinLevelValF       = 0.0                  ; min level
          res@cnMaxLevelValF       = .45                  ; max level
        end if
    end if

    if (vname.eq."OMEGA") then
      res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
      if (diff) then
          res@cnLevelSpacingF      = 0.2                   ; contour interval
          res@cnMinLevelValF       =  -1.2                  ; min level
          res@cnMaxLevelValF       =   0.4                  ; max level
        else
          res@cnLevelSpacingF      =   1.0                   ; contour interval
          res@cnMinLevelValF       = -14.0                  ; min level
          res@cnMaxLevelValF       =   4.0                  ; max level
        end if
    end if

    if (vname.eq."T") then
;      res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
;      if (diff) then
;          res@cnLevelSpacingF      =  0.5                   ; contour interval
;          res@cnMinLevelValF       = -10.0                  ; min level
;          res@cnMaxLevelValF       = 10.0                  ; max level
;        else
;          res@cnLevelSpacingF      =  5.0                   ; contour interval
;          res@cnMinLevelValF       =  185.0                  ; min level
;          res@cnMaxLevelValF       =  305.0                  ; max level
;
; WACCM
;

;          res@cnLevelSpacingF      =  5.0                   ; contour interval
;          res@cnMinLevelValF       =  180.0                  ; min level
;          res@cnMaxLevelValF       =  300.0                  ; max level
;        end if
    end if


    if (vname.eq."RELHUM") then
      res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
      if (diff) then
          res@cnLevelSpacingF      = 1.0                   ; contour interval
          res@cnMinLevelValF       =  -6.0                  ; min level
          res@cnMaxLevelValF       =  11.0                  ; max level
        else
          res@cnLevelSpacingF      = 10.0                   ; contour interval
          res@cnMinLevelValF       = 0.0                  ; min level
          res@cnMaxLevelValF       = 100.0                  ; max level
        end if
    end if

    if (vname.eq."PTEQ") then
      res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
      if (diff) then
          res@cnLevelSpacingF      =   0.04                  ; contour interval
          res@cnMinLevelValF       =  -0.24                  ; min level
          res@cnMaxLevelValF       =   0.24                  ; max level
        else
          res@cnLevelSpacingF      =   0.4                   ; contour interval
          res@cnMinLevelValF       =  -2.4                  ; min level
          res@cnMaxLevelValF       =   1.8                  ; max level
        end if
    end if


    if (vname.eq."PTTEND") then
      res@cnLevelSelectionMode = "ManualLevels"        ; manual contour levels
      if (diff) then

          res@cnLevelSpacingF      =   0.1                  ; contour interval
          res@cnMinLevelValF       =  -0.6                  ; min level
          res@cnMaxLevelValF       =   0.6                  ; max level
        else
          res@cnLevelSpacingF      =   1.0                   ; contour interval
          res@cnMinLevelValF       =  -2.0                  ; min level
          res@cnMaxLevelValF       =   6.0                  ; max level
        end if
    end if



;  return(area_string)
end

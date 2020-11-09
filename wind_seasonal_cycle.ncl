load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"      ; These four libraries are automatically
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"       ; loaded from NCL V6.4.0 onward.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   ; No need for user to explicitly load.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
;read files   f3 g3 g2

ncep_ua=addfile("../data/obdata/NCEP/uwnd1000_198001_201412.nc","r")
ua_f3=addfile("../data/fgoals-f3/ua1000_Amon_FGOALS-f3-L_historical_r1i1p1f1_gr_198001-201412.nc","r")
ua_g2=addfile("../data/fgoals-g2/ua1000_Amon_FGOALS-g2_historical_r1i1p1_198001_200512.nc","r")
ua_g3=addfile("../data/fgoals-g3/ua1000_Amon_FGOALS-g3_historical_r1i1p1f1_gn_198001_201612.nc","r")

ncep_va=addfile("../data/obdata/NCEP/vwnd1000_198001_201412.nc","r")
va_f3=addfile("../data/fgoals-f3/va1000_Amon_FGOALS-f3-L_historical_r1i1p1f1_gr_198001-201412.nc","r")
va_g2=addfile("../data/fgoals-g2/va1000_Amon_FGOALS-g2_historical_r1i1p1_198001_200512.nc","r")
va_g3=addfile("../data/fgoals-g3/va1000_Amon_FGOALS-g3_historical_r1i1p1f1_gn_198001_201612.nc","r")
;read variables 198001-200412(common period) time=25*12=300

U_f3=ua_f3->ua(0:25*12-1,0,:,:)
U_g2=ua_g2->ua(0:25*12-1,0,:,:)
U_g3=ua_g3->ua(0:25*12-1,0,:,:)
U_ncep=ncep_ua->uwnd(0:25*12-1,0,:,:);time1785 1870start

V_f3=va_f3->va(0:25*12-1,0,:,:)
V_g2=va_g2->va(0:25*12-1,0,:,:)
V_g3=va_g3->va(0:25*12-1,0,:,:)
V_ncep=ncep_va->vwnd(0:25*12-1,0,:,:);time1785 1870start

;wind 
clm_NCEP_U=clmMonTLL(U_ncep)
clm_U_f3=clmMonTLL(U_f3)
clm_U_g3=clmMonTLL(U_g3)
clm_U_g2=clmMonTLL(U_g2)

clm_NCEP_V=clmMonTLL(V_ncep)
clm_V_f3=clmMonTLL(V_f3)
clm_V_g3=clmMonTLL(V_g3)
clm_V_g2=clmMonTLL(V_g2)
printVarSummary(clm_NCEP_V)
;averaged over 140E-90W month-lat 

lat_NCEP_U=dim_avg_n_Wrap(clm_NCEP_U(:,{-25:25},{140:270}),2)
printVarSummary(lat_NCEP_U)
lat_NCEP_U:=lat_NCEP_U(lat|:,month|:)
lat_U_f3=dim_avg_n_Wrap(clm_U_f3(:,{-25:25},{140:270}),2)
lat_U_f3:=lat_U_f3(lat|:,month|:)
lat_U_g3=dim_avg_n_Wrap(clm_U_g3(:,{-25:25},{140:270}),2)
lat_U_g3:=lat_U_g3(lat|:,month|:)
lat_U_g2=dim_avg_n_Wrap(clm_U_g2(:,{-25:25},{140:270}),2)
lat_U_g2:=lat_U_g2(lat|:,month|:)


lat_NCEP_V=dim_avg_n_Wrap(clm_NCEP_V(:,{-25:25},{140:270}),2)
printVarSummary(lat_NCEP_V)
lat_NCEP_V:=lat_NCEP_V(lat|:,month|:)
lat_V_f3=dim_avg_n_Wrap(clm_V_f3(:,{-25:25},{140:270}),2)
lat_V_f3:=lat_V_f3(lat|:,month|:)
lat_V_g3=dim_avg_n_Wrap(clm_V_g3(:,{-25:25},{140:270}),2)
lat_V_g3:=lat_V_g3(lat|:,month|:)
lat_V_g2=dim_avg_n_Wrap(clm_V_g2(:,{-25:25},{140:270}),2)
lat_V_g2:=lat_V_g2(lat|:,month|:)
print("okay!")



;*******************************************************
;          create plot
;********************************************************
wks=gsn_open_wks("pdf","1000wind_lon_time")
plot = new(4,graphic)                     ; create graphic array

  vecres                  = True            ; vector only resources
  vecres@gsnDraw          = False           ; don't draw
  vecres@gsnFrame         = False           ; don't advance frame
  vecres@vcGlyphStyle     = "CurlyVector"   ; curly vectors
  vecres@vcRefMagnitudeF  = 7          ; define vector ref mag
  vecres@vcRefLengthF     = 0.045           ; define length of vec ref
  ;vecres@gsnLeftString    = " "             ; turn off left string
  ;vecres@tiXAxisString    = " "             ; turn off axis label 
  ;vecres@vcRefAnnoOrthogonalPosF = -.535    ; move ref vector into plot


;set time labels to months tmYLMode /tmXBMode
 vecres@tmXBMode			 ="Explicit"
 vecres@tmXBValues			 =ispan(0,11,1)
 vecres@tmXBLabels			 =(/"J","F","M","A","M","J","J","A","S","O","N","D"/)
  vecres@gsnLeftString   = "NCEP"             ; turn off right string
  plot(0)   = gsn_csm_vector(wks,lat_NCEP_U,lat_NCEP_V,vecres)
  
  vecres@gsnLeftString   = "FGOALS-g2"             ; turn off right string
  plot(1)   = gsn_csm_vector(wks,lat_U_g2,lat_V_g2,vecres)
  vecres@gsnLeftString   = "FGOALS-g3"             ; turn off right string
  plot(2)   = gsn_csm_vector(wks,lat_U_g3,lat_V_g3,vecres)
  vecres@gsnLeftString   = "FGOALS-f3"             ; turn off right string
  plot(3)   = gsn_csm_vector(wks,lat_U_f3,lat_V_f3,vecres)


  resP                = True                ; panel only resources
  resP@gsnMaximize    = True                ; maximize plots
  gsn_panel(wks,plot,(/2,2/),resP)          ; now draw as one plot

end


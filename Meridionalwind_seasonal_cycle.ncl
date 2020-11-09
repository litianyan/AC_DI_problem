load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"      ; These four libraries are automatically
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"       ; loaded from NCL V6.4.0 onward.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   ; No need for user to explicitly load.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
;read files   f3 g3 g2

ncep_va=addfile("../data/obdata/NCEP/vwnd1000_198001_201412.nc","r")
va_f3=addfile("../data/fgoals-f3/va1000_Amon_FGOALS-f3-L_historical_r1i1p1f1_gr_198001-201412.nc","r")
va_g2=addfile("../data/fgoals-g2/va1000_Amon_FGOALS-g2_historical_r1i1p1_198001_200512.nc","r")
va_g3=addfile("../data/fgoals-g3/va1000_Amon_FGOALS-g3_historical_r1i1p1f1_gn_198001_201612.nc","r")
;read variables 198001-200412(common period) time=25*12=300


V_f3=va_f3->va(0:25*12-1,0,:,:)
V_g2=va_g2->va(0:25*12-1,0,:,:)
V_g3=va_g3->va(0:25*12-1,0,:,:)
V_ncep=ncep_va->vwnd(0:25*12-1,0,:,:);time1785 1870start

;wind 

clm_NCEP_V=clmMonTLL(V_ncep)
clm_V_f3=clmMonTLL(V_f3)
clm_V_g3=clmMonTLL(V_g3)
clm_V_g2=clmMonTLL(V_g2)
printVarSummary(clm_NCEP_V)
;averaged over 140E-90W month-lat 


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
print(max(lat_NCEP_V))
print(max(lat_V_f3))
print(max(lat_V_g3))
print(max(lat_V_g2))

print(min(lat_NCEP_V))
print(min(lat_V_f3))
print(min(lat_V_g3))
print(min(lat_V_g2))
;*******************************************************
;          create plot
;********************************************************
wks=gsn_open_wks("pdf","meroid1000wind_lon_time")
plot = new(4,graphic)                     ; create graphic array

 res                  		 = True                ; Use plot options
 res@cnFillOn       		 = True                ; Fill contours 
 res@gsnStringFontHeightF 	 =   0.024
 res@lbLabelFontHeightF   	 = 0.024
 res@tmXBLabelFontHeightF	 = 0.03
 res@tmYLLabelFontHeightF	 = 0.03
 res@gsnDraw         		 = False               ; Do not draw plot
 res@gsnFrame        		 = False 
 res@cnLinesOn			 = False
 res@cnLineLabelsOn		 = False
 res@cnFillPalette		 = "BlueWhiteOrangeRed";"NCV_bright"
 ;res@cnFillPalette		 = "precip_11lev"
 res@cnInfoLabelOn   		 = False 
 ;res@gsnSpreadColors = True
 res@cnLevelSelectionMode	 = "ManualLevels" ; equally spaced contour levels
 res@cnMaxLevelValF		 =4.;12;30.
 res@cnMinLevelValF		 =-4.;0.;19.
 res@cnLevelSpacingF		 =.5;1;.5
 res@lbLabelBarOn     		 =False

;set time labels to months tmYLMode /tmXBMode
 res@tmXBMode			 ="Explicit"
 res@tmXBValues			 =ispan(0,11,1)
 res@tmXBLabels			 =(/"J","F","M","A","M","J","J","A","S","O","N","D"/)
 res@gsnLeftString		 ="Meridional Wind"
 res@gsnRightString		 ="m/s"
 plot(0)=gsn_csm_lat_time(wks,lat_NCEP_V,res)
 res@gsnLeftString		 ="FGOALS_g2"
 ;res@lbOrientation		 = "vertical"
 ;res@lbLabelBarOn    		 =True
 ;res@pmLabelBarOrthogonalPosF=-0.025
 ;res@pmLabelBarWidthF=0.06
 ;res@lbLabelFontHeightF=0.018
 
 plot(1)=gsn_csm_lat_time(wks,lat_V_g2,res) 
 res@gsnLeftString		 ="FGOALS_g3"
 ;res@lbLabelBarOn     	       	=False
 plot(2)=gsn_csm_lat_time(wks,lat_V_g3,res)
 res@gsnLeftString		="FGOALS_f3"
 plot(3)=gsn_csm_lat_time(wks,lat_V_f3,res)

 pres				=True
 pres@gsnPanelLabelBar= True
 gsn_panel(wks,plot,(/2,2/),pres)

end


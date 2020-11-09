load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"      ; These four libraries are automatically
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"       ; loaded from NCL V6.4.0 onward.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   ; No need for user to explicitly load.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
;read files   f3 g3 g2
pr_f3=addfile("../data/fgoals-f3/pr_Amon_FGOALS-f3-L_historical_r1i1p1f1_gr_198001-201412_regrid.nc","r")
sst_f3=addfile("../data/fgoals-f3/tos_Omon_FGOALS-f3-L_historical_r1i1p1f1_gn_185001-201412_regrid.nc","r")
hadsst=addfile("../data/obdata/HADLSST/HadISST_sst_regrid.nc","r")
gpcppre=addfile("../data/obdata/GPCP/GPCP.198001-201712_remap.nc","r")

pr_g2=addfile("../data/fgoals-g2/pr_Amon_FGOALS-g2_historical_r1i1p1_198001-200412_remap.nc","r")
pr_g3=addfile("../data/fgoals-g3/pr_Amon_FGOALS-g3_historical_r1i1p1f1_gn_198001-200912_remap.nc","r")
sst_g2=addfile("../data/fgoals-g2/tos_Omon_FGOALS-g2_historical_r1i1p1_198001-200412_remap.nc","r")
sst_g3=addfile("../data/fgoals-g3/tos_Omon_FGOALS-g3_historical_r1i1p1f1_gn_198001-201412_remap.nc","r")

pr_s2=addfile("../data/fgoals-s2/licom.pr.198001-200412.nc","r")
sst_s2=addfile("../data/fgoals-s2/licom.tos.198001-200412.nc","r")
;read variables 198001-200412(common period) time=25*12=300 
SST_f3=sst_f3->tos(130*12:155*12-1,:,:)
PR_f3=pr_f3->pr(0:25*12-1,:,:)
PR_f3=where(ismissing(PR_f3),PR_f3@_FillValue,PR_f3*24*60*60)
PR_f3@units="mm/day"
SST_g2=sst_g2->tos
SST_g2=where(ismissing(SST_g2),SST_g2@_FillValue,SST_g2-273.15)
SST_g2@units="degC"
PR_g2=pr_g2->pr
PR_g2=where(ismissing(PR_g2),PR_g2@_FillValue,PR_g2*24*60*60)
PR_g2@units="mm/day"
SST_g3=sst_g3->tos(0:25*12-1,:,:)
PR_g3=pr_g3->pr(0:25*12-1,:,:)
PR_g3=where(ismissing(PR_g3),PR_g3@_FillValue,PR_g3*24*60*60)
PR_g3@units="mm/day"

SST_s2=sst_s2->tos
SST_s2=where(ismissing(SST_s2),SST_s2@_FillValue,SST_s2-273.15)
SST_s2@units="degC"
PR_s2=pr_s2->pr
PR_s2=where(ismissing(PR_s2),PR_s2@_FillValue,PR_s2*24*60*60)
PR_s2@units="mm/day"
HADsst=hadsst->sst(110*12:135*12-1,:,:);time1785 1870start
GPCPpre=gpcppre->precip(0:299,:,:);time456 198001-201712 
;monthly climatology
a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
lsdata = a->LSMASK
lsm  = landsea_mask(lsdata,HADsst&lat,HADsst&lon)
n_time=dimsizes(HADsst&time)
do i=0,n_time-1
	HADsst(i,:,:) = mask(HADsst(i,:,:),lsm.eq.1,False)
end do

;SST Anomaly /Precipitation rate
clm_HADsst=clmMonTLL(HADsst)-conform_dims((/12,180,360/),dim_avg_n_Wrap(clmMonTLL(HADsst),0),(/1,2/))
copy_VarCoords(clmMonTLL(HADsst),clm_HADsst)
clm_GPCPpre=clmMonTLL(GPCPpre)
clm_SST_f3=clmMonTLL(SST_f3)-conform_dims((/12,180,360/),dim_avg_n_Wrap(clmMonTLL(SST_f3),0    ),(/1,2/))
copy_VarCoords(clmMonTLL(SST_f3),clm_SST_f3)
clm_PR_f3=clmMonTLL(PR_f3)
clm_SST_g3=clmMonTLL(SST_g3)-conform_dims((/12,180,360/),dim_avg_n_Wrap(clmMonTLL(SST_g3),0        ),(/1,2/))
copy_VarCoords(clmMonTLL(SST_g3),clm_SST_g3)
clm_PR_g3=clmMonTLL(PR_g3)
clm_SST_g2=clmMonTLL(SST_g2)-conform_dims((/12,180,360/),dim_avg_n_Wrap(clmMonTLL(SST_g2),0        ),(/1,2/))
copy_VarCoords(clmMonTLL(SST_g2),clm_SST_g2)
clm_PR_g2=clmMonTLL(PR_g2)
;averaged over 140E-90W month-lat 
clm_SST_s2=clmMonTLL(SST_s2)-conform_dims((/12,180,360/),dim_avg_n_Wrap(clmMonTLL(SST_s2),0        ),(/1,2/))
copy_VarCoords(clmMonTLL(SST_s2),clm_SST_s2)
clm_PR_s2=clmMonTLL(PR_s2)
;printVarSummary(clm_HADsst)
print("max of clm_HADsst"+max(clm_SST_f3))
print("min of clm_HADsst"+min(clm_SST_f3))
lat_HADsst=dim_avg_n_Wrap(clm_HADsst(:,{-25:25},{140:270}),2)
lat_HADsst:=lat_HADsst(lat|:,month|:)
lat_SST_f3=dim_avg_n_Wrap(clm_SST_f3(:,{-25:25},{140:270}),2)
lat_SST_f3:=lat_SST_f3(lat|:,month|:)
lat_SST_g3=dim_avg_n_Wrap(clm_SST_g3(:,{-25:25},{140:270}),2)
lat_SST_g3:=lat_SST_g3(lat|:,month|:)
lat_SST_g2=dim_avg_n_Wrap(clm_SST_g2(:,{-25:25},{140:270}),2)
lat_SST_g2:=lat_SST_g2(lat|:,month|:)

lat_GPCPpre=dim_avg_n_Wrap(clm_GPCPpre(:,{-25:25},{140:270}),2)
lat_GPCPpre:=lat_GPCPpre(lat|:,month|:)
lat_PR_f3=dim_avg_n_Wrap(clm_PR_f3(:,{-25:25},{140:270}),2)
lat_PR_f3:=lat_PR_f3(lat|:,month|:)
lat_PR_g3=dim_avg_n_Wrap(clm_PR_g3(:,{-25:25},{140:270}),2)
lat_PR_g3:=lat_PR_g3(lat|:,month|:)
lat_PR_g2=dim_avg_n_Wrap(clm_PR_g2(:,{-25:25},{140:270}),2)
lat_PR_g2:=lat_PR_g2(lat|:,month|:)
lat_PR_s2=dim_avg_n_Wrap(clm_PR_s2(:,{-25:25},{140:270}),2)
lat_PR_s2:=lat_PR_s2(lat|:,month|:)
;averaged over 2S-2N  month-lon

lon_HADsst=dim_avg_n_Wrap(clm_HADsst(:,{-2:2},{140:280}),1)
lon_SST_f3=dim_avg_n_Wrap(clm_SST_f3(:,{-2:2},{140:280}),1)
lon_SST_g3=dim_avg_n_Wrap(clm_SST_g3(:,{-2:2},{140:280}),1)
lon_SST_g2=dim_avg_n_Wrap(clm_SST_g2(:,{-2:2},{140:280}),1)
lon_SST_s2=dim_avg_n_Wrap(clm_SST_s2(:,{-2:2},{140:280}),1)

lon_GPCPpre=dim_avg_n_Wrap(clm_GPCPpre(:,{-2:2},{140:280}),1)
lon_PR_f3=dim_avg_n_Wrap(clm_PR_f3(:,{-2:2},{140:280}),1)
lon_PR_g3=dim_avg_n_Wrap(clm_PR_g3(:,{-2:2},{140:280}),1)
lon_PR_g2=dim_avg_n_Wrap(clm_PR_g2(:,{-2:2},{140:280}),1)
lon_PR_s2=dim_avg_n_Wrap(clm_PR_s2(:,{-2:2},{140:280}),1)
;printVarSummary(lon_GPCPpre)
;printVarSummary(lon_PR_f3)
;printVarSummary(lon_PR_g3)
;printVarSummary(lon_PR_g2)
print("max of lon_HADsst"+max(lon_HADsst))
print("min of lon_HADsst"+min(lon_HADsst))


print("okay!")

;*******************************************************
;          create plot
;********************************************************
; wks= gsn_open_wks("pdf","sst_lat_time")        
 wks= gsn_open_wks("pdf","pre_lat_time")
;wks=gsn_open_wks("pdf","sst_lon_time")
 ;wks=gsn_open_wks("pdf","pre_lon_time")
 plot = new(5,graphic)                     ; create graphic array

 res                  		 = True                ; Use plot options
 res@cnFillOn       		 = True                ; Fill contours 
 res@gsnStringFontHeightF 	 =   0.024
 res@lbLabelFontHeightF   	 = 0.024
 res@tmXBLabelFontHeightF	 = 0.03
 res@tmYLLabelFontHeightF	 = 0.03
 res@gsnDraw         		 = False               ; Do not draw plot
 res@gsnFrame        		 =False 
 res@cnLinesOn			 = False
 res@cnLineLabelsOn		 = False
 ;res@cnFillPalette		 = "BlueWhiteOrangeRed";"NCV_bright"
 res@cnFillPalette		 = "precip_11lev"
 res@cnInfoLabelOn   		 = False 
 ;res@gsnSpreadColors = True
; res@cnLevelSelectionMode	 = "ExplicitLevels" ; equally spaced contour levels
;res@cnLevels=(/-3,-2,-1,-0.8,-0.6,-0.4,-0.2,0,0.2,0.4,0.6,0.8,1.0,2.0,3.0/)
 res@cnLevelSelectionMode="ManualLevels"
 res@cnMaxLevelValF		 =12;30.
 res@cnMinLevelValF		 =0.;19.
 res@cnLevelSpacingF		 =1;.5
 res@lbLabelBarOn     		 =False

;set time labels to months tmYLMode /tmXBMode
 res@tmXBMode			 ="Explicit"
 res@tmXBValues			 =ispan(0,11,1)
 res@tmXBLabels			 =(/"J","F","M","A","M","J","J","A","S","O","N","D"/)
 res@gsnLeftString		 ="GPCP(Precipitation Rate)";"HadlSST(SST)"
 res@gsnRightString		 ="mm/day";"degC"
 plot(0)=gsn_csm_lat_time(wks,lat_GPCPpre,res)
 
 res@gsnLeftString		 ="FGOALS_s2"
 plot(1)=gsn_csm_lat_time(wks,lat_PR_s2,res)
 
 res@gsnLeftString		 ="FGOALS_g2"
 ;res@lbOrientation		 = "vertical"
 ;res@lbLabelBarOn    		 =True
 ;res@pmLabelBarOrthogonalPosF=-0.025
 ;res@pmLabelBarWidthF=0.06
 ;res@lbLabelFontHeightF=0.018
 
 plot(2)=gsn_csm_lat_time(wks,lat_PR_g2,res) 
 res@gsnLeftString		 ="FGOALS_g3"
 ;res@lbLabelBarOn     	       	=False
 plot(3)=gsn_csm_lat_time(wks,lat_PR_g3,res)
 res@gsnLeftString		="FGOALS_f3"
 plot(4)=gsn_csm_lat_time(wks,lat_PR_f3,res)

 pres				=True
 pres@gsnPanelLabelBar= True
 pres@gsnPanelRowSpec = True
 gsn_panel(wks,plot,(/1,2,2/),pres)

end

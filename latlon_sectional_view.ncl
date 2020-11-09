load "panel_two_sets.ncl"
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

;read variables 198001-200412(common period) time=25*12=300 
SST_f3=sst_f3->tos(130*12:155*12-1,:,:)
PR_f3=pr_f3->pr(0:25*12-1,:,:)
SST_g2=sst_g2->tos
SST_g2=where(ismissing(SST_g2),SST_g2@_FillValue,SST_g2-273.15)
SST_g2@units="degC"
PR_g2=pr_g2->pr
SST_g3=sst_g3->tos(0:25*12-1,:,:)
PR_g3=pr_g3->pr(0:25*12-1,:,:)
HADsst=hadsst->sst(110*12:135*12-1,:,:);time1785 1870start
GPCPpre=gpcppre->precip(0:299,:,:);time456 198001-201712 

SST_s2=sst_s2->tos
SST_s2=where(ismissing(SST_s2),SST_s2@_FillValue,SST_s2-273.15)
SST_s2@units="degC"
PR_s2=pr_s2->pr
PR_s2=where(ismissing(PR_s2),PR_s2@_FillValue,PR_s2*24*60*60)
PR_s2@units="mm/day"
;printVarSummary(PR_g2)
;printVarSummary(SST_g2)
;printVarSummary(SST_g3)
;printVarSummary(PR_g3)
;hadlsst
a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
lsdata = a->LSMASK
lsm  = landsea_mask(lsdata,HADsst&lat,HADsst&lon)
n_time=dimsizes(HADsst&time)
do i=0,n_time-1
	HADsst(i,:,:) = mask(HADsst(i,:,:),lsm.eq.1,False)
end do
if 0.eq.1 then
;CLIMATOLOGY MEAN
CLISST_f3=dim_avg_n_Wrap(SST_f3,0)
CLIHADsst=dim_avg_n_Wrap(HADsst,0)
dif_sstf3_had=CLISST_f3-CLIHADsst
copy_VarCoords(CLISST_f3,dif_sstf3_had)
CLIPR_f3=dim_avg_n_Wrap(PR_f3,0)
CLIPR_f3=where(ismissing(CLIPR_f3),CLIPR_f3@_FillValue,CLIPR_f3*24*60*60)
CLIGPCPpre=dim_avg_n_Wrap(GPCPpre,0)
dif_prf3_gpcp=CLIPR_f3-CLIGPCPpre
copy_VarCoords(CLIGPCPpre,dif_prf3_gpcp)
;****************************************
;      create plot(climatology)
;***************************************
;info
print("max sst_f3"+max(CLIPR_f3({-30:30},{100:300})))
print("max sst_had"+max(CLIGPCPpre({-30:30},{100:300})))
print("min sst_f3"+min(CLIPR_f3({-30:30},{100:300})))
print("min sst_had"+min(CLIGPCPpre({-30:30},{100:300})))

print("max bias_sst"+max(dif_prf3_gpcp({-30:30},{100:300})))
print("min bias_sst"+min(dif_prf3_gpcp({-30:30},{100:300})))
wks = gsn_open_wks("pdf","prec_obs_bias")         ; send graphics to PNG file
;wks = gsn_open_wks("pdf","sst_obs_bias")         ; send graphics to PNG file
  res                     = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@mpFillOn            = False            ; no need   
  res@cnLevelSelectionMode= "ManualLevels"   ; manual set levels
  res@cnMinLevelValF      = 0.;14.;0.
  res@cnMaxLevelValF      =12.; 30.;12.
  res@cnLevelSpacingF     = 1.             ; 20 contour levels        
  res@cnFillOn            = True             ; color fill plot
  res@cnFillPalette       ="precip_11lev" ;"BlueYellowRed" ;"BlAqGrYeOrRe"
  res@cnLinesOn           = False
  res@cnLineLabelsOn      = False
  res@cnInfoLabelOn       = False
  res@lbLabelBarOn        = False            ; turn off individual label bars
  res@mpCenterLonF        = 180.
  res@mpMinLonF              =   100
  res@mpMaxLonF              = 300
  res@mpMinLatF            = -30
  res@mpMaxLatF            = 30
  res@tmXBLabelFontHeightF                 = 0.022
  res@tmXBLabelStride                      = 2
  res@tmYLLabelFontHeightF                 = 0.022
  res@gsnLeftStringFontHeightF             = 0.022
  res@gsnCenterStringFontHeightF           = 0.022
  res@gsnRightStringFontHeightF            = 0.022
  res@tiYAxisFontHeightF                   = 0.022
  res@tiXAxisFontHeightF                   = 0.022
  res@tiMainFontHeightF                    = 0.022
  res@tiMainString                         = ""
  res@gsnLeftString                        = ""
  res@gsnCenterString                      = ""
  res@gsnRightString                       = ""
  res@tiYAxisString                        = ""
  res@tiXAxisString                        = ""
  ;
  ; Formatting the labelbar strings helps make the two sets of labelbars
  ; match better. Even though the labelbar is turned off, it is internally
  ;  still generated.
  ;
  ;res@lbLabelStrings      = sprintf("%4.1f",ispan(-20,380,20)*0.1)

  plot = new(2,graphic)    

  res@gsnLeftString       = "(a) FGOALS-f3-L"
  res@gsnRightString      = "mm/day"

  res@gsnCenterString     = ""
  plot(0) = gsn_csm_contour_map(wks,CLIPR_f3,res)

  res@gsnLeftString       = "(b) Observation"
  res@gsnCenterString     = ""
  plot(1) = gsn_csm_contour_map(wks,CLIGPCPpre,res)

  res@cnMinLevelValF      =-4.; -4.
  res@cnMaxLevelValF      = 4. ;4.
  res@cnLevelSpacingF     =  0.5
  res@cnFillPalette       = "BlueWhiteOrangeRed"    ; select a color map with white in the middle
  res@gsnLeftString       = "(c) Difference"
  res@gsnCenterString     = ""

  ;---Formatting the labelbar strings helps make the two sets of labelbars match better
  ;res@lbLabelStrings      := sprintf("%4.1f",ispan(-40,40,5)*0.1)
  plot2 = gsn_csm_contour_map(wks, dif_prf3_gpcp ,res)

  ;---Panel the two sets of plots. Note no special resources need to be set.
  pres1 = True
  pres1@pmLabelBarWidthF  = 0.05
  pres1@lbLabelJust       = "CenterLeft"
  pres2 = True
  pres2@pmLabelBarWidthF  = 0.05
  pres2@lbLabelJust       = "CenterLeft"
  pres  = True
  panel_two_sets(wks,plot,plot2,(/2,1/),(/1,1/),pres1,pres2,pres)
end if

;if 0.eq.1 then;for the sectioal view of the climatology
;get value between 2S and 2N/140E and 80W

latSST_f3=dim_avg_n_Wrap(SST_f3(:,:,{250:280}),2)
latSST_f3:=dim_avg_n_Wrap(latSST_f3,0)
latSST_g2=dim_avg_n_Wrap(SST_g2(:,:,{250:280}),2)
latSST_g2:=dim_avg_n_Wrap(latSST_g2,0)
latSST_g3=dim_avg_n_Wrap(SST_g3(:,:,{250:280}),2)
latSST_g3:=dim_avg_n_Wrap(latSST_g3,0)
latHADsst=dim_avg_n_Wrap(HADsst(:,:,{250:280}),2)
latHADsst:=dim_avg_n_Wrap(latHADsst,0)

latSST_s2=dim_avg_n_Wrap(SST_s2(:,:,{250:280}),2)
latSST_s2:=dim_avg_n_Wrap(latSST_s2,0)

SST_f3:=dim_avg_n_Wrap(SST_f3(:,{-2:2},:),(/0,1/))
PR_f3:=dim_avg_n_Wrap(PR_f3(:,:,{250:280}),2)
PR_f3:=dim_avg_n_Wrap(PR_f3,0)
PR_f3=where(ismissing(PR_f3),PR_f3@_FillValue,PR_f3*24*60*60)

SST_g2:=dim_avg_n_Wrap(SST_g2(:,{-2:2},:),(/0,1/))
PR_g2:=dim_avg_n_Wrap(PR_g2(:,:,{250:280}),2)
PR_g2:=dim_avg_n_Wrap(PR_g2,0)
PR_g2=where(ismissing(PR_g2),PR_g2@_FillValue,PR_g2*24*60*60)
SST_g3:=dim_avg_n_Wrap(SST_g3(:,{-2:2},:),(/0,1/))
PR_g3:=dim_avg_n_Wrap(PR_g3(:,:,{250:280}),2)
PR_g3:=dim_avg_n_Wrap(PR_g3,0)
PR_g3=where(ismissing(PR_g3),PR_g3@_FillValue,PR_g3*24*60*60)
HADsst:=dim_avg_n_Wrap(HADsst(:,{-2:2},:),(/0,1/))
GPCPpre:=dim_avg_n_Wrap(GPCPpre(:,:,{250:280}),2)
GPCPpre:=dim_avg_n_Wrap(GPCPpre,0)

SST_s2:=dim_avg_n_Wrap(SST_s2(:,{-2:2},:),(/0,1/))
PR_s2:=dim_avg_n_Wrap(PR_s2(:,:,{250:280}),2)
PR_s2:=dim_avg_n_Wrap(PR_s2,0)

printVarSummary(PR_g2)
printVarSummary(PR_g3)

;*************************************
;           create plot
;*************************************
wks				=gsn_open_wks("pdf","lon_sectioal")
colors				=(/"black","darkorchid","blue","green","orange"/)
labels				=(/"HadlSST","FGOALS_s2","FGOALS_f3","FGOALS_g2","FGOALS_g3"/)

res 				=True
;res@trYMinF			=
res@xyLineColors		=colors
res@xyDashPatterns		=(/0,4,1,10,15/)
res@xyLineThicknesses		=(/4,2,2,2,2/)
;label
res@pmLegendDisplayMode 	="Always"
res@pmLegendWidthF		=0.2
res@pmLegendHeightF		=0.12
res@pmLegendOrthogonalPosF	=-0.38
res@pmLegendParallelPosF 	=0.83
res@xyExplicitLegendLabels	=labels
res@gsnDraw			=False
res@gsnFrame			=False
dlon_100=HADsst({140:240})
lon_100=dlon_100&lon
lonse=(/HADsst({140:240}),SST_s2({140:240}),SST_f3({140:240}),SST_g2({140:240}),SST_g3({140:240})/)
dlat_20=GPCPpre({-20:20});&lat
lat_20=dlat_20&lat
latse=(/GPCPpre({-20:20}),PR_s2({-20:20}),PR_f3({-20:20}),PR_g2({-20:20}),PR_g3({-20:20})/)
plot=new(3,graphic)
res@gsnLeftString		="Precicpitation Rate (mm/day)"
plot(0)				=gsn_csm_xy(wks,lat_20,latse,res)
labels				:=(/"GPCP","FGOALS_s2","FGOALS_f3","FGOALS_g2","FGOALS_g3"/)
res@xyExplicitLegendLabels	=labels
res@gsnLeftString		:="Sea Surface Temperature(Centigrade)"
plot(1)				=gsn_csm_xy(wks,lon_100,lonse,res)

latse:=(/latHADsst({-20:20}),latSST_s2({-20:20}),latSST_f3({-20:20}),latSST_g2({-20:20}),latSST_g3({-20:20})/)
plot(2)				=gsn_csm_xy(wks,lat_20,latse,res)	

pres				=True
gsn_panel(wks,plot,(/2,2/),pres)

;end if
end

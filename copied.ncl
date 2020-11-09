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
clm_HADsst=clmMonTLL(HADsst)
copy_VarCoords(clmMonTLL(HADsst),clm_HADsst)
clm_GPCPpre=clmMonTLL(GPCPpre)
clm_SST_f3=clmMonTLL(SST_f3)
copy_VarCoords(clmMonTLL(SST_f3),clm_SST_f3)
clm_PR_f3=clmMonTLL(PR_f3)
clm_SST_g3=clmMonTLL(SST_g3)
copy_VarCoords(clmMonTLL(SST_g3),clm_SST_g3)
clm_PR_g3=clmMonTLL(PR_g3)
clm_SST_g2=clmMonTLL(SST_g2)
copy_VarCoords(clmMonTLL(SST_g2),clm_SST_g2)
clm_PR_g2=clmMonTLL(PR_g2)
;averaged over 140E-90W month-lat 
clm_SST_s2=clmMonTLL(SST_s2)
copy_VarCoords(clmMonTLL(SST_s2),clm_SST_s2)
clm_PR_s2=clmMonTLL(PR_s2)
;printVarSummary(clm_HADsst)
;print("max of clm_HADsst"+max(clm_SST_f3))
;print("min of clm_HADsst"+min(clm_SST_f3))
;averaged over 2S-2N  month-lon

lon_HADsst=dim_avg_n_Wrap(clm_HADsst(:,{-2:2},{255:285}),(/1,2/))
lon_SST_f3=dim_avg_n_Wrap(clm_SST_f3(:,{-2:2},{255:285}),(/1,2/))
lon_SST_g3=dim_avg_n_Wrap(clm_SST_g3(:,{-2:2},{255:285}),(/1,2/))
lon_SST_g2=dim_avg_n_Wrap(clm_SST_g2(:,{-2:2},{255:285}),(/1,2/))
lon_SST_s2=dim_avg_n_Wrap(clm_SST_s2(:,{-2:2},{255:285}),(/1,2/))
r=1.
lon_HADsst=center_finite_diff(lon_HADsst,r,False,0)
lon_SST_f3=center_finite_diff(lon_SST_f3,r,False,0)
lon_SST_g3=center_finite_diff(lon_SST_g3,r,False,0)
lon_SST_g2=center_finite_diff(lon_SST_g2,r,False,0)
lon_SST_s2=center_finite_diff(lon_SST_s2,r,False,0)


lon_GPCPpre=dim_avg_n_Wrap(clm_GPCPpre(:,{-2:2},{255:285}),(/1,2/))
lon_PR_f3=dim_avg_n_Wrap(clm_PR_f3(:,{-2:2},{255:285}),(/1,2/))
lon_PR_g3=dim_avg_n_Wrap(clm_PR_g3(:,{-2:2},{255:285}),(/1,2/))
lon_PR_g2=dim_avg_n_Wrap(clm_PR_g2(:,{-2:2},{255:285}),(/1,2/))
lon_PR_s2=dim_avg_n_Wrap(clm_PR_s2(:,{-2:2},{255:285}),(/1,2/))
;printVarSummary(lon_GPCPpre)
;printVarSummary(lon_PR_f3)
;printVarSummary(lon_PR_g3)
;printVarSummary(lon_PR_g2)
;wind

ncep_va=addfile("../data/obdata/NCEP/vwnd1000_198001_201412.nc","r")
va_f3=addfile("../data/fgoals-f3/va1000_Amon_FGOALS-f3-L_historical_r1i1p1f1_gr_198001-201412.nc","r")
va_g2=addfile("../data/fgoals-g2/va1000_Amon_FGOALS-g2_historical_r1i1p1_198001_200512.nc","r")
va_g3=addfile("../data/fgoals-g3/va1000_Amon_FGOALS-g3_historical_r1i1p1f1_gn_198001_201612.nc","r")
va_s2=addfile("../data/fgoals-s2/va_Amon_FGOALS-s2_historical_r1i1p1_198001-200412.nc","r")
;read variables 198001-200412(common period) time=25*12=300


V_f3=va_f3->va(0:25*12-1,0,:,:)
V_g2=va_g2->va(0:25*12-1,0,:,:)
V_g3=va_g3->va(0:25*12-1,0,:,:)
V_ncep=ncep_va->vwnd(0:25*12-1,0,:,:);time1785 1870start
V_s2=va_s2->va(:,0,:,:)
;wind 

clm_NCEP_V=clmMonTLL(V_ncep)
clm_V_f3=clmMonTLL(V_f3)
clm_V_g3=clmMonTLL(V_g3)
clm_V_g2=clmMonTLL(V_g2)
clm_V_s2=clmMonTLL(V_s2)
;printVarSummary(clm_NCEP_V)
;averaged over 140E-90W month-lat 


lat_NCEP_V=dim_avg_n_Wrap(clm_NCEP_V(:,{-2:2},{255:285}),(/1,2/))
lat_V_f3=dim_avg_n_Wrap(clm_V_f3(:,{-2:2},{255:285}),(/1,2/))
lat_V_g3=dim_avg_n_Wrap(clm_V_g3(:,{-2:2},{255:285}),(/1,2/))
lat_V_g2=dim_avg_n_Wrap(clm_V_g2(:,{-2:2},{255:285}),(/1,2/))

lat_V_s2=dim_avg_n_Wrap(clm_V_s2(:,{-2:2},{255:285}),(/1,2/))

;read file

f3=addfile("/public/yyq/lty/data/fgoals-f3/rsntdstropical_Omon_FGOALS-f3-L_historical_r1i1p1f1_gn_198501-200412_regrid.nc","r")
g2=addfile("/public/yyq/lty/data/fgoals-g2/rsntdstropical_Amon_FGOALS-g2_historical_r1i1p1_198001_200412.nc","r")
g3=addfile("/public/yyq/lty/data/fgoals-g3/rsntdstropical_Omon_FGOALS-g3_historical_r1i1p1f1_gn_198501_200412_remap.nc","r")
oa=addfile("/public/yyq/lty/data/obdata/oaflux_sw_1985-2004.nc","r")
s2=addfile("../data/fgoals-s2/rsntds_Amon_FGOALS-s2_historical_r1i1p1_198001-200412.nc","r")
;read variable

F3=clmMonTLL(f3->rsntds)
G2=clmMonTLL(g2->rsndts)
G3=clmMonTLL(g3->rsntds)
OA=clmMonTLL(lonFlip(oa->NSWRS))
S2=clmMonTLL(s2->rsds)
sw_F3=dim_avg_n_Wrap(F3(:,:,{255:285}),(/1,2/))
sw_G2=dim_avg_n_Wrap(G2(:,:,{255:285}),(/1,2/))
sw_G3=dim_avg_n_Wrap(G3(:,:,{255:285}),(/1,2/))
sw_OA=dim_avg_n_Wrap(OA(:,{-2:2},{255:285}),(/1,2/))
sw_S2=dim_avg_n_Wrap(S2(:,{-2:2},{255:285}),(/1,2/))
;standardnize the short_wave radiation
;sw_F3= dim_standardize_Wrap(sw_F3,1)
;sw_G2= dim_standardize_Wrap(sw_G2,1)
;sw_G3= dim_standardize_Wrap(sw_G3,1)
;sw_OA= dim_standardize_Wrap(sw_OA,1)
;sw_S2= dim_standardize_Wrap(sw_S2,1)
;Final variables to be drawn
lhf_oa=addfile("/public/yyq/lty/data/obdata/lh_oaflux_1980_2018.nc","r")
lhf_g2=addfile("/public/yyq/lty/data/fgoals-g2/hfls_Amon_FGOALS-g2_historical_r1i1p1_198001_201412.nc","r")
lhf_g3=addfile("/public/yyq/lty/data/fgoals-g3/hfls_Amon_FGOALS-g3_historical_r1i1p1f1_gn_198001_201412.nc","r")
lhf_f3=addfile("/public/yyq/lty/data/fgoals-f3/hfls_Amon_FGOALS-f3-L_historical_r1i1p1f1_gr_198001-201412.nc","r")
lhf_s2=addfile("/public/yyq/lty/data/fgoals-s2/hfls_Amon_FGOALS-s2_historical_r1i1p1_198001-200412.nc","r")


LHF_oa=clmMonTLL(short2flt(lhf_oa->lhtfl(0:419,:,:)))
LHF_g2=clmMonTLL(lhf_g2->hfls)
LHF_g3=clmMonTLL(lhf_g3->hfls)
LHF_f3=clmMonTLL(lhf_f3->hfls)
LHF_s2=clmMonTLL(lhf_s2->hfls)

printVarSummary(LHF_f3(:,{-2:2},{255:285}))
printVarSummary(LHF_g2(:,{-3:3},{255:285}))
printVarSummary(LHF_g3(:,{-2:2},{255:285}))
printVarSummary(LHF_oa(:,{-2:2},{255:285}))
printVarSummary(LHF_s2(:,{-3:3},{255:285}))
LHF_f3:=dim_avg_n_Wrap(LHF_f3(:,{-2:2},{255:285}),(/1,2/))
LHF_g2:=dim_avg_n_Wrap(LHF_g2(:,{-3:3},{255:285}),(/1,2/))
LHF_g3:=dim_avg_n_Wrap(LHF_g3(:,{-2:2},{255:285}),(/1,2/))
LHF_oa:=dim_avg_n_Wrap(LHF_oa(:,{-2:2},{255:285}),(/1,2/))
LHF_s2:=dim_avg_n_Wrap(LHF_s2(:,{-3:3},{255:285}),(/1,2/))
;standardnize the latent heat flux
;LHF_f3= dim_standardize_Wrap(LHF_f3,1)
;LHF_g2= dim_standardize_Wrap(LHF_g2,1)
;LHF_g3= dim_standardize_Wrap(LHF_g3,1)
;LHF_oa= dim_standardize_Wrap(LHF_oa,1)
;LHF_s2= dim_standardize_Wrap(LHF_s2,1)
print("latent heat flux okay")
;outgoing_longwave_radiation_flux
olr_oa=addfile("/public/yyq/lty/data/obdata/olr_monmean198001_201412.nc","r")
olr_g2=addfile("/public/yyq/lty/data/fgoals-g2/rlut_Amon_FGOALS-g2_historical_r1i1p1_198001_201412.nc","r")
olr_g3=addfile("/public/yyq/lty/data/fgoals-g3/rlut_Amon_FGOALS-g3_historical_r1i1p1f1_gn_198001_201412.nc","r")
olr_f3=addfile("/public/yyq/lty/data/fgoals-f3/rlut_Amon_FGOALS-f3-L_historical_r1i1p1f1_gr_198001-201412.nc","r")
olr_s2=addfile("/public/yyq/lty/data/fgoals-s2/rlut_Amon_FGOALS-s2_historical_r1i1p1_198001-200512.nc","r")


OLR_oa=clmMonTLL(olr_oa->olr)
OLR_g2=clmMonTLL(olr_g2->rlut)
OLR_g3=clmMonTLL(olr_g3->rlut)
OLR_f3=clmMonTLL(olr_f3->rlut)
OLR_s2=clmMonTLL(olr_s2->rlut)

OLR_oa:=dim_avg_n_Wrap(OLR_oa(:,{-2:2},{255:285}),(/1,2/))
OLR_f3:=dim_avg_n_Wrap(OLR_f3(:,{-2:2},{255:285}),(/1,2/))
OLR_g2:=dim_avg_n_Wrap(OLR_g2(:,{-2:2},{255:285}),(/1,2/))
OLR_g3:=dim_avg_n_Wrap(OLR_g3(:,{-2:2},{255:285}),(/1,2/))
OLR_s2:=dim_avg_n_Wrap(OLR_s2(:,{-2:2},{255:285}),(/1,2/))
;standardnize the outgoing longwave radiation
;OLR_f3= dim_standardize_Wrap(OLR_f3,1)
;OLR_g2= dim_standardize_Wrap(OLR_g2,1)
;OLR_g3= dim_standardize_Wrap(OLR_g3,1)
;OLR_oa= dim_standardize_Wrap(OLR_oa,1)
;OLR_s2= dim_standardize_Wrap(OLR_s2,1)
print("outgoing longwave radiation flux okay")



obvar=(/lon_HADsst,lon_GPCPpre,lat_NCEP_V,sw_OA,LHF_oa,OLR_oa/)
s2var=(/lon_SST_s2,lon_PR_s2,LHF_s2,lat_V_s2,sw_S2,OLR_s2/)
g2var=(/lon_SST_g2,lon_PR_g2,lat_V_g2,sw_G2,LHF_g2,OLR_g2/)
g3var=(/lon_SST_g3,lon_PR_g3,lat_V_g3,sw_G3,LHF_g3,OLR_g3/)
f3var=(/lon_SST_f3,lon_PR_f3,lat_V_f3,sw_F3,LHF_f3,OLR_f3/)

sstvar=(/lon_HADsst,lon_SST_s2,lon_SST_g2,lon_SST_g3,lon_SST_f3/)
prvar=(/lon_GPCPpre,lon_PR_s2,lon_PR_g2,lon_PR_g3,lon_PR_f3/)
vvar=(/lat_NCEP_V,lat_V_s2,lat_V_g2,lat_V_g3,lat_V_f3/)
swvar=(/sw_OA,sw_S2,sw_G2,sw_G3,sw_F3/)
lhfvar=(/LHF_oa,LHF_s2,LHF_g2,LHF_g3,LHF_f3/)
olrvar=(/OLR_oa,OLR_s2,OLR_g2,OLR_g3,OLR_f3/)
modelslabel=(/"obseravation","FGOALS_s2","FGOALS_g2","FGOALS_g3","FGOALS_f3"/)
;*******************************************************
;          create plot
;********************************************************
 wks= gsn_open_wks("pdf","var")
 colors=(/"black","blue","red","green","brown","purple"/)
 labels=(/"d(sst)/dt(degC/month)","pre(mm/day)","V_wind(m/s)","net_shortwave(w/m~S~2~N)","latent_heat_flux(w/m~S~2~N)","OLR(w/m~S~2~N)"/)
 months=lon_SST_f3&month
 plot = new(6,graphic)                     ; create graphic array

 res                  		 = True
 res@gsnFrame			 = False
 res@gsnDraw			 = False ; Use plot options
 res@xyLineColors		 =colors 
 res@xyDashPatterns		 =(/0,1,1,1,1,1/)
 res@xyLineThicknesses		 =(/3,2,2,2,2,2/);(/2,1,1,1,1,1/)
 res@lgLabelFontHeightF		 =0.015
 res@lgBoxMinorExtentF		 =0.3
 ;res@trYMinF			 =-2
 ;res@trYMaxF			 =8
 ;res@gsnLeftString		 ="Observation"
res@tmXBMode                    ="Explicit"
res@tmXBValues                  =ispan(0,11,1)
res@tmXBLabels                  =(/"J","F","M","A","M","J","J","A","S","O","N","D"/)
res@pmLegendDisplayMode		 ="Always" 
res@xyExplicitLegendLabels	 =modelslabel
res@pmLegendOrthogonalPosF	 =-1.1
res@pmLegendParallelPosF	 =0.5
res@lgPerimOn			 =False
res@xyDashPattern    		 = 0 

res@gsnLeftString 		 ="d(sst)/dt"
res@gsnRightString		 ="degC/month"
plot(0)=gsn_csm_xy(wks,months,sstvar,res)
 
;res@xyDashPattern    := 1 
res@pmLegendDisplayMode		 ="NoCreate" 
 ;res@gsnLeftString		 ="FGOALS_s2"

res@gsnLeftString 		 ="precipitation"
res@gsnRightString		 ="mm/day"
 plot(1)=gsn_csm_xy(wks,months,prvar,res)
 
;res@xyDashPattern    := 2 
 ;res@gsnLeftString		 ="FGOALS_g2"
 ;res@lbOrientation		 = "vertical"
;res@lbLabelBarOn    		 =True
 ;res@pmLabelBarOrthogonalPosF=-0.025
 ;res@pmLabelBarWidthF=0.06
 ;belFontHeightFres@lbLabelFontHeightF=0.018
 
res@gsnLeftString 		 ="meridional wind"
res@gsnRightString		 ="m/s"
 plot(2)=gsn_csm_xy(wks,months,vvar,res) 
; res@gsnLeftString		 ="FGOALS_g3"

;res@xyDashPattern    := 3 
res@gsnLeftString 		 ="net shortwave radiation"
res@gsnRightString		 ="W/m~S~2~N"
 plot(3)=gsn_csm_xy(wks,months,swvar,res)
 ;res@gsnLeftString		="FGOALS_f3"
 
;res@xyDashPattern    := 4 
res@gsnLeftString 		 ="latent heat flux"
res@gsnRightString		 ="W/m~S~2~N"
 plot(4)=gsn_csm_xy(wks,months,lhfvar,res)
res@gsnLeftString 		 ="outgoing longwave radiation"
res@gsnRightString		 ="W/m~S~2~N"
 plot(5)=gsn_csm_xy(wks,months,olrvar,res)

;draw(plot)
;frame(wks)
 pres				=True
pres@gsnPanelRowSpec = True

gsn_panel(wks,plot,(/2,2,2/),pres)
end

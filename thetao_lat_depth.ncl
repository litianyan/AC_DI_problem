begin
f3=addfile("../data/fgoals-f3/thetaotropical300_Omon_FGOALS-f3-L_historical_r1i1p1f1_gn_198001-200412_regrid.nc","r")
g2=addfile("../data/fgoals-g2/thetaotropical300_Omon_FGOALS-g2_historical_r1i1p1_198001_200412.nc","r")
g3=addfile("../data/fgoals-g3/thetaotropical300_Omon_FGOALS-g3_historical_r1i1p1f1_gn_198001_200412_remap.nc","r")
godas=addfile("../data/obdata/GODAS/pottmptropical300_1980_2004.nc","r")
F3=dim_avg_n_Wrap(f3->thetao,3)
G2=dim_avg_n_Wrap(g2->thetao,3)
G3=dim_avg_n_Wrap(g3->thetao,3)
GODAS=dim_avg_n_Wrap(godas->pottmp,3)
printVarSummary(GODAS)
;season JJA
season="JJA"
JJA_F3=dim_avg_n_Wrap(month_to_season(F3,season),0)
JJA_G2=dim_avg_n_Wrap(month_to_season(G2,season),0)
JJA_G3=dim_avg_n_Wrap(month_to_season(G3,season),0)
JJA_GODAS=dim_avg_n_Wrap(month_to_season(GODAS,season),0)
printVarSummary(JJA_GODAS)
JJA_G2=where(ismissing(JJA_G2),JJA_G2@_FillValue,JJA_G2-273.15)
wks=gsn_open_wks("pdf","thetao_lat_time")
plot=new(4,graphic)
res					=True
res@gsnDraw 				=False
res@gsnFrame         			= False
res@lbLabelBarOn                        =False
res@cnFillOn				=True
res@cnInfoLabelOn                       = False
res@cnLineLabelsOn             	        = False
res@trYReverse			        = True
res@gsnYAxisIrregular2Linear 		= True
res@cnFillPalette			="amwg"
res@cnLevelSelectionMode   		="ManualLevels"
res@cnMaxLevelValF			=29.
res@cnMinLevelValF			=10.
res@cnLevelSpacingF 			=1.
res@gsnRightString			="degC"
res@gsnLeftString			="GODAS"
plot(0)=gsn_csm_contour(wks,JJA_GODAS,res)
res@gsnLeftString			="FGOALS-g2"
plot(1)=gsn_csm_contour(wks,JJA_G2,res)
res@gsnLeftString			="FGOALS-g3"
plot(2)=gsn_csm_contour(wks,JJA_G3,res)
res@gsnLeftString			="FGOALS-f3"
plot(3)=gsn_csm_contour(wks,JJA_F3,res)
;plot(2)=gsn_csm_contour(wks,F3,res)
pres                           =True
pres@gsnPanelLabelBar= True
gsn_panel(wks,plot,(/2,2/),pres)
end

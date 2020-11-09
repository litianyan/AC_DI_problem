begin
;read file

f3=addfile("/public/yyq/lty/data/fgoals-f3/rsntdstropical_Omon_FGOALS-f3-L_historical_r1i1p1f1_gn_198501-200412_regrid.nc","r")
g2=addfile("/public/yyq/lty/data/fgoals-g2/rsntdstropical_Amon_FGOALS-g2_historical_r1i1p1_198001_200412.nc","r")
g3=addfile("/public/yyq/lty/data/fgoals-g3/rsntdstropical_Omon_FGOALS-g3_historical_r1i1p1f1_gn_198501_200412_remap.nc","r")
oa=addfile("/public/yyq/lty/data/obdata/oaflux_sw_1985-2004.nc","r")
;read variable
printVarSummary(oa->NSWRS)

F3=clmMonTLL(f3->rsntds)
G2=clmMonTLL(g2->rsndts)
G3=clmMonTLL(g3->rsntds)
OA=clmMonTLL(lonFlip(oa->NSWRS))
OA:=OA(:,{-2:2},{140:280})
printVarSummary(F3)
printVarSummary(G2)
printVarSummary(G3)
printVarSummary(OA)
;
clm_F3=F3-conform_dims((/12,4,140/),dim_avg_n_Wrap(F3,0),(/1,2/))
clm_G2=G2-conform_dims((/12,2,50/),dim_avg_n_Wrap(G2,0),(/1,2/))
clm_G3=G3-conform_dims((/12,4,141/),dim_avg_n_Wrap(G3,0),(/1,2/))
clm_OA=OA-conform_dims((/12,4,140/),dim_avg_n_Wrap(OA,0),(/1,2/))
printVarSummary(clm_F3)
printVarSummary(clm_G2)
printVarSummary(clm_G3)
printVarSummary(clm_OA)
clm_F3!2="lon"
clm_F3&lon=F3&lon
clm_G2!2="lon"
clm_G2&lon=G2&lon
clm_G3!2="lon"
clm_G3&lon=G3&lon
clm_OA!2="lon"
clm_OA&lon=OA&LONN179_180
printVarSummary(clm_F3)
clm_F3:=dim_avg_n_Wrap(clm_F3,1)
clm_G2:=dim_avg_n_Wrap(clm_G2,1)
clm_G3:=dim_avg_n_Wrap(clm_G3,1)
clm_OA:=dim_avg_n_Wrap(clm_OA,1)

printVarSummary(clm_F3)
;******************************************
; create plot
;*****************************************
print(max(clm_F3))
print(max(clm_G2))
print(max(clm_G3))
print(max(clm_OA))
print(min(clm_F3))
print(min(clm_G2))
print(min(clm_G3))
print(min(clm_OA))
wks=gsn_open_wks("pdf","rsntds_lon_time")
plot=new(4,graphic)
res					=True
res@tmXBMode="manual"
res@tmXBTickStartF=140.
res@tmXBTickSpacingF =20.
;set time labels to months tmYLMode /tmXBMode
 res@tmYLMode			 ="Explicit"
 res@tmYLValues			 =ispan(0,11,1)
 res@tmYLLabels			 =(/"J","F","M","A","M","J","J","A","S","O","N","D"/)
res@gsnDraw 				=False
res@gsnFrame         			= False
res@lbLabelBarOn                        =False
res@cnFillOn				=True
res@cnInfoLabelOn                       = False
res@cnLineLabelsOn             	        = False
res@cnFillPalette			="amwg"
res@cnLevelSelectionMode   		="ManualLevels"
res@cnMaxLevelValF			=40.
res@cnMinLevelValF			=-40.
res@cnLevelSpacingF 			=5.
;res@gsnRightString			="degC"
res@gsnLeftString			="OA_flux"
plot(0)=gsn_csm_contour(wks,clm_OA,res)
res@gsnLeftString			="FGOALS-g2"
plot(1)=gsn_csm_contour(wks,clm_G2,res)
res@gsnLeftString			="FGOALS-g3"
plot(2)=gsn_csm_contour(wks,clm_G3,res)
res@gsnLeftString			="FGOALS-f3"
plot(3)=gsn_csm_contour(wks,clm_F3,res)
;plot(2)=gsn_csm_contour(wks,F3,res)
pres                           =True
pres@gsnPanelLabelBar= True
gsn_panel(wks,plot,(/2,2/),pres)
end

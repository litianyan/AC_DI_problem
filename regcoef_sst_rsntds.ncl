

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"      ; These four libraries are automatically
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"       ; loaded from NCL V6.4.0 onward.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   ; No need for user to explicitly load.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
;read sst and rsntds
fo1  =   addfile("../data/obdata/oaflux_sw_1985-2004.nc", "r")
fo2  =   addfile("../data/fgoals-g2/rsntds_Amon_FGOALS-g2_historical_r1i1p1_198501_200412_remap.nc", "r")
fo3  =   addfile("../data/fgoals-g3/rsntds_Omon_FGOALS-g3_historical_r1i1p1f1_gn_198501_200912_remap.nc", "r")
fo4  =   addfile("../data/fgoals-f3/rsntds_Omon_FGOALS-f3-L_historical_r1i1p1f1_gn_198001-201412_regrid.nc","r")

ss1=rmMonAnnCycTLL(lonFlip(fo1->NSWRS))
ss2  =rmMonAnnCycTLL(fo2->rsndts)
ss3  =   rmMonAnnCycTLL(fo3->rsntds(0:20*12-1,:,:))
ss4  =  rmMonAnnCycTLL(fo4->rsntds(5*12:25*12-1,:,:))

;ss1= lonFlip(fo1->NSWRS)
;ss2  = fo2->rsndts
;ss3  =    fo3->rsntds(0:20*12-1,:,:)
;ss4  =   fo4->rsntds(5*12:25*12-1,:,:)

fu1  =   addfile("../data/obdata/HADLSST/HadISST_sst_regrid.nc", "r")
fu2  =   addfile("../data/fgoals-g2/tos_Omon_FGOALS-g2_historical_r1i1p1_198001-200412_remap.nc", "r")
fu3  =   addfile("../data/fgoals-g3/tos_Omon_FGOALS-g3_historical_r1i1p1f1_gn_198001-201412_remap.nc", "r")
fu4  =   addfile("../data/fgoals-f3/tos_Omon_FGOALS-f3-L_historical_r1i1p1f1_gn_185001-201412_regrid.nc","r")


ssthad=fu1->sst(115*12:135*12-1,:,:)
a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
lsdata = a->LSMASK
lsm  = landsea_mask(lsdata,ssthad&lat,ssthad&lon)
n_time=dimsizes(ssthad&time)
 do i=0,n_time-1
	 ssthad(i,:,:) = mask(ssthad(i,:,:),lsm.eq.1,False)
 end do
ssthad=where(ssthad.eq.-1000.0,ssthad@_FillValue,ssthad)
ssthad=where(ssthad.eq.-1.8,ssthad@_FillValue,ssthad)
ssthad=where(.not.ismissing(ssthad),ssthad+273.15,ssthad@_FillValue)
sst_g2=fu2->tos(5*12:25*12-1,:,:)
sst_g3=fu3->tos(5*12:25*12-1,:,:)
sst_f3=fu4->tos(135*12:155*12-1,:,:)

sst_g3=where(.not.ismissing(sst_g3),sst_g3+273.15,sst_g3@_FillValue)
sst_f3=where(.not.ismissing(sst_f3),sst_f3+273.15,sst_f3@_FillValue)
su1  =rmMonAnnCycTLL(ssthad)
su2  = rmMonAnnCycTLL(sst_g2)
su3  = rmMonAnnCycTLL(sst_g3)
su4  =rmMonAnnCycTLL(sst_f3) 

ss1:=ss1(LAT|:,LONN179_180|:,TIME|:)
su1:=su1(lat|:,lon|:,time|:)

ss2:=ss2(lat|:,lon|:,time|:)
su2:=su2(lat|:,lon|:,time|:)
ss3:=ss3(lat|:,lon|:,time|:)
su3:=su3(lat|:,lon|:,time|:)
ss4:=ss4(lat|:,lon|:,time|:)
su4:=su4(lat|:,lon|:,time|:)
;printVarSummary(ss1)
;printVarSummary(su1)

;printVarSummary(ss2)
;printVarSummary(su2)
;printVarSummary(ss3)
;printVarSummary(su3)
;printVarSummary(ss4)
;printVarSummary(su4)
rc1=escorc(ss1,su1)
   ;printVarSummary(rc1) 
    rc1!0="lat"
    rc1!1="lon"
    rc1&lat=su1&lat
    rc1&lon=su1&lon
    
rc2=escorc(ss2,su2)
   ;printVarSummary(rc1) 
;rc1=rc1*10
    rc2!0="lat"
    rc2!1="lon"
    rc2&lat=su2&lat
    rc2&lon=su1&lon
    
rc3=escorc(ss3,su3)
   ;printVarSummary(rc1) 
;rc1=rc1*10
    rc3!0="lat"
    rc3!1="lon"
    rc3&lat=su3&lat
    rc3&lon=su3&lon
rc4=escorc(ss4,su4)
   ;printVarSummary(rc1) 
;rc1=rc1*10
    rc4!0="lat"
    rc4!1="lon"
    rc4&lat=su4&lat
    rc4&lon=su4&lon
    
    ; **********************************************
    wks=gsn_open_wks("pdf","test")
   plot=new(4,graphic)
    gsn_define_colormap(wks,"GMT_panoply")
    res=True
    res@gsnFrame=False
    res@gsnDraw=False
    res@gsnAddCyclic=False             ;如果设置为真，则循环点被加入数据，如果数据不是循环的，就设置为假就可以。
    res@cnFillOn=True;画填充图
    res@cnLinesOn=False;不画等值线
    res@cnLineLabelsOn=False;不要等值线上的标签
    res@cnLevelSelectionMode= "ManualLevels"
    res@cnMinLevelValF      = -0.8
    res@cnMaxLevelValF      = 0.8
    res@cnLevelSpacingF     = 0.1
    bres=res
    res0=res

    bres@mpMinLatF=-20.0
    bres@mpMaxLatF=20.0
    bres@mpMinLonF=180.0
    bres@mpMaxLonF=290.0
    bres@mpCenterLonF=235.
    bres@tiMainString=""
    bres@cnFillDrawOrder="PreDraw";先画填充
    ;bres@cnMinLevelValF=-26.
    ;bres@cnMaxLevelValF=26.
    ;bres@cnLevelSpacingF =1
    bres@gsnLeftString="HadlSST(SST),OA_flux(Net_SW_Radiation_Flux)"
    plot(0)=gsn_csm_contour_map(wks,rc1,bres)
    ;plot2=gsn_csm_contour(wks,prob,res0)
    ;overlay(plot1,plot2)
    bres@gsnLeftString="FGOALS_g2_Historical"
    plot(1)=gsn_csm_contour_map(wks,rc2,bres)
    bres@gsnLeftString="FGOALS_g3_Historical"
    plot(2)=gsn_csm_contour_map(wks,rc3,bres)
    bres@gsnLeftString="FGOALS_f3_Historical"
    plot(3)=gsn_csm_contour_map(wks,rc4,bres)
    resP                = True                ; panel only resources
    ;resP@gsnMaximize    = True                ; maximize plots
    gsn_panel(wks,plot,(/2,2/),resP)     
    end

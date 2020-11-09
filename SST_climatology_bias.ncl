;----------------------------------------------------------------------
; panel_18.ncl
;
; Concepts illustrated:
;   - Combining two sets of paneled plots on one page
;   - Maximizing plots after they've been created
;   - Using cnFillPalette to assign a color palette to contours
;----------------------------------------------------------------------
; This script is similar to panel_18_old.ncl, except a function called
; "panel_two_sets" was used to make it easier to panel two sets of
; plots.
;
; This function enables you to panel two sets of contour plots on the
; same page, each with its own labelbar. The function will determine
; whether to use horizontal or vertical labelars, depending on how
; the two sets of plots are laid out in terms of rows and columns.
;----------------------------------------------------------------------
; You must download panel_two_sets.ncl for this script to run.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;----------------------------------------------------------------------
load "panel_two_sets.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"      ; These four libraries are automatically
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"       ; loaded from NCL V6.4.0 onward.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   ; No need for user to explicitly load.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin

    fo1  =   addfile("../data/obdata/HADLSST/HadISST_sst_regrid.nc", "r")
    fo2  =   addfile("../data/fgoals-g2/tos_Omon_FGOALS-g2_historical_r1i1p1_198001-200412_remap.nc", "r")
    fo3  =   addfile("../data/fgoals-g3/tos_Omon_FGOALS-g3_historical_r1i1p1f1_gn_198001-201412_remap.nc", "r")
    fo4  =   addfile("../data/fgoals-f3/tos_Omon_FGOALS-f3-L_historical_r1i1p1f1_gn_185001-201412_regrid.nc","r")
    ss1  =   fo1->sst(110*12:135*12-1,:,:)
    ss2  =   fo2->tos(:,:,:)
    ss2=where(ismissing(ss2),ss2@_FillValue,ss2-273.15) 
    ss2@units="degC"
    ss3  =   fo3->tos(0:25*12-1,:,:)
    ss4  =   fo4->tos(130*12:155*12-1,:,:)
   
    printVarSummary(ss4)

    ;HadlSST
     a    = addfile("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
     lsdata = a->LSMASK
     lsm  = landsea_mask(lsdata,ss1&lat,ss1&lon)
     n_time=dimsizes(ss1&time)
      do i=0,n_time-1
	      ss1(i,:,:) = mask(ss1(i,:,:),lsm.eq.1,False)
      end do
    ;climatology
    clm_ss1=dim_avg_n_Wrap(ss1,0)
    clm_ss2=dim_avg_n_Wrap(ss2,0)
    clm_ss3=dim_avg_n_Wrap(ss3,0)
    clm_ss4=dim_avg_n_Wrap(ss4,0)
    printVarSummary(clm_ss4)
    ;bias
    bias2    =clm_ss2-clm_ss1
copy_VarCoords(clm_ss1,bias2)
    bias3   = clm_ss3-clm_ss1
copy_VarCoords(clm_ss1,bias3)
    bias4   =clm_ss4-clm_ss1
copy_VarCoords(clm_ss1,bias4)
;---Plot
    wks  = gsn_open_wks("pdf","climbias_SST")         ; send graphics to PNG file
    
  res                     = True
  res@gsnDraw             = False
  res@gsnFrame            = False
  res@mpFillOn            = False            ; no need   
  res@cnLevelSelectionMode= "ManualLevels"   ; manual set levels
  res@cnMinLevelValF      = -3. ;28.0
  res@cnMaxLevelValF      = 3.  ;37.0
  res@cnLevelSpacingF     = 0.5              ; 20 contour levels        
  res@cnFillOn            = True             ; color fill plot
  res@cnFillPalette       = "BlueWhiteOrangeRed" ;"BlueYellowRed";"BlAqGrYeOrRe"
  res@cnLinesOn           = False
  res@cnLineLabelsOn      = False
  res@cnInfoLabelOn       = False
  res@lbLabelBarOn        = False            ; turn off individual label bars
  res@mpCenterLonF        = 180.
 res@mpMinLonF              =   100
res@mpMaxLonF              = 300
res@mpMinLatF            = -30
res@mpMaxLatF            = 30
  res@tmXBLabelFontHeightF                 = 0.028
  res@tmXBLabelStride                      = 2
  res@tmYLLabelFontHeightF                 = 0.028
  res@gsnLeftStringFontHeightF             = 0.028
  res@gsnCenterStringFontHeightF           = 0.028
  res@gsnRightStringFontHeightF            = 0.028
  res@tiYAxisFontHeightF                   = 0.028
  res@tiXAxisFontHeightF                   = 0.028
  res@tiMainFontHeightF                    = 0.028
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
    ;res@lbLabelStrings      = sprintf("%4.1f",ispan(280,470,5)*0.1)

    plot = new(3,graphic)    
    
    res@gsnLeftString       = "(a)"
    res@gsnRightString      = "degC"

    res@gsnCenterString     = "FGOALS-g2"
    plot(0) = gsn_csm_contour_map(wks,bias2(:,:),res)

    res@gsnLeftString       = "(b)"
    res@gsnCenterString     = "FGOALS-g3"
    plot(1) = gsn_csm_contour_map(wks,bias3(:,:),res)

    res@gsnLeftString       = "(c)"
    res@gsnCenterString     = "FGOALS-f3"
    plot(2) = gsn_csm_contour_map(wks,bias4(:,:),res)
    
    sres                     = res
    sres@cnMinLevelValF      = 14.0
    sres@cnMaxLevelValF      = 30.0
    sres@cnLevelSpacingF     = 1.
    sres@cnFillOn            = False 
    sres@cnLinesOn           = True
    sres@cnLineLabelsOn                       = True      ; turns off contour line labels
    sres@cnLineLabelInterval                  = 1
    sres@cnLineLabelPlacementMode             = "Computed"
    sres@cnLineLabelDensityF                  = 1.5
    sres@gsnContourZeroLineThicknessF         = 3.0
    sres@cnLineLabelFontHeightF               = 0.018
    sres@cnLineLabelPerimSpaceF               = 0.12
    sres@gsnLeftString                        = ""
    sres@gsnCenterString                      = ""
    sres@gsnRightString                       = ""
    plot_ov0 = gsn_csm_contour(wks,clm_ss2(:,:),sres)
    plot_ov1 = gsn_csm_contour(wks,clm_ss3(:,:),sres)
    
    plot_ov2 = gsn_csm_contour(wks,clm_ss4(:,:),sres)
    overlay(plot(0),plot_ov0)
    overlay(plot(1),plot_ov1)
    overlay(plot(2),plot_ov2)
    
    res@cnMinLevelValF      =  14.
    res@cnMaxLevelValF      =  30.
    res@cnLevelSpacingF     =  1.
    res@cnLinesOn           = True
    res@cnLineLabelsOn                       = True      ; turns off contour line labels
    res@cnLineLabelInterval                  = 1
    res@cnLineLabelPlacementMode             = "Computed"
    res@cnLineLabelDensityF                  = 1.5
    res@gsnContourZeroLineThicknessF         = 3.0
    res@cnLineLabelFontHeightF               = 0.018
    res@cnLineLabelPerimSpaceF               = 0.12
    res@cnFillPalette       = "BlueYellowRed"    ; select a color map with white in the middle
    res@gsnLeftString       = "(d)"
    res@gsnCenterString     = "Observation"

;---Formatting the labelbar strings helps make the two sets of labelbars match better
    ;res@lbLabelStrings      := sprintf("%4.1f",ispan(-40,40,5)*0.1)
    plot2 = gsn_csm_contour_map(wks, clm_ss1 ,res)
    
;---Panel the two sets of plots. Note no special resources need to be set.
    pres1 = True
    pres1@pmLabelBarWidthF  = 0.05
    pres1@lbLabelJust       = "CenterLeft"
    pres2 = True
    pres2@pmLabelBarWidthF  = 0.05
    pres2@lbLabelJust       = "CenterLeft"
    pres  = True
    panel_two_sets(wks,plot,plot2,(/3,1/),(/1,1/),pres1,pres2,pres)
end
    

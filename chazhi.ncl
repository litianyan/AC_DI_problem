load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"  ; This library is automatically loaded 

begin
f=addfile("/data02/lity/GPI/data/casesm/tos_Omon_CAS-ESM2-0_historical_r1i1p1f1_gn_185001-201412.nc","r")



f=addfile("/data02/lity/GPI/data/amip/HadISST_sst.nc","r");187001_202001
sst=f->sst(1296:1739,::-1,:)
printVarSummary(sst)
sst=lonFlip(sst)
printVarSummary(sst)
sst=where((sst.eq.-1000).or.(sst.eq.-1.8),sst@_FillValue,sst)
sst=where(ismissing(sst),1e+20,sst)
sst@_FillValue=1e+20
sst@missing_value=sst@_FillValue

g=addfile("/data02/lity/GPI/data/amip/psl_Amon_CAS-ESM2-0_amip_r1i1p1f1_gn_197801-201412.nc","r")
newlat = g->lat
newlon = g->lon


newtos = linint2(sst&longitude,sst&latitude,sst,True,newlon,newlat,0)
newtos!0="time"
newtos!1="lat"
newtos!2="lon"
newtos&time=g->time
newtos&lat=newlat
newtos&lon=newlon
printVarSummary(newtos)
newtos&lon@units="degrees_east"
newtos@long_name = "tos"

setfileoption("nc","Format","LargeFile")
;system("rm -rf /data02/lity/GPI/data/amip/HadlSST_amip_197801-201412_1.4*1.4.nc ")
;fout = addfile("/data02/lity/GPI/data/amip/HadlSST_amip_197801-201412_1.4*1.4.nc","c") 


fout->tos=newtos

;****plot***to***test********************
sst_5=dim_avg_n_Wrap(newtos,0)
wks=gsn_open_wks("png","tos_amip1978_2014")
gsn_define_colormap(wks,"BlueDarkRed18")

res                  =True
res@cnFillOn         =True
res@cnLinesOn        =False
;res@gsnAddCyclic=False
res@cnFillMode = "RasterFill"
res@cnRasterSmoothingOn = True
res@mpMinLonF              =  0
res@mpMaxLonF              = 360
res@mpCenterLonF           = 180 
res@mpMinLatF            = -60
res@mpMaxLatF            = 60
plot=gsn_csm_contour_map(wks,sst_5,res)



end

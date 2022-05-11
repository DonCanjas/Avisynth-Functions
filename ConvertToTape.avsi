###############################
##       ConvertToTape       ##
##     v1.0 by DonCanjas     ##
##        11 may 2022        ##
###############################

#Requirements:
# Dehalo_alpha   
# AddGrainC


Function ConvertToTape(clip c2,  int "bleedsize", float "halo_x", float "halo_y", int "halostr", bool "useColorYUV", bool "useLimitRange", int "min_luma", int "max_luma", int "min_chroma", int "max_chroma", float "paramscale", float "var", float "uvar", float "hcorr", float "vcorr", float "sat") 
{

#Presets

bleedsize = Default(bleedsize, 6)

halostr = Default(halostr, 2)
halo_x = Default(halo_x, 5)

halo_y = Default(halo_y, 5)

useColorYUV =  Default(useColorYUV, True)
useLimitRange = Default(useLimitRange, False)
min_luma = Default(min_luma, 16)
max_luma = Default(max_luma, 235)
min_chroma = Default(min_chroma, 16)
max_chroma = Default(max_chroma, 240)
paramscale = Default(paramscale, false)


var = Default(var, 20)
uvar = Default(uvar, 15)
hcorr = Default(hcorr, 0.8)
vcorr = Default(vcorr, 0.05)

sat =  Default(sat, 1.4)

##############################################################

pixel = PixelType(c2)
pixelstring = String(pixel)

src = c2

U = src.Extractu()
V = src.Extractv()

U2 = U.blur(1.58).blur(1.58).crop(bleedsize,0,0,0).bilinearresize(width(u), height(u))
V2 = V.blur(1.58).blur(1.58).crop(0,0,-bleedsize,0).bilinearresize(width(v), height(v))
Y = src.Extracty().blur(1)

CombinePlanes(Y, U, V, planes="YUV", source_planes="YYY", sample_clip=src, pixel_type=pixelstring)


dehalo_alpha(rx=halo_x, ry=halo_y, darkstr=-halostr, brightstr=-halostr)


(useLimitRange==true) ? last.Limiter(min_luma=min_luma, max_luma=max_luma, min_chroma=min_chroma, max_chroma=max_chroma, paramscale=paramscale) : last
(useColorYUV==true) ? last.ColorYUV(levels="PC->tv") : last


AddGrainC(var=var, uvar=uvar, hcorr=hcorr, vcorr=vcorr)


pointresize(width(src)/2, height(src)/2)
bilinearresize(width(src), height(src))


Tweak(sat=sat)


}

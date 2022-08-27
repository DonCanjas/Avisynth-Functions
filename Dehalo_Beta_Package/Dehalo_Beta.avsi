#Dehalo_Beta: a fork of DeHalo_alpha_MT2 with 32 bit float support. 
#Requirements: avs+, masktools2, RemoveGrain & avsresize. 
#Supported formats: YUV[A] & Y (8-32 bit), progressive only.
#2022.08.27

function DeHalo_Beta_mt(clip input, float "rx", float "ry", float "darkstr", float "brightstr", float "lowsens", float "highsens", float "ss", bool "cs", int "search_rade", int "search_radi", bool "useplacebo")
{
sre       = default( search_rade,   1 )
sri       = default( search_radi, sre )
useplacebo = Default(useplacebo, False)

input

(useplacebo == False) ? DeHalo_Beta(rx, ry, darkstr, brightstr, lowsens, highsens, ss, cs, sre, sri) : DeHalo_Beta_placebo(rx, ry, darkstr, brightstr, lowsens, highsens, ss, cs, sre, sri)
}

# modified dehalo_alpha: here with increased search-radius for validation

function DeHalo_Beta(clip input, float "rx", float "ry", float "darkstr", float "brightstr", float "lowsens", float "highsens", float "ss", bool "cs", int "search_rade", int "search_radi")
{


rx        = default( rx,        2.0 )
ry        = default( ry,        rx )
darkstr   = default( darkstr,   0.0 )
brightstr = default( brightstr, 1.0 )
lowsens   = default( lowsens,    50 )
highsens  = default( highsens,   50 )
ss        = default( ss,        1.5 )
cs        = default( cs,      false )
sre       = default( search_rade,  max(m4_sh(max(rx,ry)),3) )
sri       = default( search_radi, sre )


Assert(!isRGB(input), "DeHalo_Beta: Only YUV[A] and Y supported")


pixel = PixelType(input)
pixelstring = String(pixel)


clp = isy(input) ? input : input.ExtractY() 

U = isy(input) ? nop() : input.ExtractU()
V = isy(input) ? nop() : input.Extractv()

A = isyuva(input) ? input.ExtractA() : nop()


LOS = string(lowsens)
HIS = string(highsens/100.0)
DRK = string(darkstr)
BRT = string(brightstr)
ox  = clp.width()
oy  = clp.height()


dehalo  = clp.z_BicubicResize(m4_sh(ox/rx),m4_sh(oy/ry), b=1/3, c=1/3).z_BicubicResize(ox,oy,b=1,c=0)

clp_minmax    = sre==1 && sri==1 ? clp.mt_edge(mode="min/max", thY1=0, thY2=255)  : mt_lutxy(clp.spasses(sre,"mt_expand()"),clp.spasses(sri,"mt_inpand()"),"x y -",use_expr=3,U=1,V=1)
dehalo_minmax   = sre==1 && sri==1 ? dehalo.mt_edge(mode="min/max", thY1=0, thY2=255) : mt_lutxy(dehalo.spasses(sre,"mt_expand()"),dehalo.spasses(sri,"mt_inpand()"),"x y -",use_expr=3,U=1,V=1)

mask     = mt_lutxy( dehalo_minmax, clp_minmax, "y x - y 0.001 + / range_max * "+LOS+" scalef - y range_size + 512 scalef / "+HIS+" + *",clamp_float=true, scale_inputs="floatf",use_expr=1 )
lets   = mt_merge(dehalo,clp,mask,U=1,V=1)

remove = (ss==1.0) ? clp.repair(lets,1,0) 
\ : clp.z_LanczosResize(m4_sh(ox*ss),m4_sh(oy*ss), taps=3)
\ .mt_logic(lets.mt_expand(U=1,V=1).z_BicubicResize(m4_sh(ox*ss),m4_sh(oy*ss), b=1/3, c=1/3),"min",U=2,V=2)
\ .mt_logic(lets.mt_inpand(U=1,V=1).z_BicubicResize(m4_sh(ox*ss),m4_sh(oy*ss), b=1/3, c=1/3),"max",U=2,V=2)
\ .z_LanczosResize(ox,oy, taps=3)
them   =  mt_lutxy(clp,remove,"x y < x x y - "+DRK+" * - x x y - "+BRT+" * - ?",use_expr=1,U=2,V=2)

bb   = cs ? them.removegrain(11) : nop()
xD   = cs ? mt_makediff(bb,bb.repair(bb.repair(bb.medianblur(2,-333,-333),1),1)) : nop()
xD   = cs ? xD.mt_lut("x range_half - 2.49 * range_half +",use_expr=1) : xD
xDD  = cs ? mt_lutxy(xD,mt_makediff(clp,them),"x range_half - y range_half - * 0 < range_half x range_half - abs y range_half - abs < x y ? ?",use_expr=1) : nop()
them = cs ? them.mt_adddiff(xDD,U=2,V=2) : them

output   = isy(input) ? them : isyuva(input) ? CombinePlanes(them, U, V, A, planes="YUVA", source_planes="YYYY", pixel_type=pixelstring, sample_clip=input) : CombinePlanes(them, U, V, planes="YUV", source_planes="YYY", pixel_type=pixelstring, sample_clip=input)

output
}

#Dehalo_Beta_placebo: DeHalo_Beta but with avslibplacebo resampling.
#Requirements: avs+ r3682 or higher, masktools2, RemoveGrain & avslibplacebo. 
#Supported formats: YUV[A] & Y (8, 16 or 32 bit), progressive only.
#2022.07.18

# modified dehalo_alpha: here with increased search-radius for validation

function DeHalo_Beta_placebo(clip input, float "rx", float "ry", float "darkstr", float "brightstr", float "lowsens", float "highsens", float "ss", bool "cs", int "search_rade", int "search_radi")
{


rx        = default( rx,        2.0 )
ry        = default( ry,        rx )
darkstr   = default( darkstr,   0.0 )
brightstr = default( brightstr, 1.0 )
lowsens   = default( lowsens,    50 )
highsens  = default( highsens,   50 )
ss        = default( ss,        1.5 )
cs        = default( cs,      false )
sre       = default( search_rade,  max(m4_sh(max(rx,ry)),3) )
sri       = default( search_radi, sre )


Assert(!isRGB(input), "DeHalo_Beta: Only YUV[A] and Y supported")


pixel = PixelType(input)
pixelstring = String(pixel)


clp = isy(input) ? input : input.ExtractY() 

U = isy(input) ? nop() : input.ExtractU()
V = isy(input) ? nop() : input.Extractv()

A = isyuva(input) ? input.ExtractA() : nop()


LOS = string(lowsens)
HIS = string(highsens/100.0)
DRK = string(darkstr)
BRT = string(brightstr)
ox  = clp.width()
oy  = clp.height()


dehalo  = clp.libplacebo_Resample(m4_sh(ox/rx), m4_sh(oy/ry), filter="mitchell").libplacebo_Resample(ox,oy, filter="bicubic", param1=1, param2=0)

clp_minmax    = sre==1 && sri==1 ? clp.mt_edge(mode="min/max", thY1=0, thY2=255)  : mt_lutxy(clp.spasses(sre,"mt_expand()"),clp.spasses(sri,"mt_inpand()"),"x y -",use_expr=3,U=1,V=1)
dehalo_minmax   = sre==1 && sri==1 ? dehalo.mt_edge(mode="min/max", thY1=0, thY2=255) : mt_lutxy(dehalo.spasses(sre,"mt_expand()"),dehalo.spasses(sri,"mt_inpand()"),"x y -",use_expr=3,U=1,V=1)

mask     = mt_lutxy( dehalo_minmax, clp_minmax, "y x - y 0.001 + / range_max * "+LOS+" scalef - y range_size + 512 scalef / "+HIS+" + *",clamp_float=true, scale_inputs="floatf",use_expr=1 )
lets   = mt_merge(dehalo,clp,mask,U=1,V=1)

remove = (ss==1.0) ? clp.repair(lets,1,0) 
\ : clp.libplacebo_Resample(m4_sh(ox*ss),m4_sh(oy*ss), filter="lanczos", radius=3)
\ .mt_logic(lets.mt_expand(U=1,V=1).libplacebo_Resample(m4_sh(ox*ss),m4_sh(oy*ss), filter="mitchell"),"min",U=2,V=2)
\ .mt_logic(lets.mt_inpand(U=1,V=1).libplacebo_Resample(m4_sh(ox*ss),m4_sh(oy*ss), filter="mitchell"),"max",U=2,V=2)
\ .libplacebo_Resample(ox,oy, filter="lanczos", radius=3)
them   =  mt_lutxy(clp,remove,"x y < x x y - "+DRK+" * - x x y - "+BRT+" * - ?",use_expr=1,U=2,V=2)

bb   = cs ? them.removegrain(11) : nop()
xD   = cs ? mt_makediff(bb,bb.repair(bb.repair(bb.medianblur(2,-333,-333),1),1)) : nop()
xD   = cs ? xD.mt_lut("x range_half - 2.49 * range_half +",use_expr=1) : xD
xDD  = cs ? mt_lutxy(xD,mt_makediff(clp,them),"x range_half - y range_half - * 0 < range_half x range_half - abs y range_half - abs < x y ? ?",use_expr=1) : nop()
them = cs ? them.mt_adddiff(xDD,U=2,V=2) : them

output   = isy(input) ? them : isyuva(input) ? CombinePlanes(them, U, V, A, planes="YUVA", source_planes="YYYY", pixel_type=pixelstring, sample_clip=input) : CombinePlanes(them, U, V, planes="YUV", source_planes="YYY", pixel_type=pixelstring, sample_clip=input)

output
}

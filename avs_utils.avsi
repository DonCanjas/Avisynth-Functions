####################################
###                              ###
###     doncanjas presents:      ###
###     don's utils              ###
###     05-04-2025 - r1          ###
###                              ###
####################################

### avs_utils version 05-04-2023
### Meme hearders aside, these are a collection of functions I either use or think that might be useful.
### Everything is written with avs+ in mind.

### avs_utils version 01-11-2023
### Fixed pack3rgb() that would use only clip c

### avs_utils version 02-11-2023
### packrgb() was upgraded in order to deprecate and delete pack3rgb()

### avs_utils version 25-04-2024 - Carnation Revolution update
### mirrorborders() isn't limited to a single value for all borders anymore
### s_addborders() was added
### padmod() was added

### avs_utils version 29-04-2024
### Fixed identations
### fixtvgamma() was added

### avs_utils version 30-04-2024 - r1
### changed fixtvgamma() to operate at 32 bit
### sfillborders() was added
    ### avs_utils version 30-04-2024 - r2
    ### added addborder param to sfillborders()
    ### fixed typos

### avs_utils version 05-05-2024 - r1
### linearscaling() was added
### add TODO to fixtvgamma()

### avs_utils version 05-04-2025 - r1
### bgrtorgb() and gbrtorgb() were added


### Included Functions
###
### scrop()
###
### sborders()
###
### sfillborders()
###
### padmod()
###
### mirrorborders()
###
### limitRGBPS()
###
### packrgb()
###
### fixtvgamma()
###
### linearscaling()
###
### bgrtorgb()
###
### gbrtorgb()
#######################


# scrop()
#
# A wrapper for avs' internal function Crop(). S stands for Sane, Schizo, or whatever else you decide.
# It was written to drop the need for negative numbers and change the param order to make it function like vapoursynth's std.Crop().

Function scrop(clip c, int "left", int "right", int "top", int "bottom", bool "align")
{

    left = Default(left, 0)
    right = Default(right, 0)
    top = Default(top, 0)
    bottom = Default(bottom, 0)
    
    c.crop(left, top, -right, -bottom, align)

}



# sborders()
#
# A wrapper for avs' internal function AddBorders(). S stands for Sane, Schizo, or whatever else you decide.
# It was written to change the param order to make it function like scrop().

Function sborders(clip c, int "left", int "right", int "top", int "bottom", int "color")
{
    
    left = Default(left, 0)
    right = Default(right, 0)
    top = Default(top, 0)
    bottom = Default(bottom, 0)
    color = Default(color, $000000)
    
    c.AddBorders(left, top, right, bottom, color)
    
}



# sfillborders()
#
# Wrapper for FillBorders. It'll add borders by default, unless addborder=false.
# Changes param order to make it function like sborders().
#
# Dependencies:
#       FillBorders: https://github.com/Asd-g/AviSynth-FillBorders

Function sfillborders(clip c, int "left", int "right", int "top", int "bottom", int "mode", bool "addborder", int "y", int "u", int "v")
{
    
    left = Default(left, 0)
    right = Default(right, 0)
    top = Default(top, 0)
    bottom = Default(bottom, 0)
    mode = Default(mode, 0)
    addborder = Default(addborder, true)
    y = Default(y, 3)
    u = Default(u, 3)
    v = Default(v, 3)

    borders = addborder ? c.AddBorders(left, top, right, bottom) : c
    borders.FillBorders(left=left, top=top, right=right, bottom=bottom, mode=mode, y=y, u=u, v=v)

}



# padmod()
#
# Pads clip to mod x by mirroring borders.
# #Based on: https://github.com/Vodes/vodesfunc/blob/master/vodesfunc/scale.py#L308-L320 - 25/04/2024
#
# min: minimum ammount to pad (default: 0)
# mod: desired output resolution's module (default: 4)
#
# Dependencies:
#       avsresize

Function padmod(clip c, int "min", int "mod")
{

    min = Default(min, 0)
    mod = Default(mod, 4)
    
    og_w = Width(c)
    og_h = Height(c)
    
    w = og_w + min * 2
    h = og_h + min * 2
    
    ph = mod - ((w - 1) % mod + 1)
    pv = mod - ((h - 1) % mod + 1)
    
    left = ( floor(ph / 2) ) + min
    right = ( ph - left ) + min
    top = ( floor(pv / 2) ) + min
    bottom = ( pv - top ) + min
    
    width = og_w + left + right
    height = og_h + top + bottom
    
    c.z_PointResize(width, height, src_left=-left, src_top=-top, src_width=width, src_height=height)

}



# mirrorborders()
#
# Mirrors borders by user defined value.
# ex: 408x408 clip
# clip.mirrorborders(left=2, right=2, top=2, bottom=2) will output an 412x412 clip with 2px thick mirrored borders.
#
# Dependencies:
#       avsresize

Function mirrorborders(clip c, int "left", int "right", int "top", int "bottom")
{
    
    left = Default(left, 0)
    right = Default(right, 0)
    top = Default(top, 0)
    bottom = Default(bottom, 0)

    w = Width(c)
    h = Height(c)

    width = w + left + right    
    height = h + top + bottom    
    
    c.z_PointResize(width, height, src_left=-left, src_top=-top, src_width=width, src_height=height)

}



# limitRGBPS()
#
# Clamps RGBPS clip to legal values.

Function limitRGBPS(clip c) 
{    

    bits = BitsPerComponent(c)
    
    if (!isPlanarRGB(c) || bits != 32) 
    {
        Assert(false, "Only RGBPS supported")
    }
    else
    {
        Expr(c, "x 0 1 clip")
    }  

}    
    

    
# packrgb()
#
# Packs your clip(s) to RGBP. 

Function packrgb(clip "r", clip "g", clip "b") 
{
         
    bits = Defined(r) ? BitsPerComponent(r) : Defined(g) ? BitsPerComponent(g) : BitsPerComponent(b)
    
    if (bits == 32 )
    {
      pix_fmt = "RGBPS"
    }
    else
    {
        pix_fmt = "RGBP"+String(bits)
        pix_fmt = String(pix_fmt)
    }
    
    CombinePlanes(r, g, b, planes="RGB", source_planes="YYY", pixel_type=pix_fmt)

}



# fixtvgamma()
#
# Fixes gamma bug in Y or YUV clips at 32 bit depth. If input is lower than 32 bit, it'll convert.
#
# TODO:
#       Let user choose between 16 and 32 bit outputs, defaulting to 16 bit if input isn't 32 bit.

function fixtvgamma(clip c, bool "dither")
{    
    
    dither = Default(dither, false)
    
    bits = BitsPerComponent(c)
    yuv = isYUV(c) 
    gray = isY(c)
    
    if (!yuv) 
    {
        Assert(false, "Only Y or YUV supported")
    }
    
    if (bits < 32) 
    {
        c = c.ConvertBits(32)
    }
    
    if (gray == False)
    {
        
        y = c.ExtractY()
        y = y.Levels(0, 0.88, 1, 0, 1, false, dither)
    
        u = c.ExtractU()   
        v = c.ExtractV()   
    
        gammafix = CombinePlanes(Y, U, V, planes="YUV", source_planes="YYY", sample_clip=c)
        
    }    
    else
    {
        gammafix = c.Levels(0, 0.88, 1, 0, 1, false, dither)
    }
    
    return gammafix
    
}



# linearscaling()
#
# Uses avsresize to do linear light scaling. Y and RGB convert directly to linear 32 bit. YUV will convert to linear RGBPS. It uses frames props in order to get an automatic conversion.
#
# Dependencies:
#       avsresize
#
# TODO:
#       replace scaler_uv with scaler_uv for linear conversion and scaler_uv for gamma conversion
#       add possibility to parse own colorspace_op and chromaloc_op
#       add possibility to output at any pixel format
#       add kernels as scaler_param presets (ex: Robidoux, RobidouxSharp, etc)

Function linearscaling(clip c, int "width", int "height", string "scaler", float "scaler_param_a", float "scaler_param_b", string "scaler_uv", float "scaler_param_a_uv", float "scaler_param_b_uv")
{
    
    pix_fmt = PixelType(c)
    gray = isY(c)
    
    #defaults
    width = Default(width, Width(c))
    height = Default(height, Height(c))
    
    scaler = Default(scaler, "bicubic")
    scaler_param_a = Default(scaler_param_a, 1.00/3.00)
    scaler_param_b = Default(scaler_param_b, 1.00/3.00)
    
    scaler_uv = Default(scaler_uv, scaler)
    scaler_param_a_uv = Default(scaler_param_a_uv, scaler_param_a)
    scaler_param_b_uv = Default(scaler_param_b_uv, scaler_param_b)
    
    #frame props
    matrix_idx = propGetAny(c, "_Matrix")
    transfer_idx = propGetAny(c, "_ColorRange")
    primaries_idx = propGetAny(c, "_Primaries")
    range_idx = propGetAny(c, "_ColorRange")
    chromaloc_idx = propGetAny(c, "_ChromaLocation")
    
    matrix = Select(matrix_idx, "rgb", "709", "unspec", "fcc", "470bg", "170m", "240", "ycgco", "2020ncl", "2020cl", "chromancl", "chromacl", "ictcp")    
    transfer =  Select(transfer_idx, "", "709", "unspec", "470m", "470bg", "601", "240m", "linear", "log100", "log316", "xvycc", "srgb", "2020_10", "2020_12", "st2084", "std-b67", "prophoto")
    primaries = Select(primaries_idx, "", "709", "unspec", "470m", "470bg", "170m", "240m", "film", "2020", "st428", "st431-2", "st432-1", "jedec-p22", "prophoto")
    range = Select(range_idx, "full", "limited")
    chromaloc = gray ? nop() : Select(chromaloc_idx, "left", "center", "topleft", "top", "bottomleft", "bottom")
    
    if (gray == True)
    {
        
        linear = c.z_ConvertFormat(pixel_type="Y32", colorspace_op=matrix+":"+transfer+":"+primaries+":"+range+"""=>"""+matrix+":linear:"+primaries+":full")
        
        scaled_linear = linear.z_ConvertFormat(width=width, height=height, resample_filter=scaler, filter_param_a=scaler_param_a, filter_param_b=scaler_param_b)
    
        scaled_gamma = scaled_linear.z_ConvertFormat(pixel_type=pix_fmt, colorspace_op=matrix+":linear:"+primaries+":full=>"+matrix+":"+transfer+":"+primaries+":"+range+"")
        
    }
    else
    {
        
        linear = c.z_ConvertFormat(pixel_type="RGBPS", colorspace_op=matrix+":"+transfer+":"+primaries+":"+range+"""=>RGB:linear:"""+primaries+":full", chromaloc_op=chromaloc+"=>center", resample_filter_uv=scaler_uv, filter_param_a_uv=scaler_param_a_uv, filter_param_b_uv=scaler_param_b_uv)
    
        scaled_linear = linear.z_ConvertFormat(width=width, height=height, resample_filter=scaler, filter_param_a=scaler_param_a, filter_param_b=scaler_param_b)
    
        scaled_gamma = scaled_linear.z_ConvertFormat(pixel_type=pix_fmt, colorspace_op="RGB:linear:"+primaries+":full=>"+matrix+":"+transfer+":"+primaries+":"+range+"", chromaloc_op="center=>"+chromaloc, resample_filter_uv=scaler_uv, filter_param_a_uv=scaler_param_a_uv, filter_param_b_uv=scaler_param_b_uv)
        
    }
  
    return scaled_gamma
    
}



# bgrtorgb()
#
# Converts a BGR clip to RGBP. Input must be in RGB(P) format.

Function bgrtorgb(clip c)
{
    
    rgb = c.isRGB()
    
    if (!rgb)
    {
    Assert(false, "Clip must be in RGB format")
    }
          
    c = IsPlanar(c) ? c : c.ConvertToPlanarRGB()          
    bits = BitsPerComponent(c)
    
    if (bits == 32 )
    {
      pix_fmt = "RGBPS"
    }
    else
    {
        pix_fmt = "RGBP"+String(bits)
        pix_fmt = String(pix_fmt)
    }
    
    r = c.ExtractR()
    g = c.ExtractG()
    b = c.ExtractB()
    
    CombinePlanes(b, g, r, planes="RGB", source_planes="YYY", pixel_type=pix_fmt)
    
}



# gbrtorgb()
#
# Converts a GBR clip to RGBP. Input must be in RGB(P) format.

Function gbrtorgb(clip c)
{
    
    rgb = c.isRGB()
    
    if (!rgb)
    {
    Assert(false, "Clip must be in RGB format")
    }
           
    c = IsPlanar(c) ? c : c.ConvertToPlanarRGB()       
    bits = BitsPerComponent(c)
    
    if (bits == 32 )
    {
      pix_fmt = "RGBPS"
    }
    else
    {
        pix_fmt = "RGBP"+String(bits)
        pix_fmt = String(pix_fmt)
    }
    
    r = c.ExtractR()
    g = c.ExtractG()
    b = c.ExtractB()
    
    CombinePlanes(g, b, r, planes="RGB", source_planes="YYY", pixel_type=pix_fmt)
    
}



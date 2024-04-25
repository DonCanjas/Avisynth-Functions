###########################################
###                                     ###
###     DonCanjas presents:             ###
###     Don's Utils                     ###
###     25-04-2024:                     ###
###     Carnation Revolution Update     ###
###                                     ###
###########################################

### avs_utils version 05-04-2023
### Meme hearders aside, these are a collection of functions I either use or find that might useful.
### Everything is written with avs+ in mind.

### avs_utils version 01-11-2023
### Fixed pack3rgb() that would use only clip c

### avs_utils version 02-11-2023
### packrgb() was upgraded in order to deprecate and delete pack3rgb()

### avs_utils version 25-04-2024 - Carnation Revolution update
### mirrorborders() isn't limited to a single value for all borders anymore
### s_addborders() was added
### padmod() was added

### Included Functions
###
### scrop()
###
### sborders()
###
### padmod()
###
### mirrorborders()
###
### limitRGBPS()
###
### packrgb()
#######################


# scrop()
#
#A wrapper for avs' internal function Crop(). S stands for Sane, Schizo, or whatever else you decide.
#It was written to drop the need for negative numbers and change the param order to make it function like vapoursynth's std.Crop().

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
#A wrapper for avs' internal function AddBorders(). S stands for Sane, Schizo, or whatever else you decide.
#It was written to drop the need for negative numbers and change the param order to make it function like scrop().

Function sborders(clip c, int "left", int "right", int "top", int "bottom", int "color")
{
    left = Default(left, 0)
    right = Default(right, 0)
    top = Default(top, 0)
    bottom = Default(bottom, 0)
    color = Default(color, $000000)
    
    c.AddBorders(left, top, right, bottom, color)
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

    w_mirror_pad = w + left+right    
    h_mirror_pad = h + top + bottom    
    
    c.z_PointResize(w_mirror_pad, h_mirror_pad, src_left=-left, src_top=-top, src_width=w_mirror_pad, src_height=h_mirror_pad)
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

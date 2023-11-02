####################################
###                              ###
###     DonCanjas presents:      ###
###     Don's Utils              ###
###     01-11-2023               ###
###                              ###
####################################

### avs_utils version 05-04-2023 1.0
### Meme hearders aside, these are a collection of functions I either use or find that might useful.
### Everything is written with avs+ in mind.

### avs_utils version 01-11-2023 1.1
### Fixed pack3rgb() that would use only clip c

### Included Functions
###
### scrop()
###
### mirrorborders()
###
### limitRGBPS()
###
### packrgb()
###
### pack3rgb()
#######################


# scrop()
#
#A wrapper for avs' internal function Crop(). S stands for Sane or Schizo, whatever you decide.
#It was written to drop the need for negative numbers and change the param order to make it function like vapoursynth's std.Crop().

Function scrop(clip c, int "left", int "right", int "top", int "bottom", bool "align")
{
    left = Default(left, 0)
    right = Default(right, 0)
    top = Default(top, 0)
    bottom = Default(bottom, 0)
    
    c.crop(left, top, -right, -bottom, align)
}



# mirrorborders()
#
# Mirrors borders by user defined value.
# ex: 408x408 clip
# clip.mirrorborders(bsize=2) will output an 412x412 clip with 2px thick borders.
#
# Dependencies:
#       avsresize

Function mirrorborders(clip c, int "bsize")
{
    w = Width(c)
    h = Height(c)
    
    v1 = bsize * 2
    
    c.z_PointResize(w+v1, h+v1, src_top=-bsize, src_left=-bsize, src_width=w+v1, src_height=h+v1)
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
# Packs your clip to RGBP. 

Function packrgb(clip c) 
{
    
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
    
    CombinePlanes(c, planes="RGB", source_planes="YYY", pixel_type=pix_fmt)
    
}


# pack3rgb()
#
# Packs 3 clips to RGBP. 

Function pack3rgb(clip "r", clip "g", clip "b") 
{
    
    if (!Defined(r) || !Defined(g) || !Defined(b)) 
    {
        Assert(false, "pack3rgb: Needs 3 clips. Use packrgb() if you want to pack a single plane clip.")
    }
      
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
    
    CombinePlanes(r, g, b, planes="RGB", source_planes="YYY", pixel_type=pix_fmt)
    
}

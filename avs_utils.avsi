####################################
###                              ###
###     DonCanjas presents:      ###
###     Don's Utils              ###
###     31-03-2023               ###
###                              ###
####################################

### avs_utils version 31-03-2023 1.0
### Meme hearders aside, these are a collection of functions I either use or find that might useful.
### Everything is written with avs+ in mind.



# scrop()
#
#A wrapper for avs' internal function Crop(). S stands for Sane or Schizo, whatever you decide.
#It was written to drop the need for negative numbers and change the param order to make it function like vapoursynth's std.Crop().

Function scrop(clip c, int "left", int "right", int "top", int "bottom", bool "align"){

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
# Limits RGBPS clip to safe values.

Function limitRGBPS(clip c) 
{    
    bits = BitsPerComponent(c)
    
    if (!isPlanarRGB(c) || bits != 32) 
    {
        Assert(false, "Only RGBPS supported")
    }
    else
    {
        Expr(src, "x 0 1 clip")
    }  
}    
    

    
# packrgb()
#
# Packs your clip to RGBP. 
# Only Y 8-32 format.

Function packrgb(clip c) 
{
    
    Assert(isy(c), "Only Y 8-32 format" )
    
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

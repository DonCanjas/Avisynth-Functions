#A wrapper for avs' internal function Crop(). S stands for Sane or Schizo, whatever you decide.
#It was written to drop the need for negative numbers and change the param order.
Function SCrop(clip c, int "left", int "right", int "top", int "bottom", bool "align"){

c.crop(left, top, -right, -bottom, align)

}

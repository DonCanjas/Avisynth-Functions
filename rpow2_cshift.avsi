### A correcting shift to rpow2 image enlargements. Based on Asd-g's NNEDI3CL_rpow2
### Requirements - AviSynth+, avsresize.
Function rpow2_cshift (clip input, int "rfactor", int "field", string "cshift", string "chroma_loc"){

rfactor = Default(rfactor, 2)
step = Log(rfactor) / Log(2)
Assert(Frac(step) == 0.0, "rpow2_cshift: rfactor must be a power of two.")
step = Int(step) - 1
field = Default(field, 1)
cshift = Default(cshift, "spline36")
chroma_loc = Default(chroma_loc, "left")

Assert(cshift == "spline36" || cshift == "point" || cshift == "bilinear" || cshift == "bicubic" || cshift == "lanczos" || cshift == "lanczos4" || cshift == "spline16" || cshift == "spline64", "rpow2_cshift: wrong cshift.")
Assert(chroma_loc == "left" || chroma_loc == "center", "EEDI3CL_rpow2: chroma_loc must be either left or center.")

input   

    if (field == 1)
    {
        shift = -0.5 * (rfactor - 1)

        if (Is420() || Is422())
        {
            shift_chroma = ((chroma_loc == "left") ? shift : (-(rfactor - 1))) / 2.0
            v = (Is420()) ? BitRShiftU(Height(), 1) : Height()

            y = Eval("z_" + cshift + "Resize(ExtractY(), Width(), Height(), src_left=shift, src_top=shift)")
            u = Eval("z_" + cshift + "Resize(ExtractU(), BitRShiftU(Width(), 1), v, src_left=shift_chroma, src_top=shift)")
            v = Eval("z_" + cshift + "Resize(ExtractV(), BitRShiftU(Width(), 1), v, src_left=shift_chroma, src_top=shift)")

            return CombinePlanes(y, u, v, planes="yuv", sample_clip=last)
        }
        else
        {
            return Eval("z_" + cshift + "Resize(last, Width(), Height(), src_left=shift, src_top=shift)")
        }
    }
    else
    {
        shift = 0.5 * (rfactor - 1)
        shift_chroma =  (chroma_loc == "left") ? (0.5 * (rfactor * (step + 1) + 1) / 2.0) : shift
        v = (Is420()) ? BitRShiftU(Height(), 1) : Height()

        if (Is420() || Is422())
        {
            y = Eval("z_" + cshift + "Resize(ExtractY(), Width(), Height(), src_left=shift, src_top=shift)")
            u = Eval("z_" + cshift + "Resize(ExtractU(), BitRShiftU(Width(), 1), v, src_left=shift_chroma, src_top=shift)")
            v = Eval("z_" + cshift + "Resize(ExtractV(), BitRShiftU(Width(), 1), v, src_left=shift_chroma, src_top=shift)")

            return CombinePlanes(y, u, v, planes="yuv", sample_clip=last)
        }
        else
        {
            return Eval("z_" + cshift + "Resize(last, Width(), Height(), src_left=shift, src_top=shift)")
        }
    }
}

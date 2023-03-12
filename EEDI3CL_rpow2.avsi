### A wrapper of EEDI3CL for enlarging images by powers of 2. Based on Asd-g's NNEDI3CL_rpow2


### Requirements - AviSynth+ r3682 or later, EEDI3CL, avsresize.


### Usage ###
# EEDI3CL_rpow2(clip input, int "rfactor", int "field", int "nsize", int "nns", int "qual", int "etype", int "pscrn", int "device", bool "st", string "cshift", string "chroma_loc")
###
## Parameters ##
#---------------
# rfactor (default 2): Image enlargement factor.
# Must be a power of 2.
#---------------
# cshift (default not specified): Sets the resizer used for correcting the image center shift.
# If not specified the shift is not corrected.
# For example, cshift="spline36".
#---------------
# chroma_loc (default "left"): Chroma location if cshift is specified.
# Must be either "left" or "center".


###Based on Asd-g's NNEDI3CL_rpow2 Version: 1.0.2


### Changelog ###
#---------------
# Fixed processing of 422 clips.
#---------------
# Fixed processing of Y clips.
#---------------
# Initial version.


Function EEDI3CL_rpow2(clip input, int "rfactor", int "field", float "alpha", float "beta", float "gamma", int "nrad", int "mdis", bool "hp", bool "ucubic", bool "cost3", int "vcheck", float "vthresh0", float "vthresh1", float "vthresh2", clip "sclip", int "device", string "cshift", string "chroma_loc")
{
    rfactor = Default(rfactor, 2)
    field = Default(field, 1)
    step = Log(rfactor) / Log(2)
    Assert(Frac(step) == 0.0, "EEDI3CL_rpow2: rfactor must be a power of two.")
    step = Int(step) - 1

    input
    for (i = 0, step)
    {
        EEDI3CL(rfactor=rfactor, field=field, dh=True, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, hp=hp, ucubic=ucubic, cost3=cost3, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, vthresh2=vthresh2, sclip=sclip, device=device)
        TurnRight()
        EEDI3CL(rfactor=rfactor, field=field, dh=True, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, hp=hp, ucubic=ucubic, cost3=cost3, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, vthresh2=vthresh2, sclip=sclip, device=device)
        TurnLeft()
    }

    if (Defined(cshift))
    {
        chroma_loc = Default(chroma_loc, "left")

        Assert(cshift == "spline36" || cshift == "point" || cshift == "bilinear" || cshift == "bicubic" || cshift == "lanczos" || cshift == "lanczos4" || cshift == "spline16" || cshift == "spline64", "EEDI3CL_rpow2: wrong cshift.")
        Assert(chroma_loc == "left" || chroma_loc == "center", "EEDI3CL_rpow2: chroma_loc must be either left or center.")

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
}

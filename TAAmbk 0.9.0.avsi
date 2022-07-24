###################################################
###                        Taro's Anti-Aliasing modified by kewenyu              ###
###                                                                                                                ###
###                       Original by 06_taro - astrataro@gmail.com            ###
###                                                                                                                ###
###                        Modified by kewenyu - 1059902659@qq.com       ###
###                                                                                                                ###
###                                      v0.8.0 - 17 July 2016                                     ###
###################################################
###
###
### This is a modified script based on Taro's TAA  v1.6.2, a 3pass anti-aliasing script method based on eedi2,
### eedi3, nnedi3 and SangNom2. Several post processes are taken to avoid details loss on scence or bring in
### new artifacts. This script requires YUV420P input.
###
###v0.9.0
###Updated functions by DonCanjas - 24 July 2022

Function TAAmbk(clip input, int "aatype", int "aatypeU", int "aatypeV", float "strength", int "preaa", int "cycle",
\                                       int "mtype", int "magg", clip "mclip", int "mthr", int "mbnr", bool "mclear", int "mepd", int "mipd", float "sigma", float "sigma2", int "txtprt",
\                                       int "thin", float "dark", 
\                                       float "sharp", int "aarepair", bool "postaa", clip "src", int "stabilize",
\                                       bool "eedi3m", bool "nnedi3cl", bool "lsb_in", bool "lsb_out", bool "showmask", 
\                                       float "p1", float "p2", float "p3", float "p4", float "p5", float "p6")
{
    aatype = Default(aatype, 1)
    aatypeU = Default(aatypeU, aatype)
    aatypeV = Default(aatypeV, aatype)
    strength = Default(strength, 1)
    preaa = Default(preaa, 0)
    cycle = Default(cycle, 0)
    mtype = Default(mtype, 1)
    magg = (mtype == 1) ? Default(magg, 0) : 0
    mthr = Default(mthr, 20)
    mbnr = Default(mbnr, 1)
    mclear = Default(mclear, True)
    mepd = Default(mepd, 1)
    mipd = Default(mipd, mepd)
    sigma = Default(sigma, 1.2)
    sigma2 = Default(sigma2, 2.8)
    txtprt = Default(txtprt, 218)
    thin = Default(thin, 0)
    dark = Default(dark, 0)
    sharp = Default(sharp, 0)
    aarepair = Default(aarepair, 0)
    postaa = (sharp >= 1 || sharp < -1) ? Default(postaa, True) : Default(postaa, False)
    stabilize = Default(stabilize, 0)
    eedi3m = (abs(aatype) == 2) ? Default(eedi3m, True) : Default(eedi3m, False)
    nnedi3cl = Default(nnedi3cl, False)
    lsb_in = Default(lsb_in, False)
    lsb_out = lsb_in ? Default(lsb_out, True) : Default(lsb_out, False)
    showmask = Default(showmask, False)
    src = Default(src, input)
    absSh = abs(sharp)   
    p1 = Default(p1, Undefined())
    p2 = Default(p2, Undefined())
    p3 = Default(p3, Undefined())
    p4 = Default(p4, Undefined())
    p5 = Default(p5, Undefined())
    p6 = Default(p6, Undefined())
    
    Assert(isYV12(input), """TAAmbk: input is not an YV12 clip ! Only YV12 clip is accepted.""")
    Assert( isYV12(src),   """TAAmbk: "src" is not an YV12 clip ! Only YV12 clip is accepted.""")
    Assert(IsFrameBased(input), """TAAmbk: input must be FrameBased ! You may need to deinterlace first.""")
    Assert((aatype >= -4 && aatype <= 7), """TAAmbk: "aatype int(-4~7)" invaild""")
    Assert((aatypeU >= -4 && aatypeU <= 7), """TAAmbk: "aatypeU int(-4~7)" invaild""")
    Assert((aatypeV >= -4 && aatypeV <= 7), """TAAmbk: "aatypeV int(-4~7)" invaild""")
    Assert((preaa>=-1 && preaa<=2),"""TAA: "preaa"(int: -1~2) invalid!""")
    Assert((mtype>=0 && mtype<=6), """TAAmbk: "mtype int(0~6)" invalid!""")
    Assert((txtprt>=0 && txtprt<=255), """TAAmbk: "txtprt int(0~255)" invalid!""")
    Assert((cycle >= 0 && cycle <= 6), """TAAmbk: cycle too many times(>6) may crash your avisynth and meaningless !""")
    Assert((aarepair >= -24 && aarepair <= 24), """TAAmbk: "repair int(-24~24)" invaild""")
    Assert((stabilize >= -3 && stabilize <= 3), """TAAmbk: "stabilize int(0~3)" invaild""")
    Assert((mtype != 0 || defined(mclip) || showmask != true), """TAAmbk: there is no mask to show when you set showmask=True and mtype=0 without defined mclip !""")
    Assert((eedi3m != True || mtype != 0 || defined(mclip)), """TAAmbk: there is no mask offer to eedi3 when you set eedi3m=True and mtype=0 without defined a mclip !""")
    Assert((mthr >=0 && mthr <= 255), """TAAmbk: mthr int(0~255) invaild""")
    Assert((strength >=1 && strength <=2), """TAAmbk: strength int(1~2) invaild""")
    Assert((mbnr >= -1 && mbnr <= 8), """TAAmbk: mbnr int(-1~8) invaild""")
    Assert((lsb_in != False || lsb_out != True), """TAAmbk: only when input is 16bit can lsb_out be set to True""")
    
    input = lsb_in ? input.Ditherpost(mode=-1) : input
    preAAc = (preaa == 0) ? input : TAAmbk_preaa(input, mode=preaa)
    preLinePlayC = (thin == 0 && dark == 0) ? preAAc : TAAmbk_lineplay(preAAc, thin, dark)
    aaMask = defined(mclip) ? mclip :
    \             (mtype == 0) ? nop() :
    \             preLinePlayC.TAAmbk_mask(mtype, magg, mthr, mbnr, mclear, mepd, mipd, sigma, sigma2, txtprt)
    
    yAAClip = (aatype == aatypeU && aatype == aatypeV) ? preLinePlayC.TAAmbk_mainaa(aatype, strength, cycle, nnedi3cl, eedi3m, p1, p2, p3, p4, p5, p6, eedi3m ? aaMask : undefined()) :
    \                                                                                preLinePlayC.ExtractY().TAAmbk_mainaa(aatype, strength, cycle, nnedi3cl, eedi3m, p1, p2, p3, p4, p5, p6, eedi3m ? aaMask : undefined())
    uAAClip = (aatype == aatypeU && aatype == aatypeV) ? nop() :
    \                                                                                preLinePlayC.ExtractU().TAAmbk_mainaa(aatype, strength, cycle, nnedi3cl, eedi3m, p1, p2, p3, p4, p5, p6, eedi3m ? aaMask : undefined())
    vAAClip = (aatype == aatypeU && aatype == aatypeV) ? nop() :
    \                                                                                preLinePlayC.ExtractV().TAAmbk_mainaa(aatype, strength, cycle, nnedi3cl, eedi3m, p1, p2, p3, p4, p5, p6, eedi3m ? aaMask : undefined())
    
    aaedClip = (aatype == aatypeU && aatype == aatypeV) ? yAAClip : YToUV(uAAClip, vAAClip, yAAClip)
    
    aaedSharp = (sharp == 0) ? aaedClip :
    \                  (sharp >= 1) ? aaedClip.lsfmod(strength=Int(absSh), defaults="old", source=src) :
    \                  (sharp > 0) ? aaedClip.Sharpen(absSh) :
    \                  (sharp > -1) ? aaedClip.lsfmod(strength=Round(absSh*100), defaults="fast", source=src) :
    \                  (sharp == -1) ? aaedClip.mt_adddiff(mt_makediff(aaedClip, aaedClip.RemoveGrain((input.width()>1100) ? 20 : 11), U=3, V=3).Repair(mt_makediff(src, aaedClip, U=3, V=3), 13), U=3,V=3) :
    \                                         aaedClip.lsfmod(strength=Int(absSh), defaults="slow", source=src)
    aaedSharpSoo = postaa ? aaedSharp.Soothe(aaedClip, keep=48) : aaedSharp
    
    aaedMerge = (mtype == 0 && !defined(mclip)) ? aaedSharpSoo : mt_merge(src, aaedSharpSoo, aaMask, U=3, V=3)
    aaedRP = (aarepair == 0) ? aaedMerge :
    \             (aarepair > 0) ? src.Repair(aaedMerge, mode=aarepair) :
    \                                    aaedMerge.Repair(src, mode = abs(aarepiar))
    aaStabed = (stabilize == 0) ? aaedRP :
    \                                          aaedRP.TAAmbk_stabilize(src, stabilize)
    
    output = (lsb_in && lsb_out) ? input.dither_limit_dif16(aaStabed.dither_convert_8_to_16(), thr=1.0, elast=2.0) : aaStabed
    
    return showmask ? aaMask.GreyScale() : output
}


Function TAAmbk_preaa(clip input, int "mode")
{
    nn = (mode == 2) ? nop() : input.nnedi3(field=-2)
    nnt = (mode == 1) ? nop() : input.TAAmbk_TurnLeft().nnedi3(field=-2).TAAmbk_TurnRight()
    clph = (mode == 2) ? nop() : mt_average(selecteven(nn), selectodd(nn), U=3, V=3)
    clpv = (mode == 1) ? nop() : mt_average(selecteven(nnt), selectodd(nnt), U=3, V=3)
    clp = (mode == -1) ? mt_average(clph, clpv, U=3, V=3) : nop()
    return (mode == 1) ? clph :
    \        (mode == 2) ? clpv :
    \                             clp
}



Function TAAmbk_mainaa(clip input, int "aatype", float "strength", int "cycle", bool "nnedi3cl", bool "eedi3m",
\                                  float "p1", float "p2", float "p3", float "p4", float "p5", float "p6", clip "emask")
{
    pindex = aatype + 4
    p1 = Default( p1, Select(pindex,  48,  48,    48,    48,    0,   10,   0.5,    3,   48,   48,   48,   48) )
    p2 = Default( p2, Select(pindex,  10,    3,   0.5,    10,    0,   20,   0.2,    1,    1,    0,     0,    0) )
    p3 = Default( p3, Select(pindex,  20,    1,   0.2,    20,    0,   20,    20,    2,    3,    0,    0,     0) )
    p4 = Default( p4, Select(pindex,  20,    2,    20,    20,    0,   24,     3,    0,    2,    0,    0,     0) )
    p5 = Default( p5, Select(pindex,  24,    0,     3,    24,    0,   50,    30,    0,    0,    0,    0,     0) )
    p6 = Default( p6, Select(pindex,  50,    0,    30,    50,    0,    0,     0,    0,    0,    0,    0,     0) )
    
    w = width(input)
    h = height(input)
    downScale = -0.5 * strength + 1.5
    dw = Round(w*downScale/4)*4
    dh = Round(h*downScale/4)*4
    upw4 = Round(dw*0.375)*4
    uph4 = Round(dh*0.375)*4
    nnedi3type = nnedi3cl ? "nnedi3cl" : "nnedi3"
    eedi3mc = eedi3m ? emask.z_BilinearResize(dw, dh).mt_expand() : nop()
    eedi3mct = eedi3m ? eedi3mc.z_BilinearResize(w, uph4).TAAmbk_turnright() : nop()
    
    preDownClip = (strength == 1) ? input : input.z_Spline36Resize(dw, dh)
    
    aaClip = (aatype == -4) ? preDownClip.eedi2(field=1, mthresh=int(p2), lthresh=int(p3), vthresh=int(p4), maxd=int(p5), nt=int(p6)).TAAmbk_turnright()
    \                                                    .z_PointResize(dh*2, dw*2).SangNom2(aa=int(p1)).TAAmbk_turnleft().SangNom2(aa=int(p1)).TAAmbk_spline36resize(w, h, -0.5, -0.5) :
    \           (aatype == -3 || aatype == 4) ? preDownClip.Eval(""""""+nnedi3type+"""(dh=true, field=1, nsize=int(p2), nns=int(p3), qual=int(p4))""").TAAmbk_spline36resize(w, uph4, 0, -0.5)
    \                                                                      .TAAmbk_turnright().Eval(""""""+nnedi3type+"""(dh=true, field=1, nsize=int(p2), nns=int(p3), qual=int(p4))""").TAAmbk_spline36resize(uph4, upw4, 0, -0.5)
    \                                                                      .SangNom2(aa=int(p1)).TAAmbk_turnLeft().SangNom2(aa=int(p1)).z_Spline36Resize(w, h) :
    \           (aatype == -2) ? preDownClip.Eedi3(dh=true, field=1, alpha=float(p2), beta=float(p3), gamma=float(p4), nrad=int(p5), mdis=int(p6), mclip=eedi3m ? eedi3mc : undefined()).TAAmbk_spline36resize(w, uph4, 0, -0.5)
    \                                                    .TAAmbk_turnright().Eedi3(dh=true, field=1, alpha=float(p2), beta=float(p3), gamma=float(p4), nrad=int(p5), mdis=int(p6), mclip=eedi3m ? eedi3mct : undefined()).TAAmbk_spline36resize(uph4, upw4, 0, -0.5)
    \                                                    .SangNom2(aa=int(p1)).TAAmbk_turnleft().SangNom2(aa=int(p1)).z_Spline36Resize(w, h) :
    \           (aatype == -1) ? preDownClip.eedi2(field=1, mthresh=int(p2), lthresh=int(p3), vthresh=int(p4), maxd=int(p5), nt=int(p6)).TAAmbk_spline36resize(w, uph4, 0, -0.5).TAAmbk_turnright()
    \                                                    .eedi2(field=1, mthresh=int(p2), lthresh=int(p3), vthresh=int(p4), maxd=int(p5), nt=int(p6)).TAAmbk_spline36resize(uph4, upw4, 0, -0.5).SangNom2(aa=int(p1)).TAAmbk_turnLeft()
    \                                                    .SangNom2(aa=int(p1)).z_Spline36Resize(w, h) :
    \           (aatype == 1) ? preDownClip.eedi2(field=1, mthresh=int(p1), lthresh=int(p2), vthresh=int(p3), maxd=int(p4), nt=int(p5)).TAAmbk_spline36resize(w, h, 0, -0.5).TAAmbk_turnright()
    \                                                   .eedi2(field=1, mthresh=int(p1), lthresh=int(p2), vthresh=int(p3), maxd=int(p4), nt=int(p5)).TAAmbk_spline36resize(h, w, 0, -0.5).TAAmbk_turnleft() :
    \           (aatype == 2) ? preDownClip.Eedi3(dh=true, field=1, alpha=float(p1), beta=float(p2), gamma=float(p3), nrad=int(p4), mdis=int(p5), mclip=eedi3m ? eedi3mc : undefined()).TAAmbk_spline36resize(w, h, 0, -0.5).TAAmbk_turnright()
    \                                                   .Eedi3(dh=true, field=1, alpha=float(p1), beta=float(p2), gamma=float(p3), nrad=int(p4), mdis=int(p5), mclip=eedi3m ? eedi3mct.z_BilinearResize(h, w) : undefined()).TAAmbk_spline36resize(h, w, 0, -0.5).TAAmbk_turnleft() :
    \           (aatype == 3) ? preDownClip.Eval(""""""+nnedi3type+"""(dh=true, field=1, nsize=int(p1), nns=int(p2), qual=int(p3))""").TAAmbk_spline36resize(w, h, 0, -0.5).TAAmbk_turnright()
    \                                                   .Eval(""""""+nnedi3type+"""(dh=true, field=1, nsize=int(p1), nns=int(p2), qual=int(p3))""").TAAmbk_spline36resize(h, w, 0, -0.5).TAAmbk_turnleft() :
    \           (aatype == 5) ? preDownClip.z_Spline64Resize(upw4, uph4).Repair(input.GaussResizeMT(upw4, uph4, p=100), 1).SangNom2(aa=int(p1)).TAAmbk_turnright().SangNom2(aa=int(p1)).z_Spline36Resize(h, w).TAAmbk_turnleft() :
    \           (aatype == 6) ? preDownClip.z_Spline64Resize(w, uph4).SangNom2(aa=int(p1)).z_Spline36Resize(w, h).TAAmbk_turnright().z_Spline64Resize(h, upw4).SangNom2(aa=int(p1)).z_Spline36Resize(h, w).TAAmbk_TurnLeft().Repair(input, mode=int(p2)) :
    \           (aatype == 7) ? preDownClip.z_PointResize(dw, dh*2).SangNom2(aa=int(p1)).TAAmbk_spline36resize(w, h, 0, -0.5).TAAmbk_turnright().z_PointResize(dh, dw*2).SangNom2(aa=int(p1)).TAAmbk_spline36resize(h, w, 0, -0.5).TAAmbk_turnleft() :
    \                                   preDownClip
    
    return (cycle==0) ? aaClip : aaClip.TAAmbk_mainaa(aatype, strength, cycle - 1, nnedi3cl, eedi3m, p1, p2, p3, p4, p5, p6, emask)
}



Function TAAmbk_mask(clip input, int "mtype", int "magg", int "mthr", int "mbnr", bool "mclear", int "mepd", int "mipd", float "sigma", float "sigma2", int "txtprt")
{
    w = input.width()
    h = input.height()
    aaMask = (mtype == 1) ? input.ExtractY().Retinex_MSRCP().vsTCanny(mode=1, sigmaY=sigma) : 
    \             (mtype == 2) ? input.ExtractY().Retinex_MSRCP().vsTEdgeMask(link=2) :
    \             (mtype == 3) ? input.ExtractY().Retinex_MSRCP().MSharpen(threshold=mbnr/5, strength=0, mask=true, highq=false) :
    \             (mtype == 4) ? input.ExtractY().Retinex_MSRCP().mt_edge("sobel",7,7,5,5) :
    \             (mtype == 5) ? input.ExtractY().Retinex_MSRCP().mt_edge("roberts",0,4,0,4) :
    \             (mtype == 6) ? input.ExtractY().Retinex_MSRCP().mt_edge("prewitt",0,255,0,0) : nop()
    
    aaMaskThr = (mbnr <= 0) ? aaMask :
    \                  (mtype == 1) ? aaMask.mt_lut("x "+string(mthr)+" <= x "+string(mbnr)+" >> x "+string(mbnr)+" << ?", U=1, V=1) :
    \                  (mtype == 2) ? aaMask.mt_lut("x "+string(mthr/5)+" <= x "+string(mbnr)+" >> x "+string(4*mbnr)+" << ?", U=1, V=1) :
    \                  (mtype == 6) ? aaMask.mt_lut("x "+string(mthr)+" <= x "+string(mbnr)+" >> x 1.4 ^ ?") : aaMask
    
    aaMaskBnr = (mbnr == -1) ? aaMaskThr.mt_binarize(mthr) : aaMaskThr
    
    aaMaskAgg = (mtype == 1 && magg != 0) ? Eval("""
                                                  aggMask = input.ExtractY().Retinex_MSRCP().vsTCanny(mode=0, sigmay=sigma2).mt_expand()
                                                  return mt_lutxy(aggMask, aaMaskBnr, "y "+string(magg)+" > x 0 ?")
                                               """) : aaMaskBnr
    
    aaMaskClear = mclear ? aaMaskAgg : aaMaskAgg.RemoveGrain(4, 4)
    aaMaskExpand = (mepd == 0) ? aaMaskClear : aaMaskClear.TAAmbk_expand(mepd)
    aaMaskInpand = (mipd == 0) ? aaMaskExpand : aaMaskExpand.TAAmbk_inpand(mipd)
    
    aaMaskAvg = aaMaskInpand.RemoveGrain(20, 20)
    
    txtMask = (txtprt != 0) ? Eval("""
                           srcY = input.ExtractY()
                           srcU = input.ExtractU().z_Spline36Resize(w, h, 0.25)
                           srcV = input.ExtractV().z_Spline36Resize(w, h, 0.25)
                           mt_lutxyz(srcY,srcU,srcV,"x "+string(txtprt)+" > y 128 - abs 1 <= & z 128 - abs 1 <= & 255 0 ?").mt_expand(mode=mt_circle(2)).mt_expand().RemoveGrain(20, 20)
                       """) : nop()
           
    aaMaskFinal = (txtprt != 0) ? mt_lutxy(aaMaskAvg, txtMask, "x y -") : aaMaskAvg
    aaMaskUV = aaMaskFinal.GreyScale().z_Spline36Resize(width(aaMaskFinal)/2, height(aaMaskFinal)/2)
    aaMaskOutput = YToUV(aaMaskUV, aaMaskUV, aaMaskFinal)
    return aaMaskOutput
}
                           
    
Function TAAmbk_stabilize(clip input, clip "src", int "stabilize")
{
    aaDiff = mt_makediff(src, input, U=3, V=3)
    inSuper = input.MSuper(pel=1)
    diffSuper = aaDiff.MSuper(pel=1, levels=1)
    
    fv3 = (stabilize == 3) ? inSuper.MAnalyse(isb=false,delta=3,overlap=8,blksize=16) : nop()
    fv2 = (stabilize >= 2) ? inSuper.MAnalyse(isb=false,delta=2,overlap=8,blksize=16) : nop()
    fv1 = (stabilize >= 1) ? inSuper.MAnalyse(isb=false,delta=1,overlap=8,blksize=16) : nop()
    bv1 = (stabilize >= 1) ? inSuper.MAnalyse(isb=true,delta=1,overlap=8,blksize=16) : nop()
    bv2 = (stabilize >= 2) ? inSuper.MAnalyse(isb=true,delta=2,overlap=8,blksize=16) : nop()
    bv3 = (stabilize == 3) ? inSuper.MAnalyse(isb=true,delta=3,overlap=8,blksize=16) : nop()
    
    diffStab = (stabilize == 1) ? aaDiff.MDegrain1(diffsuper,bv1,fv1) :
    \              (stabilize == 2) ? aaDiff.MDegrain2(diffsuper,bv1,fv1,bv2,fv2) :
    \              (stabilize == 3) ? aaDiff.MDegrain3(diffsuper,bv1,fv1,bv2,fv2,bv3,fv3) : nop()
    
    diffCompare = mt_lutxy(aaDiff, diffStab, "x 128 - abs y 128 - abs < x y ?").mergeluma(diffStab, 0.6)
    aaStab = mt_makediff(src, diffCompare, U=3, V=3)
    return aaStab
}

    
Function TAAmbk_lineplay(clip input, int "thin", float "dark")
{
    return (thin != 0 && dark != 0) ? input.aWarpSharp2(depth=thin).Toon(dark) :
    \                          (thin == 0) ? input.Toon(dark) :
    \                                             input.aWarpSharp(depth=thin)
}


Function TAAmbk_expand(clip mask, int "n")
{
    expMask = mask.mt_expand()
    return (n==1) ? expMask : expMask.TAAmbk_expand(n-1)
}

Function TAAmbk_inpand(clip mask, int "n")
{
    inpMask = mask.mt_inpand()
    return (n==1) ? inpMask : inpMask.TAAmbk_inpand(n-1)
}


Function TAAmbk_spline36resize(clip input, int "w", int "h", float "sx", float "sy")
{
    y = input.ExtractY()
    u = input.ExtractU()
    v = input.ExtractV()
    yResize = y.z_Spline36Resize(w, h, sx, sy)
    uResize = u.z_Spline36Resize(w/2, h/2, sx, sy)
    vResize = v.z_Spline36Resize(w/2, h/2, sx, sy)
    return YToUV(uResize, vResize, yResize)
}

    
Function TAAmbk_turnleft(clip input)
{
    try
    {
        return input.fturnleft()
    }
    catch(error_msg)
    {
        return input.TurnLeft()
    }
}
 
 
Function TAAmbk_turnright(clip input)
{
    try
    {
        return input.fturnright()
    }
    catch(error_msg)
    {
        return input.TurnRight()
    }
}

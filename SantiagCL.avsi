#based on santiag v1.606
# Simple antialiasing

# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.

### Requirements - AviSynth+ r3682 or later, NNEDI3CL, EEDI3CL, NNEDI3 (optional), EEDI3 (optional), EEDI2, Sangnom2, avsresize, Zs_RF_Shared

### SantiagCL Version 1.0 by DonCanjas

### Changelog ###
#---------------
# Removed non-avs+ support
#---------------
# Switched resizers with their avsresize counterpart
#---------------
# Added NNEDI3CL and EEDI3CL
#---------------
# Updated default settings
#---------------
# Updated deprecated functions (ex: sTryFTurnt)
#---------------

### Usage ###
# type = "nnedi3", "nnedi3cl", "eedi2", "eedi3", "eedi3cl" or "sangnom"
# "nnedi3" requires nnedi3cl 1.0.7+
# "eedi3" requires eedi3cl 1.0.1+
# "sangnom" requires sangnom2

Function santiagcl (clip c, int "strh", int "strv", string "type", int "aa", int "aac", int "nsize", int "nns", int "qual", int "pscrn", int "device", bool "st", float "alpha", float "beta", float "gamma", int "nrad", int "mdis", float "vthresh0", float "vthresh1", int "vcheck", int "fw", int "fh", bool "halfres", string "scaler_post", int "maskt", string "typeh", string "typev", bool "lumaonly", bool "aath", int "nnrep", string "scaler_arg", bool "santiagcl_sangnom_bug")
{
	strh = Default (strh, 1)
	strv = Default (strv, 1)
	type = Default (type, "nnedi3cl")
	typeh = Default (typeh, type)
	typev = Default (typev, type)
	halfres = Default (halfres, false)
	scaler_post = Default (scaler_post, "z_Spline36Resize")
	lumaonly = Default (lumaonly,  True)
	sangnom_bug = Default (santiagcl_sangnom_bug, true)
	aain = Default (aath, !sangnom_bug) # make the turn for Horizontal (I think that what any antialiasing should do)
	nnrep = Default (nnrep, 0)
	scaler_arg = Default (scaler_arg, "")
	
	#Sangnom Default Settings
	aa = Default (aa, 48)
	aac = Default (aac, 48)
	#NNEDI3 Default Settings
	nns = Default(nns, 4)
	nsize = Default(nsize, 0)
	qual = Default(qual, 2)
	pscrn = Default(pscrn, 1)
	#EEDI3 Default Settings
    alpha = Default(alpha, 0.125)
    beta = Default(beta, 0.25)
    #gamma = Default(gamma, 40)
    #nrad = Default(nrad, 2)
    #mdis = Default(mdis, 20)
    #vcheck = Default(vcheck, 2)
    vthresh0 = Default(vthresh0, 12)
    vthresh1 = Default(vthresh1,	24)

	c

	w   = Width ()
	h   = Height ()
	fwh = (strv < 0) ? fw : w
	fhh = (strv < 0) ? fh : h

    (strh >= 0) ? santiagcl_dir (strh, typeh, halfres, scaler_post,  aain, aa=aa, aac=aac, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, device=device, st=st, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, maskt=maskt, fw=aain ? fw : fwh, fh=aain ? fh : fhh, lumaonly=lumaonly, nnrep=nnrep, scaler_arg=scaler_arg,santiagcl_sangnom_bug=sangnom_bug) : last
	(strv >= 0) ? santiagcl_dir (strv, typev, halfres, scaler_post, !aain, aa=aa, aac=aac, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, device=device, st=st, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, maskt=maskt, fw=aain ? fwh : fw, fh=aain ? fhh : fh, lumaonly=lumaonly, nnrep=nnrep, scaler_arg=scaler_arg,santiagcl_sangnom_bug=sangnom_bug) : last

	fwx = Default (fw, w)
	fhx = Default (fh, h)
	(strh < 0 && strv < 0) ? Eval (scaler_post + " (fwx, fhx" + scaler_arg + ")") : last
}

Function santiagcl_dir (clip c, int "strength", string "type", bool "halfres", string "scaler_post", bool "dot", int "aa", int "aac", int "nsize", int "nns", int "qual", int "pscrn", int "device", bool "st", float "alpha", float "beta", float "gamma", int "nrad", int "mdis", float "vthresh0", float "vthresh1", int "vcheck", int "maskt", int "fw", int "fh", bool "lumaonly", int "nnrep", string "scaler_arg", bool "santiagcl_sangnom_bug")
{

	c
	w = Width ()
	h = Height ()
	fw = Default (fw, w)
	fh = Default (fh, h)

	sislumaonly = isy()
	chr420  = is420()
	chr422  = is422()
	chr411  = isyv411()
	fullchr = is444()

	multi = !fullchr || lumaonly
	c_y = multi && !sislumaonly ? ExtractY() : last
	c_u = multi && !sislumaonly ? ExtractU() : nop()
	c_v = multi && !sislumaonly ? ExtractV() : nop()
	
	
	c_y = dot ? c_y.TurnLeft().santiagcl_stronger (strength, type, halfres, multi, aa=aa, aac=aac, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, device=device, st=st, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, maskt=maskt,nnrep=nnrep,santiagcl_sangnom_bug=santiagcl_sangnom_bug).TurnRight()
	\ : c_y.santiagcl_stronger (strength, type, halfres, multi, aa=aa, aac=aac, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, device=device, st=st, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, maskt=maskt,nnrep=nnrep,santiagcl_sangnom_bug=santiagcl_sangnom_bug)
	
	c_u = lumaonly ? c_u : (multi && !sislumaonly) ? dot ? c_u.TurnLeft().santiagcl_stronger (strength, type, halfres, true, aa=aac, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, device=device, st=st, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, maskt=maskt,nnrep=nnrep,santiagcl_sangnom_bug=santiagcl_sangnom_bug).TurnRight()
	\ : c_u.santiagcl_stronger (strength, type, halfres, true, aa=aac, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, device=device, st=st, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, maskt=maskt,nnrep=nnrep,santiagcl_sangnom_bug=santiagcl_sangnom_bug) : nop()
	
	c_v = lumaonly ? c_v : (multi && !sislumaonly) ? dot ? c_v.TurnLeft().santiagcl_stronger (strength, type, halfres, true, aa=aac, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, device=device, st=st, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, maskt=maskt,nnrep=nnrep,santiagcl_sangnom_bug=santiagcl_sangnom_bug).TurnRight()
	\ : c_v.santiagcl_stronger (strength, type, halfres, true, aa=aac, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, device=device, st=st, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, maskt=maskt,nnrep=nnrep,santiagcl_sangnom_bug=santiagcl_sangnom_bug) : nop()
	
	chrfw = chr422 || chr420 ? fw/2 : chr411 ? fw/4 : fw
	chrfh = chr420 ? fh/2 : fh
	c_u = lumaonly ? c_u : multi && !sislumaonly ? Eval ("c_u." + scaler_post + " (chrfw, chrfh, src_left=(halfres)?0:!dot?0:-0.5, src_top=(halfres)?0:dot?0:0.5, src_width=c_u.Width (), src_height=c_u.Height ()" + scaler_arg + ")") : c_u
	c_v = lumaonly ? c_v : multi && !sislumaonly ? Eval ("c_v." + scaler_post + " (chrfw, chrfh, src_left=(halfres)?0:!dot?0:-0.5, src_top=(halfres)?0:dot?0:0.5, src_width=c_v.Width (), src_height=c_v.Height ()" + scaler_arg + ")") : c_v
	c_y = Eval ("c_y." + scaler_post + " (fw,    fh,    src_left=(halfres)?0:!dot?0:-0.5, src_top=(halfres)?0:dot?0:0.5, src_width=c_y.Width (), src_height=c_y.Height ()" + scaler_arg + ")")

	(multi && !sislumaonly) ? YToUV(c_u, c_v, c_y) : c_y
}

Function santiagcl_stronger (clip c, int "strength", string "type", bool "halfres", bool "lumaonly", int "aa", int "aac", int "nsize", int "nns", int "qual", int "pscrn", int "device", bool "st", float "alpha", float "beta", float "gamma", int "nrad", int "mdis", float "vthresh0", float "vthresh1", int "vcheck", int "maskt", int "nnrep", bool "santiagcl_sangnom_bug")
{
	strength = (strength < 0) ? 0 : strength
	field = strength % 2
	dh = (strength <= 0 && ! halfres)

	(strength > 0) ? c.santiagcl_stronger (strength - 1, type, halfres, lumaonly, aa=aa, aac=aac, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, device=device, st=st, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, maskt=maskt, nnrep=nnrep, santiagcl_sangnom_bug=santiagcl_sangnom_bug) : c

      (type == "nnedi3" ) ? santiagcl_nnedi3  (dh, field, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, lumaonly=lumaonly)
\	: (type == "nnedi3cl" ) ? santiagcl_nnedi3cl  (dh, field, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, device=device, st=st, lumaonly=lumaonly)
\	: (type == "eedi2"  ) ? santiagcl_eedi2   (dh, field)
\	: (type == "eedi3"  ) ? santiagcl_eedi3   (dh, field, lumaonly, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, device=device, st=st, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, maskt=maskt, nnrep=nnrep)
\	: (type == "eedi3cl"  ) ? santiagcl_eedi3cl   (dh, field, lumaonly, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, device=device, st=st, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, maskt=maskt, nnrep=nnrep)
\	: (type == "sangnom") ? santiagcl_sangnom (dh, santiagcl_sangnom_bug ? field : field==0 ? 2 : 1, aa=aa, aac=aac, chroma=!lumaonly,santiagcl_sangnom_bug=santiagcl_sangnom_bug)
\	: Assert (false, "Santiag: unexpected value for type.")

}

Function santiagcl_nnedi3 (clip c, bool "dh", int "field", bool "lumaonly", int "nsize", int "nns", int "qual", int "pscrn")
{
	c.nnedi3 (dh=dh, field=field, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, u=!lumaonly, v=!lumaonly)
}

Function santiagcl_nnedi3cl (clip c, bool "dh", int "field", bool "lumaonly", int "nsize", int "nns", int "qual", int "pscrn", int "device", bool "st")
{
	c.nnedi3cl (dh=dh, field=field, luma=lumaonly, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, device=device, st=st)
}

Function santiagcl_eedi2 (clip c, bool dh, int field)
{
	c
	w = Width ()
	h = Height ()
	(dh) ? last : z_PointResize (w, h / 2, 0, 1-field, w, h)
	eedi2 (field=field)
}

# maskt = 24
Function santiagcl_eedi3 (clip c, bool "dh", int "field", bool "lumaonly", int "nsize", int "nns", int "qual", int "pscrn", int "device", bool "st", float "alpha", float "beta", float "gamma", int "nrad", int "mdis", float "vthresh0", float "vthresh1", int "vcheck", int "maskt", int "nnrep")
{
	chroma = (lumaonly) ? 1 : 3
	sclip = c.santiagcl_nnedi3 (dh, field, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, lumaonly=lumaonly)
	mclip_flag = (Defined (maskt) && maskt > 0)

	mclip = (mclip_flag && dh) ? sclip.z_BicubicResize (c.Width (), c.Height (), src_top=0.5-field) : sclip
	mclip = (mclip_flag)
\	?	mclip.mt_edge (mode="1 2 1 0 0 0 -1 -2 -1 1", thY1=0, thY2=255, u=chroma, v=chroma)
\			.mt_binarize (threshold=maskt, y=3, u=chroma, v=chroma)
\			.mt_expand (y=3, u=chroma, v=chroma)
\	:	Undefined

	c.eedi3 (dh=dh, field=field, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, sclip=sclip, mclip=mclip,  u=!lumaonly, v=!lumaonly)
	nnrep > 1 ? slimit_dif2(last,sclip,thr=4,u=!lumaonly ? 3 : 2, v=!lumaonly ? 3 : 2) : nnrep > 1 ? Repair(sclip,9,!lumaonly ? 9 : 0) : last
}

Function santiagcl_eedi3cl (clip c, bool "dh", int "field", bool "lumaonly", int "nsize", int "nns", int "qual", int "pscrn", int "device", bool "st", float "alpha", float "beta", float "gamma", int "nrad", int "mdis", float "vthresh0", float "vthresh1", int "vcheck", int "maskt", int "nnrep")
{
	sclip = c.santiagcl_nnedi3cl (dh, field, nsize=nsize, nns=nns, qual=qual, pscrn=pscrn, lumaonly=lumaonly, st=st)

	c.eedi3cl (dh=dh, field=field, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, sclip=sclip, luma=lumaonly)
	nnrep > 1 ? slimit_dif2(last,sclip,thr=4,u=!lumaonly ? 3 : 2, v=!lumaonly ? 3 : 2) : nnrep > 1 ? Repair(sclip,9,!lumaonly ? 9 : 0) : last
}

Function santiagcl_sangnom (clip c, bool "dh", int "field", int "aa", int "aac", bool "luma", bool "chroma", bool "santiagcl_sangnom_bug")
{
	c
	w = Width ()
	h = Height ()

	(santiagcl_sangnom_bug) && (dh) ? z_Spline36Resize (w, h * 2, 0, -0.25, w, h) : last
	!santiagcl_sangnom_bug ? SangNom2 (order=field, aa=aa, aac=aac, dh=dh, luma=luma, chroma=chroma) : SangNom2 (order=field, aa=aa, aac=aac)
}

Function santiaguv (clip c, int "strh", int "strv", string "type", int "aac", int "nsize", int "nns", int "qual", int "pscrn", int "device", bool "st", float "alpha", float "beta", float "gamma", int "nrad", int "mdis", float "vthresh0", float "vthresh1", int "vcheck", int "fw", int "fh", bool "halfres", string "scaler_post", int "maskt", string "typeh", string "typev", bool "aath", int "nnrep")
{
c
sislumaonly = isy()
Assert(!sislumaonly, "santiaguv: use santiag for this clip!" )

	c_y = ExtractY()
	c_u = ExtractU()
	c_v = ExtractV()
	c_u = c_u.santiag(strh=strh, strv=strv, type=type, nns=nns, aa=aac, threads=threads, nsize=nsize, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, fw=fw, fh=fh, halfres=halfres, scaler_post=scaler_post, maskt=maskt, typeh=typeh, typev=typev, aath=aath, lumaonly=true, nnrep=nnrep)
	c_v = c_v.santiag(strh=strh, strv=strv, type=type, nns=nns, aa=aac, threads=threads, nsize=nsize, alpha=alpha, beta=beta, gamma=gamma, nrad=nrad, mdis=mdis, vcheck=vcheck, vthresh0=vthresh0, vthresh1=vthresh1, fw=fw, fh=fh, halfres=halfres, scaler_post=scaler_post, maskt=maskt, typeh=typeh, typev=typev, aath=aath, lumaonly=true, nnrep=nnrep)
YToUV (c_u, c_v, c_y)
}

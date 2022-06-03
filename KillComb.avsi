#KillComb 2.1 by DonCanjas
#Requires TDeint, TIVTC, vinverse, DAA3, DAA3mod
#This Function is meant to decomb safely by filtering only on edges using your mask.

Function KillComb(clip c2, clip "EdgeMask", bool "useTDeint", int "mthreshL", int "mthreshC", int "type", bool "full", bool "useTFM", int "mode", int "PP", int "cthresh", bool "useVinverse2", bool "usemcDAA3", float "sstr", bool "useDAA3" )
{

useTDeint = Default(useTDeint, True)
useTFM = Default(useTFM, False)
mode = Default(mode, 6)
PP = Default(PP, 5)

usemcDAA3 = Default(usemcDAA3, False)
useVinverse2 = Default(useVinverse2, True)
useDAA3 = Default(useDAA3, False)

c2
source=last

TDeint = source.TDeint(mode=2, mthreshL=mthreshL, mthreshC=mthreshC, type=type, full=full)
TFM = source.TFM(mode=mode, PP=PP, cthresh=cthresh)


(useTDeint==True) ? Overlay(source, TDeint, mask=EdgeMask) \
	: (useTFM==True) ? Overlay(source, TFM, mask=EdgeMask) \
		: source


(usemcDAA3==true) ? Overlay(last, mcDaa3(), mask=EdgeMask) : last

(useVinverse2==True) ? Overlay(last, vinverse2(sstr=sstr, amnt=255, uv=2),mask=EdgeMask) : last

(useDAA3==True) ? Overlay(last, Daa3(), mask=EdgeMask) : last

}

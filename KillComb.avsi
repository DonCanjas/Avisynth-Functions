#KillComb 2.0 by DonCanjas
#Requires TDeint, TIVTC, vinverse, DAA3
#This Function is meant to decomb safely by filtering only on edges using your mask.

Function KillComb(clip c2, clip "EdgeMask", bool "useTDeint", int "mthreshL", int "mthreshC", int "type", bool "full", bool "useTFM", int "mode", int "PP", int "cthresh", bool "useVinverse2", float "sstr", bool "useDAA3" ) 
{

useTDeint = Default(useTDeint, True)
useTFM = Default(useTFM, False)
mode = Default(mode, 6)
PP = Default(PP, 5)
useVinverse2 = Default(useVinverse2, True)
useDAA3 = Default(useDAA3, False)

c2
source=last

TDeint = source.TDeint(mode=2, mthreshL=mthreshL, mthreshC=mthreshC, type=type, full=full)
TFM = source.TFM(mode=mode, PP=PP, cthresh=cthresh)


(useTDeint==True) ? Overlay(source, TDeint, mask=EdgeMask) \
	: (useTFM==True) ? Overlay(source, TFM, mask=EdgeMask) \
		: source


(useVinverse2==True) ? Overlay(vinverse2(sstr=sstr, amnt=255, uv=2),mask=EdgeMask) : last


(useDAA3==true) ? last.Overlay(Daa3(), mask=EdgeMask) : last

}

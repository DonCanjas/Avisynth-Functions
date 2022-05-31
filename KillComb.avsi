#Requires TIVTC, vinverse, DAA3
#This Function is meant to eliminate combing safely by filtering only on edges using a mask you will have to make.

Function KillComb(clip c2, int "mode", int "PP", clip "EdgeMask", float "sstr", bool "useDAA3" ) 
{
c2

useTFM = Default(useTFM, True)
mode = Default(mode, 6)
PP = Default(PP, 5)
sstr = Default(sstr, 2.7)
useDAA3 = Default(useDAA3, False)


source=last


TFM = source.TFM(mode=mode, PP=PP)


Deinterlace = (useTFM==True) ? Overlay(TFM, source, mask=EdgeMask) : source


Overlay(vinverse2(sstr=sstr, amnt=255, uv=2),mask=EdgeMask)


DAA3 = (useDAA3==true) ? last.Overlay(Daa3(), mask=EdgeMask) : last
DAA3

}

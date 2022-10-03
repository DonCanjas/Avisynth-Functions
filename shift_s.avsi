#Shift_Simple 1.0 by DonCanjas
#Based on ChromaShiftSP2
#Shifts whole clip, doesn't take chroma subsampling in consideration

Function shift_s (clip clp, float "X",float "Y", string "kernel")
{
    
ow = Width(clp)
oh = Height(clp)

X = default(X, 0.0) # positive values shift to left, negative values to right
Y = default(Y, 0.0) # positive values shift upwards, negative values downwards

kernel = Default(kernel, "z_Spline36Resize")
      
   
Eval("clp." + kernel + "(ow, oh, X, Y, ow+X, oh+Y)")
        
}

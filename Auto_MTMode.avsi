#Auto MTMode r1 - 06 August 2022
#Sets best MTMode automatically for filters that need to be set an MTMode manually
#Requests or fixes: https://github.com/DonCanjas/Avisynth-Functions

SetFilterMTMode("NNEDI3CL", 3, true)
SetFilterMTMode("KNLMeansCL", 3, true)

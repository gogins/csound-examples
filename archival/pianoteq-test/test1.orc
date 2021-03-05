


sr = 22050
ksmps = 2205
nchnls = 2

gihandle1 vstinit "C:\\Program Files\\Pianoteq 3.0 Trial\\Pianoteq30 Trial.dll",1
vstinfo gihandle1
vstedit gihandle1
instr 1
ainleft                 init                    0.0
ainright                init                    0.0
aleft, aright           vstaudiog               gihandle1,ainleft,ainright
outs aleft,aright
endin


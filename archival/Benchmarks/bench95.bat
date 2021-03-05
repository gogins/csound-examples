del times95

timer bach-d start >> times95
csound95 -Wd -o bach95.wav bach.orc bach.sco
timer bach-d end >> times95

timer bach-m start >> times95
csound95 -m0 -Wd -o bachm95.wav bach.orc bach.sco
timer bach-m end >> times95

timer riss-g start >> times95
csound95 -Wg -o risset195.wav risset1.orc risset1.sco
timer riss-g end >> times95

timer riss-m start >> times95
csound95 -Wm0 -d -o risset1m95.wav risset1.orc risset1.sco
timer riss-m end >> times95

timer guit-d start >> times95
csound95 -Wd -o guitar95.wav guitar.orc guitar.sco
timer guit-d end >> times95

timer guit-m start >> times95
csound95 -Wm0 -d -o guitarm95.wav guitar.orc guitar.sco
timer guit-m end >> times95

timer jame-g start >> times95
csoun95 -Wg -o james95.wav james.orc james.sco
timer jame-g end >> times95

timer pvanal start >> times95
pvanal pvtest.aif foo
timer pvanal end >> times95

timer lpanal start >> times95
lpcanal lptest.aif foo
timer lpanal end >> times95


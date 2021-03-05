del times

timer bach-d start >> times
csound -Wdb65535 -o bach.wav bach.orc bach.sco
timer bach-d end >> times

timer bach-m start >> times
csound -Wm0b512000 -d -o bachm.wav bach.orc bach.sco
timer bach-m end >> times

timer riss-g start >> times
csound -Wg -o risset1.wav risset1.orc risset1.sco
timer riss-g end >> times

timer riss-m start >> times
csound -Wm0 -d -o risset1m.wav risset1.orc risset1.sco
timer riss-m end >> times

timer guit-d start >> times
csound -Wd -o guitar.wav guitar.orc guitar.sco
timer guit-d end >> times

timer guit-m start >> times
csound -Wm0 -d -o guitarm.wav guitar.orc guitar.sco
timer guit-m end >> times

timer jame-g start >> times
csound -Wg -o james.wav james.orc james.sco
timer jame-g end >> times

timer pvanal start >> times
pvanal pvtest.aif foo
timer pvanal end >> times

timer lpanal start >> times
lpcanal lptest.aif foo
timer lpanal end >> times


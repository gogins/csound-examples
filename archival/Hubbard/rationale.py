#!/usr/bin/python2.5

#import Tkinter as tk
import Tix as tk
import tkFileDialog as tkfd
import tkMessageBox as tkmb
import tkColorChooser as tkcc
import math
import os
import threading
import sys
#from PIL import Image, ImageTk
import csnd
import notestorage
import odialog
import rdialog
import tdialog
import mdialog
import copy
import pickle

class rationaleApp:
    def __init__(self, parent):
        self.myparent = parent
        self.myparent.rowconfigure(0, weight=1)
        self.myparent.columnconfigure(0, weight=1)
        #note: instr/voice, time, dur, db, num, den, region, bar, selected, guihandle, arb-tuple
        self.notelist = []
        self.notewidgetlist = []
        #meter: bar, beats, count
        self.meterlist = []
#        self.meterlist = [[3,3,4],[5,6,8],[7,4,4]]
        #tempo: beat (in quarters), bpm, unit (in quarters)
        self.tempolist = []
#        self.tempolist = [[0, 60, 1], [5, 120, 1], [10, 240, 1.5]]
        #region: num, den, color, r11
        initregion = rdialog.region(self, 1, 1, '#999999', 240)
        self.regionlist = [initregion]
#        self.regionlist = [[1, 1, '#999999', 240]]
#        self.regionlist = [[1,1,999999,240],[3,2,999999,99.6089998269]]
        self.instlist = [0]
        self.instdefault = []
        self.csdimport = None
        self.csdimported = ''
        self.outautoload = False
        self.sf2list = []
        self.filetosave = None
        self.ties = {}
        self.barlist = []
        self.primelimit = 13
        self.editreference = None
        if sys.platform.count("win32"):
            self.shiftnum1 = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57]
            self.shiftnum2 = [96, 97, 98, 99, 100, 101, 102, 103, 104, 105]
        else:
            self.shiftnum1 = [19, 10, 11, 12, 13, 14, 15, 16, 17, 18]
            self.shiftnum2 = [90, 87, 88, 89, 83, 84, 85, 79, 80, 81]
        self.basefreq = 261.265
        self.curnum = 1
        self.curden = 1
        self.log2 = math.log(2)
        self.ctlkey = self.shiftkey = self.numkey = self.rkey = self.vkey = 0
        self.overdur = 0
#mode 0:add; 1:edit; 2:delete; 3:scrub
        self.welcome = 'Welcome to Rationale version 0.1\n'
        self.mode = tk.IntVar()
        self.modehelp = 'Press:\n\t"a" for ADD mode;\n\t"e" for EDIT mode;\n\t"d" for DELETE mode;\n\t"b" for SCRUB mode\n'
        self.stdouttext = tk.StringVar()
        self.stdouttext.set('%s\n%s\n' % (self.welcome,self.modehelp))
        self.playing = 0

### The Score Window ###
        self.scorebd = 3
        self.scoreh = 600
        self.scorew = 800
        self.scorecursor = "ur_angle"
        self.mainwin = tk.PanedWindow(self.myparent, orientation='horizontal', relief='ridge', bd=self.scorebd, height=self.scoreh, width=1040)
#        self.scorewin = tk.Frame(self.myparent, relief='ridge', bd=self.scorebd, height=self.scoreh, width=self.scorew)
        self.scorewin = self.mainwin.add('scorewin', size=self.scorew)
        self.scorewin.rowconfigure(3, weight=1)
        self.scorewin.columnconfigure(2, weight=1)
#        self.scorewin.grid(sticky='nesw')
        self.xscroll = tk.Scrollbar(self.scorewin, orient='horizontal', takefocus=0, troughcolor="#cc9966", activebackground="#bb8866", bg="#aa7755")
        self.xscroll.grid(row=4, column=2, sticky='ew')
        self.yscroll = tk.Scrollbar(self.scorewin, orient='vertical', takefocus=0, troughcolor="#cc9966", activebackground="#bb8866", bg="#aa7755")
        self.yscroll.grid(row=3, column=3, rowspan=1, sticky='ns')
#        self.stdoutwin = tk.Frame(self.scorewin, width=240)
        self.stdoutwin = self.mainwin.add('stdoutwin', size=240, before='scorewin')
#        self.stdoutwin.grid_propagate(0)
#        self.stdoutwin.grid(row=0, column=0, sticky='ns', rowspan=6)
        self.stdoutwin.rowconfigure(0, weight=1)
        self.stdoutwin.columnconfigure(0, weight=1)
        self.mainwin.grid(row=0, column=0, sticky='nesw')
        self.stdouttxt = tk.Text(self.stdoutwin, bg = "#114433", fg="#aaaaff")
        self.stdouttxt.grid(sticky='nesw')
        self.stdouttxt.insert('end', self.stdouttext.get())
        self.stdouttxt.configure(state="disabled")
        self.stdscroll = tk.Scrollbar(self.stdoutwin, orient='vertical', takefocus=0, troughcolor="#ccaaaa", activebackground="#cc7777", bg="#cc8f8f")
        self.stdouttxt.config(yscrollcommand=self.stdscroll.set)
        self.stdscroll.config(command=self.stdouttxt.yview)
        self.octaveres = 240
        self.yadj = self.octave11 = 240
        self.xquantize = .25
        self.xperquarter = 30
        self.xpxquantize = float(self.xquantize * self.xperquarter)
        self.miny = self.octave11 - self.octaveres * 5
        self.maxy = self.octave11 + self.octaveres * 5
        self.minx = -60
        self.maxx = 12000
        self.meters = tk.Canvas(self.scorewin, height=8, width=self.scorew, scrollregion=(self.minx,0,self.maxx,0), bg="#eeeeaa", confine="false")
        self.meters.myparent = self
        self.meters.grid(row=0, column=2, sticky='ew', pady=0)
        self.meters.bind("<Button-1>", self.meteradd)
        self.meters.bind("<Button-3>", self.openmeterdialog)
        self.meters.columnconfigure(1, weight=1)
        self.meterlabel = tk.Label(self.meters, text="meters", anchor='w', font=("Times",6), pady=0, bg="#eeeeaa")
        self.meterlabel.grid(row=0, column=0, sticky='w')
        self.tempos = tk.Canvas(self.scorewin, height=8, width=self.scorew, scrollregion=(self.minx,0,self.maxx,0), bg="#ddcccc", confine="false")
        self.tempos.myparent = self
        self.tempos.grid(row=1, column=2, sticky='ew', pady=0)
        self.tempos.bind("<Button-1>", self.tempoinit)
        self.tempos.bind("<B1-Motion>", self.tempoadjust)
        self.tempos.bind("<ButtonRelease-1>", self.tempoadd)
        self.tempos.bind("<Button-3>", self.opentempodialog)
        self.tempos.columnconfigure(1, weight=1)
        self.tempolabel = tk.Label(self.tempos, text="tempos", anchor='w', font=("Times",6), pady=0, bg="#ddcccc")
        self.tempolabel.grid(row=0, column=0, sticky='w')
        self.bars = tk.Canvas(self.scorewin, height=8, width=self.scorew, scrollregion=(self.minx,0,self.maxx,0), bg="#ccccee", confine="false")
        self.bars.grid(row=2, column=2, sticky='ew', pady=0)
        self.score = tk.Canvas(self.scorewin, width=self.scorew, height=self.scoreh, xscrollcommand=self.xscroll.set, yscrollcommand=self.yscroll.set, scrollregion=(self.minx, self.miny, self.maxx, self.maxy), confine="false", bg="#ffffff", cursor=self.scorecursor)
        self.score.rowconfigure(0, weight=1)
        self.score.columnconfigure(0, weight=1)
        self.score.grid(row=3, column=2, sticky='nesw')
        self.cursor = cursor(self)
        self.octaves = tk.Canvas(self.scorewin, width=10, height=self.scoreh, scrollregion=(0, self.miny, 0, self.maxy), bg="#99dd99", confine="false")
        self.octaves.rowconfigure(0, weight=1)
        self.octaves.grid(row=3,column=1, sticky='ns')
        self.xscroll.config(command=self.scorexscroll)
        self.yscroll.config(command=self.scoreyscroll)
        self.scorexscroll("moveto", 0.00242072)
        self.score.bind("<Button-2>", self.grab)
        self.score.bind("<B2-Motion>", self.scoredrag)
        self.score.bind("<Button-4>",
                              lambda
                              event, arg1="scroll", arg2=-1, arg3="units":
                              self.scoreyscroll(arg1, arg2, arg3))
        self.score.bind("<Button-5>",
                              lambda
                              event, arg1="scroll", arg2=1, arg3="units":
                              self.scoreyscroll(arg1, arg2, arg3))
        self.yscroll.bind("<Button-4>",
                              lambda
                              event, arg1="scroll", arg2=-1, arg3="units":
                              self.scoreyscroll(arg1, arg2, arg3))
        self.yscroll.bind("<Button-5>",
                              lambda
                              event, arg1="scroll", arg2=1, arg3="units":
                              self.scoreyscroll(arg1, arg2, arg3))
        self.drawoctaves(self.octave11)
        self.drawlines(1000)
#        self.score.create_rectangle(-3,self.miny,3,self.maxy, fill="#99cccc", outline="#555555", stipple="gray25", tags=("timecursor", "all"))
        self.hover = hover(self)

### Score Bindings ###
        self.score.bind("<Button-1>", self.buttondown)
        self.score.bind("<B1-Motion>", self.buttonmotion)
        self.score.bind("<Motion>",self.normalmotion)
        self.score.bind("<Shift-Motion>",self.shiftmotion)
        self.score.bind("<Shift-B1-Motion>", self.shiftbuttonmotion)
        self.score.bind("<ButtonRelease-1>",self.buttonup)
        self.score.bind("<Button-3>",self.popup)
        self.score.bind("<Key>",self.keypress)
        self.score.bind("<KeyRelease>",self.keyrelease)
        self.scorewin.bind("<Key>",self.keypress)
        self.scorewin.bind("<KeyRelease>",self.keyrelease)
        self.myparent.bind("<Key>",self.keypress)
        self.myparent.bind("<KeyRelease>",self.keyrelease)
        self.myparent.bind("<Shift-Right>", self.durmod8up)
        self.myparent.bind("<Shift-Left>", self.durmod8down)
        self.myparent.bind("<Shift-Up>", self.durmod6up)
        self.myparent.bind("<Shift-Down>", self.durmod6down)
        self.myparent.bind("<Control-q>", self.fileexit)
        self.myparent.bind("<Control-Q>", self.fileexit)
        self.myparent.bind("<Control-s>", self.filesave)
        self.myparent.bind("<Control-S>", self.filesave)
        self.myparent.bind("<Shift-Control-s>", self.filesaveas)
        self.myparent.bind("<Shift-Control-S>", self.filesaveas)
        self.myparent.bind("<Control-o>", self.fileopen)
        self.myparent.bind("<Control-O>", self.fileopen)
        self.myparent.bind("<Control-i>", self.fileimport)
        self.myparent.bind("<Control-I>", self.fileimport)
        self.myparent.bind("<Control-e>", self.fileexport)
        self.myparent.bind("<Control-E>", self.fileexport)
        self.myparent.bind("<Next>", self.cursor.nextbeat)
        self.myparent.bind("<Prior>", self.cursor.previousbeat)
        self.myparent.bind("<Control-Next>", self.cursor.nextbar)
        self.myparent.bind("<Control-Prior>", self.cursor.previousbar)
        self.myparent.bind("<Home>", self.cursor.home)
        self.myparent.bind("<Control-n>", self.filenew)
        self.myparent.bind("<Control-N>", self.filenew)
        self.myparent.bind("<Control-c>", self.editmodecopy)
        self.myparent.bind("<Control-C>", self.editmodecopy)
        self.myparent.bind("<Control-x>", self.editcut)
        self.myparent.bind("<Control-X>", self.editcut)
        self.myparent.bind("<Control-v>", self.editpaste)
        self.myparent.bind("<Control-V>", self.editpaste)
        self.myparent.bind("<n>", self.openregiondialog)
        self.myparent.bind("<N>", self.openregiondialog)
        self.myparent.bind("<p>", self.opentempodialog)
        self.myparent.bind("<P>", self.opentempodialog)
        self.myparent.bind("<m>", self.openmeterdialog)
        self.myparent.bind("<M>", self.openmeterdialog)
        self.myparent.bind_all("<Escape>", self.globalcancel)
#        self.myparent.bind("<n>", self.noteeditlistnew)
#        self.myparent.bind("<N>", self.noteeditlistnew)


### Score Menus ###
        self.menumain = tk.Menu(self.myparent)
        self.myparent.config(menu=self.menumain)
        self.menufile = tk.Menu(self.menumain, tearoff=0)
        self.menufile.add_command(label="New", command=self.filenew, underline=0)
        self.menufile.add_command(label="Open", command=self.fileopen, underline=0)
        self.menufile.add_command(label="Save", command=self.filesave, underline=0)
        self.menufile.add_command(label="Save As", command=self.filesaveas, underline=1)
        self.menufile.add_command(label="Import .ji", command=self.fileimport, underline=0)
        self.menufile.add_command(label="Export Csound", command=self.fileexport, underline=0)
        self.menufile.add_command(label="Exit Rationale", command=self.fileexit, underline=1)
        self.menumain.add_cascade(label="File", menu=self.menufile, underline=0)
        self.menuedit = tk.Menu(self.menumain, tearoff=0)
        self.menumode = tk.Menu(self.menuedit, tearoff=0)
        self.modeadd = self.menumode.add_radiobutton(label="Add", value=0, variable=self.mode, underline=0, command=self.modeannounce)
        self.modeedit = self.menumode.add_radiobutton(label="Edit", value=1, variable=self.mode, underline=0, command=self.modeannounce)
        self.modedelete = self.menumode.add_radiobutton(label="Delete", value=2, variable=self.mode, underline=0, command=self.modeannounce)
        self.modescrub = self.menumode.add_radiobutton(label="Scrub", value=3, variable=self.mode, underline=4, command=self.modeannounce)
        self.menumode.invoke(0)
        self.menuedit.add_cascade(label="Mode", menu=self.menumode, underline=0)
        self.menuedit.add_command(label="Select", command=self.editselect, underline=0)
        self.menuedit.add_command(label="Cut", command=self.editcut)
        self.menuedit.add_command(label="Copy", command=self.editmodecopy, underline=0)
        self.menuedit.add_command(label="Paste", command=self.editpaste, underline=0)
        self.menumain.add_cascade(label="Edit", menu=self.menuedit, underline=0)
        self.menuview = tk.Menu(self.menumain, tearoff=0)
        self.menumain.add_cascade(label="View", menu=self.menuview, underline=0)
        self.menuoptions = tk.Menu(self.menumain, tearoff=0)
        self.menumain.add_cascade(label="Options", menu=self.menuoptions, underline=0)
        self.menuhelp = tk.Menu(self.menumain, tearoff=0)
        self.menumain.add_cascade(label="Help", menu=self.menuhelp, underline=0)
        self.menupopup = tk.Menu(self.myparent, tearoff=0)
        self.menupopupregion = tk.Menu(self.menupopup, tearoff=0)
        for region in range(0, len(self.regionlist)):
            self.menupopupregion.add_command(label='%d' % region, command=lambda arg1=region: self.editregionassign(arg1))
        self.menupopupinst = tk.Menu(self.menupopup, tearoff=0)
        for inst in range(1, len(self.instlist)):
            self.menupopupinst.add_command(label='%d' % inst, command=lambda arg1=inst: self.editinstassign(arg1))
        self.menupopupvoice = tk.Menu(self.menupopup, tearoff=0)
        for voice in range(0, 6):
            self.menupopupvoice.add_command(label='%d' % voice, command=lambda arg1=voice: self.editvoiceassign(arg1))
        self.menupopup.add_cascade(label="Region", menu=self.menupopupregion)
        self.menupopup.add_cascade(label="Instrument", menu=self.menupopupinst)
        self.menupopup.add_cascade(label="Voice", menu=self.menupopupvoice)
        self.menupopup.add_command(label="Copy", command=self.editmodecopy)

        if len(sys.argv) > 1:
            try:
                self.fileopenwork(sys.argv[1])
            except:
                self.write('%s: File Not Found' % sys.argv[1])

    def ratioreduce(self, num, den, lim):
        for factor in range(2,lim+1):
            for i in range(0,15):
                if num % factor == 0 and den % factor == 0:
                    num /= factor
                    den /= factor
                else:
                    pass
        ret = (num,den)
        return ret

### Draw the barlines and beatlines ###
    def drawlines(self, bars):
        beats = 4
        count = 4
        ml = self.meterlist
        i = [(s.bar) for s in ml]
        x = 0
        barnum = 1
        for m in range(1, bars+1):
            if (m in i):
                ind = i.index(m)
                if ml[ind].top != 0:
                    beats = ml[ind].top
                if ml[ind].bottom != 0:
                    count = ml[ind].bottom
                self.meters.create_text(x,-1,anchor="n",fill="#555522",text='%d/%d' % (beats,count),font=("Times",7), tags="x")
            bar = self.score.create_line(x,self.miny,x,self.maxy,width=2,fill="#999999", tags=("barline", "x"))
            barnumdisp = self.bars.create_text(x,-1,anchor="n",fill="#222222",text=str(barnum), font=("Times",7), tags="x")
            self.barlist.append(bar)
            x += self.xperquarter * 4 / count
            barnum = barnum + 1
            for b in range(1,beats):
                bar = self.score.create_line(x,self.miny,x,self.maxy,width=1,fill="#aaaaaa", tags=("beatline", "all"))
                self.barlist.append(bar)
                x += self.xperquarter * 4 / count

    def redrawlines(self, *args):
        self.meters.delete("all")
        self.bars.delete("all")
        self.score.delete("barline")
        self.score.delete("beatline")
        self.barlist[:] = []
        self.drawlines(1000)

    def drawoctaves(self, new11):
        y = self.octave11 - 5 * self.octaveres
        num = 32
        den = 1
        coloroctnum = "#228822"
        linelength = 1000 * self.xperquarter * 4
        try:
            line = self.line11
            ydelta = new11 - self.octave11
            if abs(ydelta) > 240:
                ydiv = 64
            elif abs(ydelta) > 120:
                ydiv = 32
            else:
                ydiv = 16
            yincr = float(ydelta)/ydiv
            for incr in range(0, ydiv):
                self.score.move("octaveline",0,yincr)
                self.octaves.move("octavetext",0,yincr)
                self.scorewin.update_idletasks()
        except:
            self.perm11 = self.score.create_line(-60,self.octave11,linelength,self.octave11,width=4,fill="#aaaaaa", tags=("all", "perm11"))
            for up in range(0,5):
                self.score.create_line(-60,y,linelength,y,width=2,fill="#bbbbbb",tags=("octaveline", "all"))
                self.octaves.create_text(6,y,anchor="s",text=str(num),fill=coloroctnum,tags=("octavetext", "y"),font=("Times",9))
                self.octaves.create_text(6,y,anchor="n",text=str(den),fill=coloroctnum,tags=("octavetext", "y"),font=("Times",9))
                num /= 2
                y += self.octaveres
            self.line11 = self.score.create_line(-60,y,linelength,y,width=2,fill="#7777bb",tags=("octaveline", "y"))
            self.octaves.create_text(6,y,anchor="s",text=str(num),fill=coloroctnum,tags=("octavetext", "y"),font=("Times",14))
            self.octaves.create_text(6,y,anchor="n",text=str(den),fill=coloroctnum,tags=("octavetext", "y"),font=("Times",14))
            for down in range(0,6):
                y += self.octaveres
                den *= 2
                self.score.create_line(-60,y,linelength,y,width=2,fill="#bbbbbb",tags=("octaveline", "y"))
                self.octaves.create_text(6,y,anchor="s",text=str(num),fill=coloroctnum,tags=("octavetext", "y"),font=("Times",9))
                self.octaves.create_text(6,y,anchor="n",text=str(den),fill=coloroctnum,tags=("octavetext", "y"),font=("Times",9))

######## prepare csd file
    def preparecsd(self, event, instlist, counter):
        self.scsort()
        if self.outautoload == True:
            self.csdreload()

        playscore = self.notelist
        if self.tempolist:
#            print self.tempolist[0].bar.get(), self.tempolist[0].beat.get()
            self.csdsco = 't'
            for t in self.tempolist:
                self.csdsco += ' %f %f' % (t.scobeat, t.bpm*4/t.unit)
            self.write('Tempos: %s' % self.csdsco)
            self.csdsco += '\n'
        else:
            self.csdsco = ''
        if self.cursor.beat != 0:
            self.ratstart = self.cursor.center / self.xperquarter
            astring = 'a 0 0 %d\n' % self.ratstart
            self.csdsco += astring
        else:
            self.ratstart = 0
        self.csdsco += '#define RATSTART # %f #\n' % float(self.ratstart)
        if self.csdimported.count("<CsScore>"):
            scostart = self.csdimported.find("<CsScore>") + 9
            scoend = self.csdimported.find("</CsScore>")
            self.csdsco += self.csdimported[scostart:scoend]
#        else:
#            self.csdsco = ''

        for i in range(0,len(playscore)):
            note = playscore[i]
            if note.voice == 0:
                held = "No"
            else:
                held = "Yes"
            if note.sel == 1:
                selected = "Yes"
            else:
                selected = "No"
#            region = note.region
#            rnum = self.regionlist[region][0]
#            rden = self.regionlist[region][1]
#            freq = (float(rnum * note.num))/(float(rden * note.den)) * self.basefreq
            if float(note.inst) < len(instlist):
                instr = float(note.inst) + .001 * float(note.voice)
                if instlist[note.inst].mute == 0:
                    for outline in instlist[note.inst].outlist:
                        if outline.mute == 0:
                            if outline.__class__.__name__ == 'csdout':
                                lineguide = outline.string.split()
                                line = 'i ' + lineguide[0]
                                for pfield in range(1,len(lineguide)):
                                    line += ' '
                                    line += str(note.dict[lineguide[pfield]])
                                line += '\n'
                                self.csdsco += line
#                self.csdsco += 'i%f %f %d %f %f\n' % (instr, note.time, note.dur, note.db, note.freq)
            else:
                self.csdsco += 'i %s %f %d %f %f\n' % ('"ratdefault"', note.time, note.dur, note.db, note.freq)
        if counter == 1:
            icounter = 0
            if len(playscore):
                last = playscore[len(playscore)-1]
                while icounter < last.time+last.dur:
                    self.csdsco += 'i "ratcounter" %f .0625\n' % icounter
                    icounter += .0625
#        self.write(self.csdsco)
        if sys.platform.count('win'):
            self.csdopt = '''
csound -+rtaudio=portaudio -odac -m0d test.orc test.sco
'''
        if sys.platform.count('linux'):
            grepjackd = os.popen('ps aux | grep jackd | grep -v grep','r')
            jackd = grepjackd.readlines()
            if len(jackd):
                self.csdopt = '''
csound -+rtaudio=jack -odac:alsa_pcm:playback_ -m0d test.orc test.sco
'''
            else:
                self.csdopt = '''
csound -+rtaudio=alsa -odac -m0d test.orc test.sco
'''
        if self.csdimported.count("<CsInstruments>"):
            orcstart = self.csdimported.find("<CsInstruments>") + 15
            orcend = self.csdimported.find("</CsInstruments>")
            self.csdimportinst = self.csdimported[orcstart:orcend]
        else:
            self.csdimportinst = ''
        self.csdinst = '''
gidefaultinst  ftgen   0, 0, 2048, 10, 1, .2, .1
girattcursor init 0
girattcursor chnexport "rattime", 2
girattimeskip init 0
girattimeskip chnexport "rattimeskip", 1
''' + self.csdimportinst + '''
instr +ratdefault
iamp = ampdb(p4)/6
ifreq   =       p5
idur    =       p3
;print   ifreq
aamp    transeg 0, .004, 1, iamp, idur-.01, 1, iamp * .4, .006, 1, 0
        print   gidefaultinst
aosc    oscil   1, ifreq, gidefaultinst
aenv    =       aosc * aamp
aout    =       aenv
outrg 1, aout, aout
endin

instr +ratcounter
girattcursor = girattcursor + .0625
endin
'''
        self.csdcsd = '''
<CsoundSynthesizer>
<CsOptions>
''' + self.csdopt + '''
</CsOptions>
<CsInstruments>
''' + self.csdinst + '''
</CsInstruments>
<CsScore>
''' + self.csdsco + '''
</CsScore>
</CsoundSynthesizer>
'''

    def csdreload(self):
        if self.outautoload == True and self.csdimport != None:
            file = open(self.csdimport)
            self.csdimported = ''
            for line in file:
                self.csdimported += line
            try:
                self.out.csdtext.delete(1.0, "end")
                self.out.csdtext.insert("end", self.csdimported)
            except:
                pass



### Play ###
    def play(self, instlist):
        #note: instr/voice, time, dur, db, num, den, region, selected, guihandle, arb-tuple
#        print threading.enumerate()
        if len(self.notelist):
            self.playing = 1
            self.preparecsd(self, instlist, 1)
##### comment out next line to worsen performance
#            self.score.unbind("<Motion>")

            # Create an instance of CppSound.
            self.cs = csnd.CppSound()
            # Create the Csound thread and start it.
            self.csThread = threading.Thread(None, self.csThreadRoutine)
            self.csThread.start()
#        cs.setPythonMessageCallback()

    def csThreadRoutine(self):
        self.cs.setCSD(self.csdcsd)
        self.cs.exportForPerformance()
        self.cs.compile()
        self.cs.SetChannel("rattime", 0)
        self.cs.SetChannel("rattimeskip", self.ratstart)
        self.perf = csnd.CsoundPerformanceThread(self.cs)
#        self.perf.SetProcessCallback(self.cscb, self.cs)
        self.perf.Play()
        t = threading.Timer(.0625, self.timed)
        t.start()

    def timed(self):
#        print threading.activeCount()
        time = self.cs.GetChannel("rattime")
        self.cursor.scroll(time)
        if self.perf.GetStatus() == 0:
            t = threading.Timer(.0625, self.timed)
            t.start()
        else:
            self.playing = 0
            self.perf.Stop()
##### comment out next line to worsen performance
#            self.score.bind("<Motion>",self.normalmotion)
#            print threading.enumerate()
#            print threading.activeCount()
            coords = self.score.coords(self.barlist[self.cursor.beat])
            self.score.coords(self.cursor.widget, coords[0]-3, self.miny, coords[0]+3, self.maxy)

#    def cscb(self, csound):
#        time = self.cs.GetChannel("rattime")
#        pos = time * self.xperquarter
#        self.score.coords("timecursor", pos-6, miny, pos+6, maxy)

    def stop(self):
        self.playing = 0
        if len(self.notelist):
            self.perf.Stop()
##### comment out next line to worsen performance
#            self.score.bind("<Motion>",self.normalmotion)
            coords = self.score.coords(self.barlist[self.cursor.beat])
            self.score.coords(self.cursor.widget, coords[0]-3, self.miny, coords[0]+3, self.maxy)

### Tonality Change###
    def tonchange(self, innum, inden):
        curnum = self.curnum * innum
        curden = self.curden * inden
        curratio = self.ratioreduce(curnum,curden,self.primelimit)
        self.curnum = curratio[0]
        self.curden = curratio[1]
        self.drawoctaves(self.yadj)
        self.regionlist[self.hover.hregion].num = self.curnum
        self.regionlist[self.hover.hregion].den = self.curden
        # this next assignment has to be after the call to drawoctaves because that function compares yadj and octave11 to move the lines #
        self.regionlist[self.hover.hregion].octave11 = self.octave11 = self.yadj
        for i in range(0,len(self.notelist)):
            if self.notelist[i].region == self.hover.hregion:
                note = self.notelist[i]
                notewidget = self.notewidgetlist[i]
                num = note.num * inden
                den = note.den * innum
                ratio = self.ratioreduce(num,den,self.primelimit)
                note.num = ratio[0]
                note.den = ratio[1]
                self.notelist[i] = note
                notewidget.updateregion()
        self.score.itemconfigure(self.hover.hrnumdisp, text=str(self.curnum))
        self.score.itemconfigure(self.hover.hrdendisp, text=str(self.curden))
        hnum = self.hover.hnum * inden
        hden = self.hover.hden * innum
        hratio = self.ratioreduce(hnum, hden, self.primelimit)
        self.hover.hnum = hratio[0]
        self.hover.hden = hratio[1]
        self.score.itemconfigure(self.hover.hnumdisp, text=str(self.hover.hnum))
        self.score.itemconfigure(self.hover.hdendisp, text=str(self.hover.hden))
        self.hover.log1 = math.log(float(self.hover.hnum)/float(self.hover.hden))
        self.hover.logged = self.hover.log1/self.log2
        self.yadj = self.octave11 - (self.hover.logged * self.octaveres)
        self.write('New Tonality: %d/%d' % (self.curnum,self.curden))
        self.textsize = 24
        rtext = 'Region "%d" x %d/%d\n= %d/%d' % (self.hover.hregion, innum, inden, self.curnum, self.curden)
        self.write(rtext)
#        scrx = self.score.winfo_width()/2
#        scry = self.score.winfo_height()/2
#        x = self.score.canvasx(scrx)
#        y = self.score.canvasy(scry)
 #       self.score.create_text(x, y, fill="#e0e0e0", justify="center", text=rtext, font=("Arial", self.textsize), tags=("temptext", "all"))
#        self.score.lower("temptext")
#        t = threading.Timer(0.0625, self.getbigger)
#        t.start()
#
#    def ton11(self):
#        region = self.hover.hregion
#        num = self.curden
#        den = self.curnum
#        hnum = self.hover.hnum * num
#        hden = self.hover.hden * den
#        hratio = self.ratioreduce(hnum, hden, self.primelimit)
#        for i in range(len(self.notelist)):
#            if self.notelist[i].region == self.hover.hregion:
#                note = self.notelist[i]
#        self.score.itemconfigure(self.hover.hnumdisp, text=str(hratio[0]))
#        self.score.itemconfigure(self.hover.hdendisp, text=str(hratio[1]))
#        self.score.itemconfigure(self.hover.hrnumdisp, text='1')
#        self.score.itemconfigure(self.hover.hrdendisp, text='1')

### Sort extant score notes ###
    def scsort(self):
        sc = self.notewidgetlist
        sorter=[(s.purex,s) for s in sc]
        sorter.sort()
        self.notewidgetlist[:]=[t[1] for t in sorter]
        self.notelist = [notewidget.note for notewidget in self.notewidgetlist]

    def buttondown(self, event):
        self.menupopup.unpost()
        if self.mode.get() == 1:
            if self.overdur == 0:
                if self.editreference != None:
                    if self.editreference.note.sel == 1:
                        pass
                    else:
                        for notewidget in self.notewidgetlist:
                            notewidget.note.sel = 0
                            outline = self.score.itemcget(notewidget.notewidget, "fill")
                            self.score.itemconfig(notewidget.notewidget, width=1, outline=outline)
                        self.score.itemconfig(self.editreference.notewidget, width=3, outline='#ff6670')
                        self.editreference.note.sel = 1
                else:
                    self.selectbox = selectbox(self, event)
            else:
                self.durgrab(event)

    def durgrab(self, event):
        self.dragcoords = self.score.coords("durdrag")
        self.startinit = self.dragcoords[4]
        self.leninit = self.dragcoords[8]-self.dragcoords[4]
        self.durinit = self.leninit/self.xperquarter

    def durdrag(self, event):
        todrag = self.score.find_withtag("durdrag")[0]
        newpurx = self.score.canvasx(event.x) - self.startinit
        if newpurx > 0:
            newdurx = math.ceil(newpurx/self.xpxquantize) * self.xpxquantize
#            newcoords = (self.dragcoords[0:8])
#            newcoords.append(newdurx + self.startinit)
#            newcoords.append(self.dragcoords[9])
#            self.score.coords(todrag, tuple(newcoords))
            for notewidget in self.notewidgetlist:
                 if notewidget.notewidget == todrag:
                    notewidget.note.dur = float(newdurx)/self.xperquarter
                    notewidget.note.dict['dur'] = notewidget.note.dur
                    notewidget.updatedur()

#        for note in self.notelist:
#            if "durdrag" in self.score.gettags(note.widget):
#                newpurx = self.score.canvasx(event.x) - self.startinit
#                if newpurx > 0:
#                    newdurx = math.ceil(newpurx/self.xpxquantize) * self.xpxquantize
#                    newcoords = (self.dragcoords[0:8])
#                    newcoords.append(newdurx + self.startinit)
#                    newcoords.append(self.dragcoords[9])
#                    self.score.coords(note.widget, tuple(newcoords))
#                    note.dur = float(newdurx)/self.xperquarter
#                    note.dict['dur'] = note.dur

    def shiftbuttonmotion(self, event):
        if self.mode.get() == 1:
            if self.overdur == 0:
                if self.editreference != None:
                    widget = event.widget
                    realx = widget.canvasx(event.x)
                    quantizedx = int(realx/self.xpxquantize) * self.xpxquantize
                    xdelta = quantizedx - self.editreference.purex
                    for notewidget in self.notewidgetlist:
                        note = notewidget.note
                        if note.sel == 1:
                            notewidget.purex += xdelta
                            note.time = notewidget.purex / self.xperquarter
                            notewidget.updatetime()

    def buttonmotion(self, event):
        if self.mode.get() == 1:
            if self.overdur == 0:
                if self.editreference == None:
                    self.selectbox.adjust(event)
                else:
##############
                    widget = event.widget
                    realy = widget.canvasy(event.y)
                    yloc = self.regionlist[self.editreference.note.region].octave11 - realy
                    ynotestorage = int(yloc * 240 / self.octaveres) % self.octaveres
                    prenum = notestorage.notebank[ynotestorage][1]
                    preden = notestorage.notebank[ynotestorage][2]
                    if yloc > self.octaveres:
                        prenum *= 2**int((yloc)/self.octaveres)
                    elif yloc < 0:
                        preden *= 2**(0-((int(yloc)/self.octaveres)))
#                    ratio = self.ratioreduce(prenum,preden,self.primelimit)
#                    num = ratio[0]
#                    den = ratio[1]
                    numdelta = prenum * self.editreference.note.den
                    dendelta = preden * self.editreference.note.num
                    for notewidget in self.notewidgetlist:
                        if notewidget.note.sel == 1:
                            note = notewidget.note
                            ratio = self.ratioreduce(note.num*numdelta, note.den*dendelta, self.primelimit)
                            note.num = ratio[0]
                            note.den = ratio[1]
                            self.score.itemconfig(notewidget.numwidget, text=str(note.num))
                            self.score.itemconfig(notewidget.denwidget, text=str(note.den))
                            notewidget.updateheight()
                            self.tiedraw(note.inst, note.voice)
##############
            else:
                self.durdrag(event)

    def normalmotion(self, event):
#        self.scoredrag(event)
        if self.mode.get() == 0:
            self.hover.hovermotion(event)
            self.otherseek(event)
        elif self.mode.get() == 1:
            self.editseek(event)
        elif self.mode.get() == 2:
            self.deleteseek(event)
        else:
            self.otherseek(event)
#        self.editseek(event)

    def shiftmotion(self, event):
        if self.mode.get() == 1:
            self.editseek(event)

    def otherseek(self, event):
        self.score.itemconfig("note", stipple="")
        self.score.dtag("note", "edit")
        widget = event.widget
        realx = widget.canvasx(event.x)
        realy = widget.canvasy(event.y)
        notes = self.score.find_overlapping(realx-10, realy-10, realx+10, realy+10)
        note = 0
        absall = 10
        tempflag = 0
        flag = 0
        for match in notes:
            if "note" in self.score.gettags(match):
                coords = self.score.coords(match)
                mainxy = (coords[0], coords[1])
                maindist = math.sqrt((mainxy[0]-realx)**2 + (mainxy[1]-realy)**2)
                if maindist < absall:
                    absall = maindist
                    note = match
                self.score.itemconfig(note, stipple="gray50")
                self.score.addtag_withtag("edit", note)

    def editseek(self, event):
        self.score.itemconfig("note", stipple="")
        self.score.dtag("note", "edit")
        widget = event.widget
        realx = widget.canvasx(event.x)
        realy = widget.canvasy(event.y)
        notes = self.score.find_overlapping(realx-10, realy-10, realx+10, realy+10)
        note = 0
        absall = 10
        tempflag = 0
        flag = 0
        for match in notes:
            if "note" in self.score.gettags(match):
                coords = self.score.coords(match)
                mainxy = (coords[0], coords[1])
                durxy = (coords[8], coords[9])
                maindist = math.sqrt((mainxy[0]-realx)**2 + (mainxy[1]-realy)**2)
                durdist = math.sqrt((durxy[0]-realx)**2 + (durxy[1]-realy)**2)
                if durdist < maindist:
                    abs = durdist
                    tempflag = 1
                else:
                    abs = maindist
                    tempflag = 0
                if abs < absall:
                    absall = abs
                    note = match
                    flag = tempflag
        if note == 0:
            self.overdur = 0
            self.score.configure(cursor="pencil")
            self.score.dtag("note", "durdrag")
            self.editreference = None
        else:
            if flag == 1:
                self.overdur = 1
                self.score.configure(cursor="right_side")
                self.score.addtag_withtag("durdrag", note)
            if flag == 0:
                self.overdur = 0
                if self.shiftkey == 0:
                    self.score.configure(cursor="sb_v_double_arrow")
                else:
                    self.score.configure(cursor="sb_h_double_arrow")
                self.score.itemconfig(note, stipple="gray50")
                self.score.addtag_withtag("edit", note)
                for notewidget in self.notewidgetlist:
                    if notewidget.notewidget == note:
                        self.editreference = notewidget

#                self.score.addtag_withtag("editreference", note)
#                self.selectbox = selectbox(self, event)
#                if 
                
### Add a Note ###
    def buttonup(self, event):
        winfo = (str(self.scorewin.winfo_name()))
        winfocus = (str(self.scorewin.focus_get()))
# conditional based on whether window is active #
#        if (winfocus.endswith(winfo)):
        if winfocus != None and self.mode.get() == 0:
            ### Add Note ###
            inst = self.hover.hinst
            time = self.hover.posx/self.xperquarter
            dur = self.hover.entrydur
            db = self.hover.hdb
            num = self.hover.hnum
            den = self.hover.hden
            voice = self.hover.hvoice
            if voice == 0:
                held = 0
            else:
                held = 1
            region = self.hover.hregion
            rnum = self.regionlist[region].num
            rden = self.regionlist[region].den
            rcolor = self.regionlist[region].color
            sel = 0
            arb = []
            yloc = self.yadj
            locy2 = yloc
            locy0 = yloc - self.hover.hyoff
            locy1 = yloc + self.hover.hyoff
            ry0 = yloc - 15
            ry1 = yloc + 15
#            newnote = self.score.create_polygon(self.hover.hovx2,locy2,self.hover.hovx0,locy0,self.hover.hovx1,locy1,self.hover.hovx2,locy2,self.hover.hcrossx3,locy2,fill=self.hover.entrycolor,outline=self.hover.entrycolor, tags=("note", "all"))
#            newnotenum = self.score.create_text(self.hover.hovx0,locy2,anchor="se",fill=self.hover.entrycolor,text=str(self.hover.hnum), tags="all")
#            newnoteden = self.score.create_text(self.hover.hovx0,locy2,anchor="ne",fill=self.hover.entrycolor,text=str(self.hover.hden), tags="all")
#            regionnum = self.score.create_text(self.hover.hovx2,ry0,anchor="se",fill=rcolor,text=str(rnum),font=("Times",10), tags="all")
#            regionden = self.score.create_text(self.hover.hovx2,ry1,anchor="ne",fill=rcolor,text=str(rden),font=("Times",10), tags="all")
#            regiondisp = self.score.create_text(self.hover.hovx2, locy2, anchor="sw", fill=rcolor, text='r' + str(region), font=("Times",10), tags="all")
#            voicedisp = self.score.create_text(self.hover.hovx2, locy2, anchor="nw", fill=self.hover.entrycolor, text=str(voice), font=("Times", 10), tags="all")
            noteinstance = note(self, self.hover.hinst, self.hover.hvoice, time, dur, db, num, den, region, sel)
            self.notelist.append(noteinstance)
            notewidgetinstance = notewidgetclass(self, noteinstance)
            self.notewidgetlist.append(notewidgetinstance)
#            self.tiedraw(self.hover.hinst, self.hover.hvoice)

        elif winfocus != None and self.mode.get() == 1:
            if self.overdur == 0 and self.editreference == None:
                self.score.delete(self.selectbox.widget)
                del self.selectbox

        elif winfocus != None and self.mode.get() == 2:
            ### Delete Note ###
            deletematch = self.score.find_withtag("delete")
            if deletematch:
                todel = deletematch[0]
                for notemember in range(len(self.notewidgetlist)):
                    if self.notewidgetlist[notemember].notewidget == todel:
                        notewidget = self.notewidgetlist[notemember]
                        tieinst = self.notelist[notemember].inst
                        tievoice = self.notelist[notemember].voice
                        notewidget.undraw()
                        del self.notewidgetlist[notemember]
                        del self.notelist[notemember]
                        self.tiedraw(tieinst, tievoice)
                        break

    def write(self,s):
        self.stdouttxt.configure(state='normal')
        self.stdouttxt.insert('end', '%s\n\n' % s)
        self.stdouttxt.configure(state='disabled')
        self.stdouttxt.update_idletasks()
        if self.stdscroll.winfo_ismapped():
            pass
        else:
            if self.stdscroll.get() != (0.0, 1.0):
                self.stdscroll.grid(row=0, column=1, rowspan=1, sticky='ns')
        self.stdouttxt.see('end')


#    def getbigger(self):
#        self.textsize *= 1.1
#        self.score.itemconfigure("temptext", font=("Arial", int(self.textsize)))
#        if self.textsize > 160:
#            self.score.delete("temptext")
#        else:
#            t = threading.Timer(0.0625, self.getbigger)
#            t.start()

    def openregiondialog(self, event):
        try:
            self.regiondialog.regionfr.lift()
            self.regiondialog.regionfr.focus_set()
        except:
            self.regiondialog = rdialog.regiondialog(self)
        self.ctlkey = 0

    def opentempodialog(self, event):
        try:
            self.tempodialog.tempofr.lift()
            self.tempodialog.tempofr.focus_set()
        except:
            self.tempodialog = tdialog.tempodialog(self)
        self.ctlkey = 0

    def openmeterdialog(self, event):
        try:
            self.meterdialog.meterfr.lift()
            self.meterdialog.meterfr.focus_set()
        except:
            self.meterdialog = mdialog.meterdialog(self)
        self.ctlkey = 0

    def globalcancel(self, event):
        pass


    def keypress(self, event):
#        print event.keysym
#        print event.keycode
#        print event.keysym_num
        if event.keysym.count("Shift"):
            self.hinstch = 0
            self.shiftkey = 1
            if self.mode.get() == 1 and self.editreference != None:
                self.score.configure(cursor="sb_h_double_arrow")
        if event.keysym.count("Control"):
            self.ctlkey = 1
        if self.shiftkey == self.ctlkey == self.rkey == 0 and self.vkey == 1:
            if event.keysym in "1234567890":
                self.hover.hvoice = 10 * self.hover.hvoice + int(event.keysym)
                self.score.itemconfigure(self.hover.hvoicedisp, text=str(self.hover.hvoice))
                self.write(str(self.hover.hvoice))
        if self.shiftkey == 1 and self.ctlkey == self.rkey == self.vkey == 0:
            if event.keycode in self.shiftnum1:
#############################################
#                print event.keycode
                self.hinstch = self.hinstch * 10 + self.shiftnum1.index(event.keycode)
            elif event.keycode in self.shiftnum2:
                print event.keycode
                self.hinstch = self.hinstch * 10 + self.shiftnum2.index(event.keycode)
        if self.ctlkey == self.shiftkey == self.rkey == self.vkey == 0:
            if event.keysym == "comma" or event.keysym == "less":
                self.xquantize = float(1)/float(6)
                self.xpxquantize = float(self.xquantize * self.xperquarter)
            if event.keysym == "period" or event.keysym == "greater":
                self.xquantize = .25
                self.xpxquantize = float(self.xquantize * self.xperquarter)
            if event.keysym == "r" or event.keysym == "R":
                if self.hover.hregion:
                    self.hover.hregion = 0
                self.rkey = 1
            elif event.keysym == "v" or event.keysym == "V":
                oldinst = self.hover.hinst
                oldvoice = self.hover.hvoice
#                self.hover.hinst = self.hover.hinst & 1073740800
                self.hover.hvoice = 0
                self.tiedraw(oldinst, oldvoice)
                self.vkey = 1
    # Score Modes #
            if event.keysym == "a" or event.keysym == "A":
                self.menumode.invoke(0)
            elif event.keysym == "e" or event.keysym == "E":
                self.menumode.invoke(1)
            elif event.keysym == "d" or event.keysym == "D":
                self.menumode.invoke(2)
            elif event.keysym == "b" or event.keysym == "B":
                self.menumode.invoke(3)
            if event.keysym == "space":
                if self.numkey == 0:
                    if self.playing == 0:
                        self.play(self.instlist)
                    else:
                        self.stop()
##### comment out next line to worsen performance
#                        self.score.bind("<Motion>",self.normalmotion)


    # Durations #
            if self.mode.get() == 0:
            #32nd note#
                if event.keysym == "1":
                    self.numkey = 1
                    self.durupdate(.125)
            #16th note#
                elif event.keysym == "2":
                    self.numkey = 1
                    self.durupdate(.25)
            #8th note#
                elif event.keysym == "3":
                    self.numkey = 1
                    self.durupdate(.5)
            #quarter note#
                elif event.keysym == "4":
                    self.numkey = 1
                    self.durupdate(1)
            #half note#
                elif event.keysym == "5":
                    self.numkey = 1
                    self.durupdate(2)
            #whole note#
                elif event.keysym == "6":
                    self.numkey = 1
                    self.durupdate(4)
            #double whole note#
                elif event.keysym == "7":
                    self.numkey = 1
                    self.durupdate(8)
            #and so on#
                elif event.keysym == "8":
                    self.numkey = 1
                    self.durupdate(16)
                elif event.keysym == "9":
                    self.numkey = 1
                    self.durupdate(32)
            # "t" while holding number sets triplet of duration #
                if event.keysym == "t" or event.keysym == "T":
                    if self.numkey == 1:
                        self.durupdate(self.hover.entrydur*(2.0/3.0))
                    else:
                        self.tonchange(self.hover.hnum, self.hover.hden)
                if event.keysym == "g" or event.keysym == "G":
                    self.yadj = 240
                    self.tonchange(self.curden, self.curnum)
            # "space" while holding number sets dotted value of duration #
                if event.keysym == "space":
                    if self.numkey == 1:
                        self.durupdate(self.hover.entrydur*1.5)
                if event.keysym == "y" or event.keysym == "Y":
                    self.hover.increase(self.hover)
                if event.keysym == "h" or event.keysym == "H":
                    self.hover.decrease(self.hover)
            if event.keysym == "o" or event.keysym == "O":
                try:
                    self.out.outputfr.lift()
                    self.out.outputfr.focus_set()
                except:
                    self.out = odialog.outputdialog(self)

    # Region change #
        if self.rkey == 1 and self.ctlkey == self.shiftkey == 0 and str.isdigit(event.keysym):
            self.hover.hregion = self.hover.hregion * 10 + int(event.keysym)

    def keyrelease(self,event):
#        self.write(str(event.keysym))
        if event.keysym.count("Shift"):
            if self.mode.get() == 0:
                oldinst = self.hover.hinst
                if self.hinstch >= len(self.instlist):
                    self.hinstch = len(self.instlist)
                    self.write('New Instrument: %d' % self.hinstch)
                    newinst = odialog.instrument(self, self.hinstch, '#999999')
                    self.instlist.append(newinst)
                    try:
                        dummy = self.out
                        self.out.instmaybe = copy.deepcopy(self.instlist)
                        newinstpage = odialog.instrumentpage(self.out, newinst)
                        odialog.instpagelist.append(newinstpage)
                    except:
                        pass
                if self.hinstch > 0:
                    self.hover.hinst = self.hinstch
                    self.tiedraw(oldinst, self.hover.hvoice)
                    self.tiedraw(self.hover.hinst, self.hover.hvoice)
                    self.write(str(self.hover.hinst))
                    self.hover.colorupdate(self)
            self.shiftkey = 0
            if self.mode.get() == 1 and self.editreference != None:
                self.score.configure(cursor="sb_v_double_arrow")
        elif event.keysym.count("Control"):
            self.ctlkey = 0
        if event.keysym == "r" or event.keysym.count == "R":
            self.regionchange()
            self.rkey = 0
        if event.keysym == "v" or event.keysym.count == "V":
            self.tiedraw(self.hover.hinst, self.hover.hvoice)
            self.score.itemconfigure(self.hover.hvoicedisp, text=str(self.hover.hvoice))
            self.voicechange()
            self.vkey = 0
        if event.keysym in "1234567890":
            self.numkey = 0
        if event.keysym.count("equal") or event.keysym.count("plus"):
            self.zoom("in")
        if event.keysym.count("underscore") or event.keysym.count("minus"):
            self.zoom("out")

    def regionchange(self):
        if self.hover.hregion >= len(self.regionlist):
            self.hover.hregion = len(self.regionlist)
            region = copy.deepcopy(self.regionlist[self.hover.oldhregion])
            self.regionlist.append(region)
            self.score.itemconfigure(self.hover.hregiondisp, text='r'+str(self.hover.hregion))
        elif self.hover.hregion != self.hover.oldhregion:
            region = self.regionlist[self.hover.hregion]
            oldregion = self.regionlist[self.hover.oldhregion]
            hnum = self.hover.hnum * region.den * oldregion.num
            hden = self.hover.hden * region.num * oldregion.den
            hratio = self.ratioreduce(hnum, hden, self.primelimit)
            rcolor = region.color
            self.hover.hnum = hratio[0]
            self.hover.hden = hratio[1]
            self.curnum = region.num
            self.curden = region.den
            self.score.itemconfigure(self.hover.hnumdisp, text=str(self.hover.hnum))
            self.score.itemconfigure(self.hover.hdendisp, text=str(self.hover.hden))
            self.score.itemconfigure(self.hover.hrnumdisp, text=str(region.num), fill=rcolor)
            self.score.itemconfigure(self.hover.hrdendisp, text=str(region.den), fill=rcolor)
            self.score.itemconfigure(self.hover.hregiondisp, text='r'+str(self.hover.hregion), fill=rcolor)
            self.drawoctaves(region.octave11)
            self.octave11 = region.octave11
            self.hover.log1 = math.log(float(self.hover.hnum)/float(self.hover.hden))
            self.hover.logged = self.hover.log1/self.log2
            self.yadj = self.octave11 - (self.hover.logged * self.octaveres)
        else:
            region = self.regionlist[self.hover.hregion]
        self.hover.oldhregion = self.hover.hregion
#        self.write('%s%d =' % ("Region: ",self.hregion))
#        self.write('%d/%d' % (self.regionlist[self.hregion][0],self.regionlist[self.hregion][1]))
        self.textsize = 24
        rtext = 'Region %d\n= %d/%d' % (self.hover.hregion, region.num, region.den)
        self.write(rtext)
#        scrx = self.score.winfo_width()/2
#        scry = self.score.winfo_height()/2
#        x = self.score.canvasx(scrx)
#        y = self.score.canvasy(scry)
#        self.score.create_text(x, y, fill="#e0e0e0", justify="center", text=rtext, font=("Arial", self.textsize), tags=("temptext", "all"))
#        self.score.lower("temptext")
#        t = threading.Timer(0.0625, self.getbigger)
#        t.start()

    def voicechange(self):
        pass
#        if self.hinst >= len(self.regionlist):
#            self.hregion = len(self.regionlist)
#            region = self.regionlist[self.oldhregion]
#            self.regionlist.append(region)
#        elif self.hregion != self.oldhregion:
#            region = self.regionlist[self.hregion]
#            oldregion = self.regionlist[self.oldhregion]
#            hnum = self.hnum * region[1] * oldregion[0]
#            hden = self.hden * region[0] * oldregion[1]
#            hratio = self.ratioreduce(hnum, hden, self.primelimit)
#            self.hnum = hratio[0]
#            self.hden = hratio[1]
#            self.curnum = region[0]
#            self.curden = region[1]
#            self.score.itemconfigure(self.hnumdisp, text=str(self.hnum))
#            self.score.itemconfigure(self.hdendisp, text=str(self.hden))
#            self.score.itemconfigure(self.hrnumdisp, text=str(region[0]))
#            self.score.itemconfigure(self.hrdendisp, text=str(region[1]))
#            self.drawoctaves(region[3])
#            self.octave11 = region[3]
#            self.log1 = math.log(float(self.hnum)/float(self.hden))
#            self.logged = self.log1/self.log2
#            self.yadj = self.octave11 - (self.logged * self.octaveres)
#        else:
#            region = self.regionlist[self.hregion]
#        self.oldhregion = self.hregion
##        self.write('%s%d =' % ("Region: ",self.hregion))
##        self.write('%d/%d' % (self.regionlist[self.hregion][0],self.regionlist[self.hregion][1]))
#        self.textsize = 24
#        rtext = 'Region %d\n= %d/%d' % (self.hregion, region[0], region[1])
#        self.write(rtext)
#        scrx = self.score.winfo_width()/2
#        scry = self.score.winfo_height()/2
#        x = self.score.canvasx(scrx)
#        y = self.score.canvasy(scry)
#        self.score.create_text(x, y, fill="#e0e0e0", justify="center", text=rtext, font=("Arial", self.textsize), tags=("temptext", "all"))
#        self.score.lower("temptext")
#        t = threading.Timer(0.0625, self.getbigger)
#        t.start()

    def modeannounce(self):
        mode = self.mode.get()
        if mode == 0:
            self.score.config(cursor="ur_angle")
#            self.score.unbind("<Motion>")
#            self.score.bind("<Motion>", self.hover.hovermotion)
#            self.score.itemconfigure("note", activewidth=0, activeoutline=None)
            if self.score.itemcget(self.hover.widget, 'state') != 'normal':
                self.score.itemconfigure(self.hover.widget, state='normal')
                self.score.itemconfigure(self.hover.hcross1, state='normal')
                self.score.itemconfigure(self.hover.hcross2, state='normal')
                self.score.itemconfigure(self.hover.hnumdisp, state='normal')
                self.score.itemconfigure(self.hover.hdendisp, state='normal')
                self.score.itemconfigure(self.hover.hrnumdisp, state='normal')
                self.score.itemconfigure(self.hover.hrdendisp, state='normal')
                self.score.itemconfigure(self.hover.hregiondisp, state='normal')
                self.score.itemconfigure(self.hover.hvoicedisp, state='normal')
            self.editselectnone()
            self.tiedraw(self.hover.hinst, self.hover.hvoice)
            self.write("Now in Add Mode")
        elif mode == 1:
            self.score.config(cursor="pencil")
            if self.score.itemcget(self.hover.widget, 'state') != 'hidden':
                self.score.itemconfigure(self.hover.widget, state='hidden')
                self.score.itemconfigure(self.hover.hcross1, state='hidden')
                self.score.itemconfigure(self.hover.hcross2, state='hidden')
                self.score.itemconfigure(self.hover.hnumdisp, state='hidden')
                self.score.itemconfigure(self.hover.hdendisp, state='hidden')
                self.score.itemconfigure(self.hover.hrnumdisp, state='hidden')
                self.score.itemconfigure(self.hover.hrdendisp, state='hidden')
                self.score.itemconfigure(self.hover.hregiondisp, state='hidden')
                self.score.itemconfigure(self.hover.hvoicedisp, state='hidden')
            self.tiedraw(self.hover.hinst, self.hover.hvoice)
            self.write("Now in Edit Mode")
        elif mode == 2:
            self.score.config(cursor="X_cursor")
#            self.score.unbind("<Motion>")
#            self.score.bind("<Motion>", self.deleteseek)
#            self.score.itemconfigure("note", activeoutline="#664444", activewidth=2)
            if self.score.itemcget(self.hover.widget, 'state') != 'hidden':
                self.score.itemconfigure(self.hover.widget, state='hidden')
                self.score.itemconfigure(self.hover.hcross1, state='hidden')
                self.score.itemconfigure(self.hover.hcross2, state='hidden')
                self.score.itemconfigure(self.hover.hnumdisp, state='hidden')
                self.score.itemconfigure(self.hover.hdendisp, state='hidden')
                self.score.itemconfigure(self.hover.hrnumdisp, state='hidden')
                self.score.itemconfigure(self.hover.hrdendisp, state='hidden')
                self.score.itemconfigure(self.hover.hregiondisp, state='hidden')
                self.score.itemconfigure(self.hover.hvoicedisp, state='hidden')
            self.editselectnone()
            self.tiedraw(self.hover.hinst, self.hover.hvoice)
            self.write("Now in Delete Mode")
        elif mode == 3:
            self.score.config(cursor="crosshair")
            if self.score.itemcget(self.hover.widget, 'state') != 'hidden':
                self.score.itemconfigure(self.hover.widget, state='hidden')
                self.score.itemconfigure(self.hover.hcross1, state='hidden')
                self.score.itemconfigure(self.hover.hcross2, state='hidden')
                self.score.itemconfigure(self.hover.hnumdisp, state='hidden')
                self.score.itemconfigure(self.hover.hdendisp, state='hidden')
                self.score.itemconfigure(self.hover.hrnumdisp, state='hidden')
                self.score.itemconfigure(self.hover.hrdendisp, state='hidden')
                self.score.itemconfigure(self.hover.hregiondisp, state='hidden')
                self.score.itemconfigure(self.hover.hvoicedisp, state='hidden')
            self.editselectnone()
            self.tiedraw(self.hover.hinst, self.hover.hvoice)
            self.write("Now in Scrub Mode")

    def popup(self,event):
        self.menupopupinst.delete(0, "end")
        for inst in range(1, len(self.instlist)):
            self.menupopupinst.add_command(label='%d' % inst, command=lambda arg1=inst: self.editinstassign(arg1))
        self.menupopupregion.delete(0, "end")
#        self.menupopupregion.add_command(label="New", command=self.regioneditlistnew)
#        self.menupopupregion.add_command(label="0", command=lambda: self.editregionassign(0))
        for region in range(0, len(self.regionlist)):
            self.menupopupregion.add_command(label='%d' % region, command=lambda arg1=region: self.editregionassign(arg1))
        self.menupopup.post(event.x_root,event.y_root)

    def editregionassign(self, region):
        color = self.regionlist[region].color
        try:
            toedit = self.score.find_withtag("edit")[0]
        except:
            toedit = None
        for notewidget in self.notewidgetlist:
            note = notewidget.note
            if notewidget.notewidget == toedit:
                if note.sel == 0:
                    oldrnum = self.regionlist[note.region].num
                    oldrden = self.regionlist[note.region].den
                    note.region = region
                    rnum = self.regionlist[region].num
                    rden = self.regionlist[region].den
                    ratio = self.ratioreduce(note.num * oldrnum * rden, note.den * oldrden * rnum, self.primelimit)
                    note.num = ratio[0]
                    note.den = ratio[1]
                    notewidget.updateregion()
                    break
            if note.sel == 1:
                oldrnum = self.regionlist[note.region].num
                oldrden = self.regionlist[note.region].den
                note.region = region
                rnum = self.regionlist[region].num
                rden = self.regionlist[region].den
                ratio = self.ratioreduce(note.num * oldrnum * rden, note.den * oldrden * rnum, self.primelimit)
                note.num = ratio[0]
                note.den = ratio[1]
                notewidget.updateregion()

    def editvoiceassign(self, voice):
#        print voice
        try:
            toedit = self.score.find_withtag("edit")[0]
        except:
            toedit = None
        for notewidget in self.notewidgetlist:
            note = notewidget.note
            if notewidget.notewidget == toedit:
                if note.sel == 0:
                    inst = note.inst
                    oldvoice = note.voice
                    note.voice = voice
                    self.tiedraw(inst, voice)
                    self.tiedraw(inst, oldvoice)
                    notewidget.updatevoice()
                    break
            if note.sel == 1:
                inst = note.inst
                oldvoice = note.voice
                note.voice = voice
                self.tiedraw(inst, voice)
                self.tiedraw(inst, oldvoice)
                notewidget.updatevoice()

    def editinstassign(self, inst):
#        print inst
        try:
            toedit = self.score.find_withtag("edit")[0]
        except:
            toedit = None
        for notewidget in self.notewidgetlist:
            note = notewidget.note
            if notewidget.notewidget == toedit:
                if note.sel == 0:
                    voice = note.voice
                    oldinst = note.inst
                    note.inst = inst
                    self.tiedraw(oldinst, voice)
                    self.tiedraw(inst, voice)
                    notewidget.updateinst()
                    break
            if note.sel == 1:
                voice = note.voice
                oldinst = note.inst
                note.inst = inst
                self.tiedraw(oldinst, voice)
                self.tiedraw(inst, voice)
                notewidget.updateinst()

    def editselect(self):
        self.write("Edit->Select")

    def editselectnone(self, *args):
        for notewidget in self.notewidgetlist:
            notewidget.note.sel = 0
            outline = self.score.itemcget(notewidget.notewidget, "fill")
            self.score.itemconfig(notewidget.notewidget, outline=outline, width=1)

    def editcut(self, *args):
        self.write("Edit->Cut")

    def editcopy(self, *args):
        self.write("Edit->Copy")

    def editpaste(self, *args):
        self.write("Edit->Paste")

    def filenew(self, *args):
        for i in range(len(self.notewidgetlist)):
            self.notewidgetlist[0].undraw()
            del self.notewidgetlist[0]
        for i in range(len(self.notelist)):
            del self.notelist[0]
        self.notelist = []
        self.notewidgetlist = []
        initregion = rdialog.region(self, 1, 1, '#999999', 240)
        for i in range(len(self.regionlist)):
            del self.regionlist[0]
        self.regionlist = [initregion]
        for i in range(len(self.instlist)):
            del self.instlist[0]
        self.instlist = [0]
        for i in range(len(self.tempolist)):
            del self.tempolist[0]
        self.tempolist = []
        for i in range(len(self.meterlist)):
            del self.meterlist[0]
        self.meterlist = []
        self.redrawlines()
        self.filetosave = None
        self.csdimport = None
        self.csdimported = ''
        self.outautoload = False
        self.write("File->New")

    def fileopen(self, *args):
        file = tkfd.askopenfilename(title="Open", filetypes=[("Rationale 0.1", ".rat")])
        if file:
            self.fileopenwork(file)
#        else:
        self.ctlkey = 0

    def fileopenwork(self, file):
        self.filenew()
        self.filetosave = file
        self.write('File->Open: %s' % str(file))
        input = open(file, 'rb')
        regionlistin = pickle.load(input)
        instlistin = pickle.load(input)
        notelistin = pickle.load(input)
        meterlistin = pickle.load(input)
        tempolistin = pickle.load(input)
        self.csdimport = pickle.load(input)
        self.csdimported = pickle.load(input)
        self.outautoload = pickle.load(input)
#        self.score.delete("all")
        for scoreitem in self.score.find_all():
            tags = self.score.gettags(scoreitem)
            if "octaveline" not in tags and "perm11" not in tags and "timecursor" not in tags and "hover" not in tags:
                self.score.delete(scoreitem)
#        self.drawoctaves(self.octave11)
        self.regionlist = []
        self.notelist = []
        self.meterlist = []
        self.tempolist = []
#            for region in regionlistin:
#                newregion = rdialog.region(self, region[0], region[1], region[2], region[3])
#                self.regionlist.append(newregion)
        self.regionlist = regionlistin
#            for reg in self.regionlist:
#                reg.color = '#' + str(reg.color)
        self.instlist = instlistin
        for test in notelistin:
            inst = test[0]
            voice = test[1]
            time = test[2]
            dur = test[3]
            db = test[4]
            num = test[5]
            den = test[6]
            region = test[7]
            sel = test[8]
            entrycolor = '#888888'
            if inst < len(self.instlist):
                entrycolor = str(self.instlist[inst].color)
            rnum = self.regionlist[region].num
            rden = self.regionlist[region].den
            rcolor = str(self.regionlist[region].color)
            posx = time * self.xperquarter
            yadj = self.octave11 - ((math.log(float(num)/float(den))/self.log2) * self.octaveres)
            x2 = posx + db/12
            y2 = yadj
            x0 = posx
            y0 = yadj - db/6
            x1 = posx
            y1 = yadj + db/6
            crossx3 = posx + dur * self.xperquarter
            ry0 = yadj - 15
            ry1 = yadj + 15

#                newnote = self.score.create_polygon(x2,y2,x0,y0,x1,y1,x2,y2,crossx3,y2,fill=entrycolor,outline=entrycolor, tags=("note", "all"))
#                newnotenum = self.score.create_text(x0,y2,anchor="se",fill=entrycolor,text=str(num), tags="all")
#                newnoteden = self.score.create_text(x0,y2,anchor="ne",fill=entrycolor,text=str(den), tags="all")
#                regionnum = self.score.create_text(x2,ry0,anchor="se",fill=rcolor,text=str(rnum),font=("Times",10), tags="all")
#                regionden = self.score.create_text(x2,ry1,anchor="ne",fill=rcolor,text=str(rden),font=("Times",10), tags="all")
#                regiondisp = self.score.create_text(x2, y2, anchor="sw", fill=rcolor, text='r' + str(region), font=("Times",10), tags="all")
#                voicedisp = self.score.create_text(x2, y2, anchor="nw", fill=entrycolor, text=str(voice), tags="all")
            noteinstance = note(self, inst, voice, time, dur, db, num, den, region, sel)
            self.notelist.append(noteinstance)
            notewidgetinstance = notewidgetclass(self, noteinstance)
            self.notewidgetlist.append(notewidgetinstance)
            self.tiedraw(inst, voice)
        for i in meterlistin:
            test = mdialog.meter(self, i[0], i[1], i[2])
            self.meterlist.append(test)
        self.redrawlines()
        for i in tempolistin:
            test = tdialog.tempo(self, i[0], i[1], i[2], i[3])
            self.tempolist.append(test)


    def filesave(self, *args):
        if not self.filetosave or self.filetosave == None:
            self.filetosave = tkfd.asksaveasfilename(master=self.myparent, title="Save As", defaultextension=".rat")
        if self.filetosave:
            self.ctlkey = 0
            output = open(self.filetosave, 'wb')
            regionlist = self.regionlist
            instlist = self.instlist
            notelist = [(note.inst, note.voice, note.time, note.dur, note.db, note.num, note.den, note.region, note.sel) for note in self.notelist]
            meterlist = [(meter.bar, meter.top, meter.bottom) for meter in self.meterlist]
            tempolist = [(tempo.bar, tempo.beat, tempo.bpm, tempo.unit) for tempo in self.tempolist]
            pickle.dump(regionlist, output)
            pickle.dump(instlist, output)
            pickle.dump(notelist, output)
            pickle.dump(meterlist, output)
            pickle.dump(tempolist, output)
            pickle.dump(self.csdimport, output)
            pickle.dump(self.csdimported, output)
            pickle.dump(self.outautoload, output)

            self.write('File->Save: %s' % self.filetosave)
            output.close()

    def filesaveas(self, *args):
        self.filetosave = tkfd.asksaveasfilename(master=self.myparent, title="Save As", filetypes=[("Rationale 0.1", ".rat")])
        if self.filetosave:
            output = open(self.filetosave, 'wb')
            regionlist = self.regionlist
            instlist = self.instlist
            notelist = [(note.inst, note.voice, note.time, note.dur, note.db, note.num, note.den, note.region, note.sel) for note in self.notelist]
            meterlist = [(meter.bar, meter.top, meter.bottom) for meter in self.meterlist]
            tempolist = [(tempo.bar, tempo.beat, tempo.bpm, tempo.unit) for tempo in self.tempolist]
            pickle.dump(regionlist, output)
            pickle.dump(instlist, output)
            pickle.dump(notelist, output)
            pickle.dump(meterlist, output)
            pickle.dump(tempolist, output)
            pickle.dump(self.csdimport, output)
            pickle.dump(self.csdimported, output)
            pickle.dump(self.outautoload, output)
            self.write('File->Save As: %s' % self.filetosave)
            output.close()

    def fileimport(self, *args):
        self.write("File->Import .ji")
        file = tkfd.askopenfilename(title="Import .ji", filetypes=[("JIsequencer", ".ji")])
        if file:
            input = open(file, 'rb')
            notelistin = []
            flag1 = 0
            for line in input:
                if flag1 == 1:
                    split = line.split()
                    if split[-1][-1] == ';':
                        split[-1] = split[-1][:-1]
                    bothlines = fstline + split
                    notelistin.append(bothlines)
                    flag1 = 0
                if line.split()[0] == "notes":
                    split = line.split()
                    if split[-1][-1] == ';':
                        split[-1] = split[-1][:-1]
                    fstline = split
                    flag1 = 1
#            meterlistin = pickle.load(input)
#            tempolistin = pickle.load(input)
            self.filenew()
#            for scoreitem in self.score.find_all():
#                tags = self.score.gettags(scoreitem)
#                if "octaveline" not in tags and "perm11" not in tags and "timecursor" not in tags and "hover" not in tags:
#                    self.score.delete(scoreitem)
#            initregion = rdialog.region(self, 1, 1, '#999999', 240)
#            for i in range(len(self.regionlist)):
#                del self.regionlist[i]
#            self.regionlist = [initregion]
##            self.regionlist = [[1,1,999999,240]]
#            self.notelist = []
#            self.meterlist = []
#            self.tempolist = []
            instset = [0]
            for test in notelistin:
                jiinst = test[8]
                if jiinst in instset:
                    inst = instset.index(jiinst)
                else:
                    instset.append(jiinst)
                    inst = instset.index(jiinst)
                voice = 0
                time = (float(test[1]) - 30)/30
                dur = float(test[5])/30
                widgetdur = dur * self.xperquarter
                db = int(test[-2]) * 6
                num = int(test[3])
                den = int(test[4])
                region = 0
                sel = 0
                entrycolor = '#888888'
                if inst < len(self.instlist):
                    entrycolor = str(self.instlist[inst].color)
                rnum = self.regionlist[region].num
                rden = self.regionlist[region].den
                rcolor = str(self.regionlist[region].color)
                posx = time * self.xperquarter
                yadj = self.octave11 - ((math.log(float(num)/float(den))/self.log2) * self.octaveres)
                x2 = posx + db/12
                y2 = yadj
                x0 = posx
                y0 = yadj - db/6
                x1 = posx
                y1 = yadj + db/6
                crossx3 = posx + widgetdur
                ry0 = yadj - 15
                ry1 = yadj + 15

#                newnote = self.score.create_polygon(x2,y2,x0,y0,x1,y1,x2,y2,crossx3,y2,fill=entrycolor,outline=entrycolor, tags=("note", "all"))
#                newnotenum = self.score.create_text(x0,y2,anchor="se",fill=entrycolor,text=str(num), tags="all")
#                newnoteden = self.score.create_text(x0,y2,anchor="ne",fill=entrycolor,text=str(den), tags="all")
#                regionnum = self.score.create_text(x2,ry0,anchor="se",fill=rcolor,text=str(rnum),font=("Times",10), tags="all")
#                regionden = self.score.create_text(x2,ry1,anchor="ne",fill=rcolor,text=str(rden),font=("Times",10), tags="all")
#                regiondisp = self.score.create_text(x2, y2, anchor="sw", fill=rcolor, text='r' + str(region), font=("Times",10), tags="all")
#                voicedisp = self.score.create_text(x2, y2, anchor="nw", fill=entrycolor, text=str(voice), tags="all")
                noteinstance = note(self, inst, voice, time, dur, db, num, den, region, sel)
                self.notelist.append(noteinstance)
                notewidgetinstance = notewidgetclass(self, noteinstance)
                self.notewidgetlist.append(notewidgetinstance)

                self.tiedraw(inst, voice)
#            for i in meterlistin:
#                test = meter(self, i[0], i[1], i[2])
#                self.meterlist.append(test)
            self.redrawlines()
#            for i in tempolistin:
#                test = tempo(self, i[0], i[1], i[2], i[3])
#                self.tempolist.append(test)

    def fileexport(self, *args):
        self.preparecsd(self, self.instlist, 0)
        filetoexport = tkfd.asksaveasfilename(master=self.myparent, title="Export Csound", filetypes=[("Csound Unified Format", ".csd")])
        if filetoexport:
            csdexport = open(filetoexport, 'w')
            csdexport.write(self.csdcsd)
            csdexport.close()
            self.write('File->Export: %s' % filetoexport)


    def fileexit(self, *args):
        self.write("File->Exit")
        self.myparent.destroy()

    def durupdate(self,dur):
        if self.mode.get() == 0:
            self.hover.entrydur = dur
            self.hover.hdur = self.xperquarter * self.hover.entrydur
            self.hover.hcrossx3 = self.hover.posx + self.hover.hdur
            self.score.coords(self.hover.hcross2,self.hover.hovx0,self.hover.hcrossy2,self.hover.hcrossx3,self.hover.hcrossy3)
        elif self.mode.get() == 1:
            self.selectdur == dur * self.xperquarter

    def durmod8up(self, event):
        tempdur = float(int(self.hover.entrydur * 8) + 1)/8
        if self.mode.get() == 0:
            self.durupdate(tempdur)
        elif self.mode.get() == 1:
            pass
        
    def durmod8down(self, event):
        tempdur = float(int(self.hover.entrydur * 8) - 1)/8
        if self.mode.get() == 0:
            self.durupdate(tempdur)
        elif self.mode.get() == 1:
            pass

    def durmod6up(self, event):
        tempdur = float(int(self.hover.entrydur * 6) + 1)/6
        if self.mode.get() == 0:
            self.durupdate(tempdur)
        elif self.mode.get() == 1:
            pass

    def durmod6down(self, event):
        tempdur = float(int(self.hover.entrydur * 6) - 1)/6
        if self.mode.get() == 0:
            self.durupdate(tempdur)
        elif self.mode.get() == 1:
            pass

    def tiedraw(self, inst, voice):
        if voice != 0:
            loclist = []
            for notewidget in self.notewidgetlist:
                note = notewidget.note
                if note.inst == inst and note.voice == voice:
                    notex = notewidget.purex
                    notey = notewidget.purey
                    loclist.append([notex,notey])
            if self.hover.hinst == inst and self.hover.hvoice == voice and self.score.itemcget(self.hover.widget, 'state') != 'hidden':
                loclist.append([self.hover.hovx0,self.hover.hovy2])
            if len(loclist) > 1:
                loclist.sort()
                if '%s-%.30d-%.30d' % ('key',inst,voice) in self.ties:
                    tiehandle = self.ties['%s-%.30d-%.30d' % ('key',inst,voice)]
                    self.score.delete(tiehandle)
#                    self.score.coords(tiehandle,loclist)
#                else:
                loctie = self.score.create_line(loclist,width=5,fill="#ffcccc",tags="all")
                self.score.lower(loctie)
                self.ties['%s-%.30d-%.30d' % ('key',inst,voice)] = loctie
            else:
                if '%s-%.30d-%.30d' % ('key',inst,voice) in self.ties:
                    tiehandle = self.ties['%s-%.30d-%.30d' % ('key',inst,voice)]
                    self.score.delete(tiehandle)
                    del self.ties['%s-%.30d-%.30d' % ('key',inst,voice)]

    def hupdate(self):
        pass

    def scorexscroll(self, *args):
        self.score.xview(*args)
        self.meters.xview(*args)
        self.tempos.xview(*args)
        self.bars.xview(*args)
#        self.scrollposx = args[1]
####    self.scrollposx is now the fraction of the scroll region shown on the left.  If I can compare the distance from here to the cursor with the width of the viewable part of the canvas, I can know when to scroll...
#        self.scrolltotal = self.maxx-self.minx
#        self.viewwidthtotal = self.scrolltotal * float(self.scrollposx)
#        self.viewwidth = self.scorewin.winfo_width()

    def scoreyscroll(self, *args):
        self.score.yview(*args)
        self.octaves.yview(*args)

    def inserttempo(self, event):
        pass

    def grab(self, event):
        self.xdrag = event.x
        self.ydrag = event.y
        xscroll = self.xscroll.get()
        yscroll = self.yscroll.get()
        self.xscrwas = xscroll[0]
        self.yscrwas = yscroll[0]
        self.xrange = self.maxx - self.minx
        self.yrange = self.maxy - self.miny

    def zoom(self, which):
        if which == "in":
#            self.score.scale("all", 200, 200, 1.1, 1.1)
            pass
        elif which == "out":
#            self.score.scale("all", 200, 200, .9, .9)
            pass

    def deleteseek(self, event):
        self.score.itemconfig("note", stipple="")
        self.score.dtag("note", "delete")
        self.score.dtag("note", "edit")
        widget = event.widget
        realx = widget.canvasx(event.x)
        realy = widget.canvasy(event.y)
        notes = self.score.find_overlapping(realx-21, realy-21, realx+21, realy+21)
        note = 0
        absall = 20
        for match in notes:
            if "note" in self.score.gettags(match):
                coords = self.score.coords(match)
                xy = (coords[2], coords[1])
                abs = math.sqrt((xy[0]-realx)**2 + (xy[1]-realy)**2)
                if abs < absall:
                    absall = abs
                    note = match
        if note != 0:
            self.score.itemconfig(note, stipple="gray50")
            self.score.addtag_withtag("delete", note)
            self.score.addtag_withtag("edit", note)

    def meteradd(self, event):
        self.meteraddwindow = tk.Toplevel(self.myparent)
        self.meteraddwindow.title("Add Meter Change")
        self.meteraddwindow.rowconfigure(0, weight=0)
        self.meteraddwindow.rowconfigure(1, weight=0)
        self.meteraddwindow.rowconfigure(2, weight=0)
        self.meteraddwindow.rowconfigure(3, weight=1)
        self.meteraddwindow.columnconfigure(1, weight=0)
        self.meteraddwindow.columnconfigure(2, weight=0)
        self.meteraddwindow.columnconfigure(3, weight=0)
        self.meteraddwindow.columnconfigure(4, weight=1)
        self.meteraddbar = tk.IntVar()
        self.meteraddtop = tk.IntVar()
        self.meteraddbottom = tk.IntVar()
        barwidget = tk.Entry(self.meteraddwindow, textvariable=bar, width=4)
        barwidget.grid(row=0, column=0)
        topwidget = tk.Entry(self.meteraddwindow, textvariable=top, width=4)
        topwidget.grid(row=0, column=1)
        bottomwidget = tk.Entry(self.meteraddwindow, textvariable=bottom, width=4)
        bottomwidget.grid(row=1, column=1)
        ok = tk.Button(self.meteraddwindow, text="OK")
        ok.grid(row=2, column=0)
        cancel = tk.Button(self.meteraddwindow, text="Cancel", command=self.cancel)
        cancel.grid(row=2, column=1)

    def meteredit(self, event):
        tempwindow = tk.Toplevel(self.myparent)
        tempwindow.title("Edit Meter Changes")
        rowcount = 0
        for meter in self.meterlist:
            tempwindow.rowconfigure(rowcount, weight=0)
            tk.Entry(tempwindow, text=str(meter.bar)).grid(row=rowcount, column=0)            

    def tempoinit(self, event):
        print 'tempo init: %d %d' % (event.x, event.y)

    def tempoadjust(self, event):
        print 'tempo adjust'

    def tempoadd(self, event):
        print 'tempo add: %d %d' % (event.x, event.y)

    def tempoedit(self, event):
        print 'tempolist edit'

    def editmodecopy(self, *args):
        self.clipboard = []
        for note in self.notelist:
            if note.sel == 1:
                self.clipboard.append(note)
        print 'copy'

    def editmodecut(self, event):
        print 'cut'

    def editmodepaste(self, event):
        pastedialog = pastedialog()
        print 'paste'

    def editmodedur(self, dur):
        for notewidget in self.notewidgetlist:
            note = notewidget.note
            if note.sel == 1:
                note.dur = dur
                notewidget.updatedur()
        print 'durations edited'

    def editmodetranspose(self, num, den):
        print 'notes transposed'

    def editmoderegion(self, region):
        print 'notes assigned to region %d' % region

    def editmodeinst(self, inst):
        print 'assigned to inst %d' % inst

    def editmodevoice(self, voice):
        for notewidget in self.notewidgetlist:
            note = notewidget.note
            if note.sel == 1:
                note.voice = voice
                notewidget.updatevoice()
        print 'assigned to voice %d' % voice

    def editmodeslide(self, bars, beats, ticks):
        print 'slid'

    def regioneditlistnew(self, *args):
        print "regioneditlistnew"
        self.regioneditlist = regioneditlist(self)

    def noteeditlistnew(self, *args):
        self.noteeditlist = noteeditlist(self)

    def scoredrag(self, event):
        winfocus = (str(self.scorewin.focus_get()))
        if winfocus != None:
            xdrag = self.xdrag - event.x
            ydrag = self.ydrag - event.y
            xfrac = float(xdrag) / self.xrange + self.xscrwas
            yfrac = float(ydrag) / self.yrange + self.yscrwas
            self.scorexscroll('moveto', xfrac)
            self.scoreyscroll('moveto', yfrac)

class notewidgetclass:
    def __init__(self, parent, note):
        self.myparent = parent
        self.note = note
        self.purex = self.note.time * self.myparent.xperquarter
        self.purey = self.myparent.octave11 - ((math.log(float(self.note.num)/float(self.note.den))/self.myparent.log2) * self.myparent.octaveres)
#        print self.purey
        self.yoff = self.note.db/6.0
        self.xoff = self.yoff/2.0
        self.durx = self.purex + self.note.dur * self.myparent.xperquarter
        if self.note.inst >= len(self.myparent.instlist):
            self.color = '#888888'
        else:
            self.color = self.myparent.instlist[self.note.inst].color
        self.rcolor = self.myparent.regionlist[self.note.region].color
        self.rnum = self.myparent.regionlist[self.note.region].num
        self.rden = self.myparent.regionlist[self.note.region].den
        self.rstring = 'r' + str(self.note.region)
        if self.note.voice == 0:
            self.vstring = ''
        else:
            self.vstring = str(self.note.voice)

        self.notewidget = self.myparent.score.create_polygon(self.purex+self.xoff,self.purey,self.purex,self.purey-self.yoff,self.purex,self.purey+self.yoff,self.purex+self.xoff,self.purey,self.durx,self.purey,fill=self.color,outline=self.color, tags=("note", "all"))
        self.numwidget = self.myparent.score.create_text(self.purex,self.purey,anchor="se",fill=self.color,text=str(self.note.num), tags="all")
        self.denwidget = self.myparent.score.create_text(self.purex,self.purey,anchor="ne",fill=self.color,text=str(self.note.den), tags="all")
        self.rnumwidget = self.myparent.score.create_text(self.purex+6,self.purey-12,anchor="se",fill=self.rcolor,text=str(self.rnum),font=("Times",10), tags="all")
        self.rdenwidget = self.myparent.score.create_text(self.purex+6,self.purey+12,anchor="ne",fill=self.rcolor,text=str(self.rden),font=("Times",10), tags="all")
        self.regiondisp = self.myparent.score.create_text(self.purex+6, self.purey, anchor="sw", fill=self.rcolor, text=self.rstring, font=("Times",10), tags="all")
        self.voicedisp = self.myparent.score.create_text(self.purex+6, self.purey, anchor="nw", fill=self.color, text=self.vstring, font=("Times",10), tags="all")

    def updatetime(self):
        self.purex = self.note.time * self.myparent.xperquarter
        self.durx = self.purex + self.note.dur * self.myparent.xperquarter
        self.myparent.score.coords(self.notewidget, self.purex+self.xoff,self.purey,self.purex,self.purey-self.yoff,self.purex,self.purey+self.yoff,self.purex+self.xoff,self.purey,self.durx,self.purey)
        self.myparent.score.coords(self.numwidget, self.purex,self.purey)
        self.myparent.score.coords(self.denwidget, self.purex,self.purey)
        self.myparent.score.coords(self.rnumwidget, self.purex+6,self.purey-12)
        self.myparent.score.coords(self.rdenwidget, self.purex+6,self.purey+12)
        self.myparent.score.coords(self.regiondisp, self.purex+6,self.purey)
        self.myparent.score.coords(self.voicedisp, self.purex+6,self.purey)

    def updateheight(self):
        self.purey = self.myparent.regionlist[self.note.region].octave11 - ((math.log(float(self.note.num)/float(self.note.den))/self.myparent.log2) * self.myparent.octaveres)
        self.myparent.score.coords(self.notewidget, self.purex+self.xoff,self.purey,self.purex,self.purey-self.yoff,self.purex,self.purey+self.yoff,self.purex+self.xoff,self.purey,self.durx,self.purey)
        self.myparent.score.coords(self.numwidget, self.purex,self.purey)
        self.myparent.score.coords(self.denwidget, self.purex,self.purey)
        self.myparent.score.coords(self.rnumwidget, self.purex+6,self.purey-12)
        self.myparent.score.coords(self.rdenwidget, self.purex+6,self.purey+12)
        self.myparent.score.coords(self.regiondisp, self.purex+6,self.purey)
        self.myparent.score.coords(self.voicedisp, self.purex+6,self.purey)

    def updatedb(self):
        self.yoff = self.note.db/6.0
        self.xoff = self.yoff/2.0
        self.myparent.score.coords(self.notewidget, self.purex+self.xoff,self.purey,self.purex,self.purey-self.yoff,self.purex,self.purey+self.yoff,self.purex+self.xoff,self.purey,self.durx,self.purey)

    def updatedur(self):
        self.durx = self.purex + self.note.dur * self.myparent.xperquarter
        self.myparent.score.coords(self.notewidget, self.purex+self.xoff,self.purey,self.purex,self.purey-self.yoff,self.purex,self.purey+self.yoff,self.purex+self.xoff,self.purey,self.durx,self.purey)

    def updateinst(self):
        if self.note.inst < len(self.myparent.instlist):
            self.color = self.myparent.instlist[self.note.inst].color
        else:
            self.color = '#888888'
        self.myparent.score.itemconfigure(self.notewidget, fill=self.color, outline=self.color)
        self.myparent.score.itemconfigure(self.numwidget, fill=self.color)
        self.myparent.score.itemconfigure(self.denwidget, fill=self.color)
        self.myparent.score.itemconfigure(self.voicedisp, fill=self.color)

    def updateregion(self):
        self.rcolor = self.myparent.regionlist[self.note.region].color
        self.rnum = self.myparent.regionlist[self.note.region].num
        self.rden = self.myparent.regionlist[self.note.region].den
        self.rstring = 'r' + str(self.note.region)
        self.myparent.score.itemconfigure(self.numwidget, text=self.note.num)
        self.myparent.score.itemconfigure(self.denwidget, text=self.note.den)
        self.myparent.score.itemconfigure(self.rnumwidget, text=self.rnum, fill=self.rcolor)
        self.myparent.score.itemconfigure(self.rdenwidget, text=self.rden, fill=self.rcolor)
        self.myparent.score.itemconfigure(self.regiondisp, text=self.rstring, fill=self.rcolor)

    def updatevoice(self):
        if self.note.voice == 0:
            self.vstring = ''
        else:
            self.vstring = str(self.note.voice)
        self.myparent.score.itemconfigure(self.voicedisp, text=self.vstring)

    def undraw(self):
        self.myparent.score.delete(self.notewidget)
        self.myparent.score.delete(self.numwidget)
        self.myparent.score.delete(self.denwidget)
        self.myparent.score.delete(self.rnumwidget)
        self.myparent.score.delete(self.rdenwidget)
        self.myparent.score.delete(self.regiondisp)
        self.myparent.score.delete(self.voicedisp)

    def remove(self):
        pass

class note:
    def __init__(self, parent, inst, voice, time, dur, db, num, den, region, sel):
        self.myparent = parent
        self.inst = inst
        self.voice = voice
        self.time = time
        self.dur = dur
        self.db = db
        self.num = num
        self.den = den
        self.region = region
        self.sel = sel
#        self.arb = arb
#        self.widget = widget
        rnum = self.myparent.regionlist[self.region].num
        rden = self.myparent.regionlist[self.region].den
        self.freq = (float(rnum * self.num))/(float(rden * self.den)) * self.myparent.basefreq
        self.dict = {'inst': self.inst, 'voice': self.voice, 'time': self.time, 'dur': self.dur, 'db': self.db, 'num': self.num, 'den': self.den, 'region': self.region, 'freq': self.freq}

class noteeditlist:
    def __init__(self, parent):
        self.myparent = parent
        self.myparent.scsort()
        self.widget = tk.Toplevel(self.myparent.myparent)
        self.widget.title("Note List")
        self.widget.rowconfigure(0, weight=0)
        self.widget.rowconfigure(1, weight=0)
        self.widget.rowconfigure(2, weight=1)
        self.notesfr = tk.Frame(self.widget)
        self.notesfr.grid(row=0, column=0, sticky='ew')
        self.buttonfr = tk.Frame(self.widget)
        self.buttonfr.grid(row=1, column=0, sticky='ew')
        self.ok = tk.Button(self.buttonfr, text="OK")
        self.ok.grid(row=0, column=0)
        self.cancel = tk.Button(self.buttonfr, text="Cancel")
        self.cancel.grid(row=0, column=1)
        row = 0
        for note in self.myparent.notelist:
            note.fr = tk.Frame(self.notesfr)
            note.fr.grid(row=row, column=0)
            note.instwidget = tk.Entry(note.fr, width=5)
            note.instwidget.grid(row=0, column=0, rowspan=2)
            note.instwidget.insert("end", str(note.inst))
            note.voicewidget = tk.Entry(note.fr, width=3)
            note.voicewidget.grid(row=0, column=1, rowspan=2)
            note.voicewidget.insert("end", str(note.voice))
            note.timewidget = tk.Entry(note.fr, width=6)
            note.timewidget.grid(row=0, column=2, rowspan=2)
            note.timewidget.insert("end", str(note.time))
            note.durwidget = tk.Entry(note.fr, width=6)
            note.durwidget.grid(row=0, column=3, rowspan=2)
            note.durwidget.insert("end", str(note.dur))
            note.dbwidget = tk.Entry(note.fr, width=2)
            note.dbwidget.grid(row=0, column=4, rowspan=2)
            note.dbwidget.insert("end", str(note.db))
            note.numwidget = tk.Entry(note.fr, width=4)
            note.numwidget.grid(row=0, column=5)
            note.numwidget.insert("end", str(note.num))
            note.denwidget = tk.Entry(note.fr, width=4)
            note.denwidget.grid(row=1, column=5)
            note.denwidget.insert("end", str(note.den))
            note.regionwidget = tk.Entry(note.fr, width=2)
            note.regionwidget.grid(row=0, column=6, rowspan=2)
            note.regionwidget.insert("end", str(note.region))

            row += 1

class marker:
    def __init__(self, parent, name, bar, beat, widget):
        self.myparent = parent
        self.name = name
        self.bar = bar
        self.beat = beat
        self.widget = widget

#class tempo:
#    def __init__(self, parent, bar, beat, bpm, unit):
#        '''Left-click: add new or edit existing tempo;
#
#                tempo may be dragged left and right,
#                and dragging up and down raises or lowers tempo value
#           Right-click: edit list of tempos
#           '''
##        self.myparent = parent
#        self.bpm = bpm
#        self.unit = unit
#        self.bar = bar
#        self.beat = beat
##        self.bpm.set(bpm)
##        self.unit.set(unit)
##        self.bar.set(bar)
##        self.beat.set(beat)
##        self.tick = tick
##        self.widget = widget
#        self.findcsdbeat(parent)
#
#    def findcsdbeat(self, app):
#        sum = 0
#        if len(app.meterlist):
#            for i in range(len(app.meterlist)):
#                if self.bar > app.meterlist[i].bar.get():
#                    sum += (app.meterlist[i].bar.get() - app.meterlist[i-1].bar.get()) * 4 * float(app.meterlist[i-1].top.get())/float(app.meterlist[i-1].bottom.get())
#                else:
#                    sum += (self.bar - app.meterlist[i-1].bar.get()) * 4 * float(app.meterlist[i-1].top.get())/float(app.meterlist[i-1].bottom.get()) + (self.beat - 1) * 4 / app.meterlist[i-1].bottom.get()
#                    break
#        else:
#            sum = 4 * (self.bar - 1) + self.beat - 1
##            print self.bar.get(), self.beat.get()
#        self.scobeat = sum
#        print sum

class tempoadd:
    def __init__(self, event):
        pass

class tempoeditlist:
    def __init__(self, event):
        self.myparent = event.widget.myparent
        self.widget = tk.Toplevel(self.myparent.myparent)
        self.widget.title("Tempo Changes")
        self.entries = []
        labelframe = tk.Frame(self.widget, relief="raised")
        tk.Label(self.widget, text="Bar").grid(row=0, column=0, sticky='ew')
        tk.Label(self.widget, text="Beat").grid(row=0, column=1, sticky='ew')
        tk.Label(self.widget, text="BPM").grid(row=0, column=2, sticky='ew')
        tk.Label(self.widget, text="Unit").grid(row=0, column=3, sticky='ew')
        row = 0
        for tempo in self.myparent.tempolist:
            row = self.myparent.tempolist.index(tempo) + 1
            self.widget.rowconfigure(row, weight=0)
            tempoframe = tk.Frame(self.widget, relief="ridge", bd=2)
            tempoframe.grid(row=row, column=0, columnspan=5, sticky='ew')
            tempentry = tk.Entry(tempoframe, width=4, textvariable=tempo.bar)
            tempentry.grid(row=0, column=0, padx=10, pady=10)
            tempentry.bind("<Tab>", self.reorder)
            tempentry = tk.Entry(tempoframe, width=4, textvariable=tempo.beat)
            tempentry.grid(row=0, column=1, padx=10, pady=10)
            tempentry.bind("<Tab>", self.reorder)
            tk.Entry(tempoframe, width=4, textvariable=tempo.bpm).grid(row=0, column=2, padx=10, pady=10)
            tk.Entry(tempoframe, width=4, textvariable=tempo.unit).grid(row=0, column=3, padx=10, pady=10)
            kill = tk.Button(tempoframe, text="x", padx=0, pady=0,
                      command=lambda
                      index=tempo : 
                      self.remove(index)
                      )
            kill.grid(row=0, column=4, padx=10, pady=10)
        row += 1
        self.widget.rowconfigure(row, weight=0)
        self.newlineframe = tk.Frame(self.widget, relief="ridge", bd=2)
        self.newlineframe.grid(row=row, column=0, columnspan=5, sticky='ew')
        self.newbar = tk.IntVar()
        self.newbeat = tk.IntVar()
        self.newbpm = tk.DoubleVar()
        self.newunit = tk.IntVar()
        self.newlinebar = tk.Entry(self.newlineframe, width=4, textvariable=self.newbar)
        self.newlinebar.grid(row=0, column=0, padx=10, pady=10)
        self.newlinebar.bind("<Tab>", self.addline)
        self.newlinebeat = tk.Entry(self.newlineframe, width=4, textvariable=self.newbeat)
        self.newlinebeat.grid(row=0, column=1, padx=10, pady=10)
        self.newlinebeat.bind("<Tab>", self.addline)
        tk.Entry(self.newlineframe, width=4, textvariable=self.newbpm).grid(row=0, column=2, padx=10, pady=10)
        tk.Entry(self.newlineframe, width=4, textvariable=self.newunit).grid(row=0, column=3, padx=10, pady=10)
        row += 1
        self.widget.rowconfigure(row, weight=1)

    def addline(self, event):
        if self.newbar.get() != '' or self.newbeat.get() != '':
            newtempo = tdialog.tempo(self.myparent, 0, 0, 0, 0)
            newtempo.bar = self.newbar.get()
            newtempo.beat = self.newbeat.get()
            newtempo.bpm = self.newbpm.get()
            newtempo.unit = self.newunit.get()
            newtempoframe = self.newlineframe
            self.newlinebar.bind("<Tab>", self.reorder)
            self.newlinebeat.bind("<Tab>", self.reorder)
            self.myparent.tempolist.append(newtempo)
            self.reorder(event)
            kill = tk.Button(newtempoframe, text="x", padx=0, pady=0,
                      command=lambda
                      index=newtempo : 
                      self.remove(index)
                      )
            kill.grid(row=0, column=4, padx=10, pady=10)

            row = len(self.myparent.tempolist) + 1
            self.widget.rowconfigure(row, weight=0)
            self.newlineframe = tk.Frame(self.widget, relief="ridge", bd=2)
            self.newlineframe.grid(row=row, column=0, columnspan=5, sticky='ew')
            self.newbar = tk.IntVar()
            self.newbeat = tk.IntVar()
            self.newbpm = tk.DoubleVar()
            self.newunit = tk.IntVar()
            self.newlinebar = tk.Entry(self.newlineframe, width=4, textvariable=self.newbar)
            self.newlinebar.grid(row=0, column=0, padx=10, pady=10)
            self.newlinebar.bind("<Tab>", self.addline)
            self.newlinebeat = tk.Entry(self.newlineframe, width=4, textvariable=self.newbeat)
            self.newlinebeat.grid(row=0, column=1, padx=10, pady=10)
            self.newlinebeat.bind("<Tab>", self.addline)
            tk.Entry(self.newlineframe, width=4, textvariable=self.newbpm).grid(row=0, column=2, padx=10, pady=10)
            tk.Entry(self.newlineframe, width=4, textvariable=self.newunit).grid(row=0, column=3, padx=10, pady=10)
            row += 1
            self.widget.rowconfigure(row, weight=1)

    def remove(self, tempo):
        num = self.myparent.tempolist.index(tempo)
        tempo.frame.destroy()
        self.myparent.tempolist.pop(num)

    def reorder(self, event):
        self.myparent.tempolist.sort(key=self.sortextract)
        for tempo in self.myparent.tempolist:
            row = self.myparent.tempolist.index(tempo) + 1
            tempo.frame.grid(row=row, column=0, columnspan=5, sticky='ew')
            tempo.findcsdbeat(self.myparent)

    def sortextract(self, item):
        if item.bar != '':
            bar = int(item.bar)
        else: bar = '0'
        if item.beat != '':
            beat = float(item.beat)
        else: beat = '0'
        return (bar, beat)


### When you open a tempoeditlist, a window is created which reads the tempo
### list and creates a line for each existing tempo, with entries that can be
### edited.  A blank line of entries at the bottom waits for a tempo to be
### added.  When it is, the list is reordered.  If any are changed, they also
### update and reorder.  Each line also has an X button to remove tempos.

#class meter:
#    def __init__(self, parent, bar, top, bottom):
#        '''Left-click: add dialog;
#        Right-click: edit list of meters'''
#        self.myparent = parent
#        self.bar = tk.IntVar()
#        self.top = tk.IntVar()
#        self.bottom = tk.IntVar()
#        self.bar.set(bar)
#        self.top.set(top)
#        self.bottom.set(bottom)
#        self.bar.trace_variable("w", self.myparent.redrawlines)
#        self.top.trace_variable("w", self.myparent.redrawlines)
#        self.bottom.trace_variable("w", self.myparent.redrawlines)

class meteradddialog:
    def __init__(self, parent):
        pass

class metereditlist:
    def __init__(self, event):
        self.myparent = event.widget.myparent
        self.widget = tk.Toplevel(self.myparent.myparent)
        self.widget.title("Meter Changes")
        self.entries = []
        labelframe = tk.Frame(self.widget, relief="raised")
        tk.Label(self.widget, text="Bar").grid(row=0, column=0, sticky='ew')
        tk.Label(self.widget, text="Top").grid(row=0, column=1, sticky='ew')
        tk.Label(self.widget, text="Bottom").grid(row=0, column=2, sticky='ew')
        row = 0
        for meter in self.myparent.meterlist:
            row = self.myparent.meterlist.index(meter) + 1
            self.widget.rowconfigure(row, weight=0)
            meter.frame = tk.Frame(self.widget, relief="ridge", bd=2)
            meter.frame.grid(row=row, column=0, columnspan=4, sticky='ew')
            tempentry = tk.Entry(meter.frame, width=4, textvariable=meter.bar)
            tempentry.grid(row=0, column=0, padx=10, pady=10)
            tempentry.bind("<Tab>", self.reorder)
            tk.Entry(meter.frame, width=4, textvariable=meter.top).grid(row=0, column=1, padx=10, pady=10)
            tk.Entry(meter.frame, width=4, textvariable=meter.bottom).grid(row=0, column=2, padx=10, pady=10)
            kill = tk.Button(meter.frame, text="x", padx=0, pady=0,
                      command=lambda
                      index=meter : 
                      self.remove(index)
                      )
            kill.grid(row=0, column=4, padx=10, pady=10)
        row += 1
        self.widget.rowconfigure(row, weight=0)
        self.newlineframe = tk.Frame(self.widget, relief="ridge", bd=2)
        self.newlineframe.grid(row=row, column=0, columnspan=5, sticky='ew')
        self.newbar = tk.IntVar()
        self.newtop = tk.IntVar()
        self.newbottom = tk.IntVar()
        self.newlinebar = tk.Entry(self.newlineframe, width=4, textvariable=self.newbar)
        self.newlinebar.grid(row=0, column=0, padx=10, pady=10)
        self.newlinebar.bind("<Tab>", self.addline)
        tk.Entry(self.newlineframe, width=4, textvariable=self.newtop).grid(row=0, column=1, padx=10, pady=10)
        tk.Entry(self.newlineframe, width=4, textvariable=self.newbottom).grid(row=0, column=2, padx=10, pady=10)
        row += 1
        self.widget.rowconfigure(row, weight=1)

    def addline(self, event):
        if self.newbar.get() != '':
            newmeter = meter(self.myparent, 0, 0, 0)
            newmeter.bar = self.newbar
            newmeter.top = self.newtop
            newmeter.bottom = self.newbottom
            newmeter.frame = self.newlineframe
            self.newlinebar.bind("<Tab>", self.reorder)
            self.myparent.meterlist.append(newmeter)
            self.reorder(event)
            kill = tk.Button(newmeter.frame, text="x", padx=0, pady=0,
                      command=lambda
                      index=newmeter : 
                      self.remove(index)
                      )
            kill.grid(row=0, column=4, padx=10, pady=10)

            row = len(self.myparent.meterlist) + 1
            self.widget.rowconfigure(row, weight=0)
            self.newlineframe = tk.Frame(self.widget, relief="ridge", bd=2)
            self.newlineframe.grid(row=row, column=0, columnspan=5, sticky='ew')
            self.newbar = tk.IntVar()
            self.newtop = tk.IntVar()
            self.newbottom = tk.IntVar()
            self.newlinebar = tk.Entry(self.newlineframe, width=4, textvariable=self.newbar)
            self.newlinebar.grid(row=0, column=0, padx=10, pady=10)
            self.newlinebar.bind("<Tab>", self.addline)
            tk.Entry(self.newlineframe, width=4, textvariable=self.newtop).grid(row=0, column=1, padx=10, pady=10)
            tk.Entry(self.newlineframe, width=4, textvariable=self.newbottom).grid(row=0, column=2, padx=10, pady=10)
            row += 1
            self.widget.rowconfigure(row, weight=1)

    def remove(self, meter):
        num = self.myparent.meterlist.index(meter)
        meter.frame.destroy()
        self.myparent.meterlist.pop(num)
        self.myparent.redrawlines()

    def reorder(self, event):
        self.myparent.meterlist.sort(key=self.sortextract)
        for meter in self.myparent.meterlist:
            row = self.myparent.meterlist.index(meter) + 1
            meter.frame.grid(row=row, column=0, columnspan=4, sticky='ew')
        self.myparent.redrawlines()

    def sortextract(self, item):
        if item.bar.get() != '':
            bar = int(item.bar.get())
        else: bar = '0'
        return bar

class hover:
    def __init__(self, parent):
        '''This is the surrogate mouse cursor in ADD mode.  It always shows the current region's tonality, as well as the potential note's dynamic, duration, color, voice, and ratio to the current tonality.  If you click, the note that is added will be a copy of this hover.'''
        self.myparent = parent
        self.hnum = 1
        self.hden = 1
        self.hdb = 72
        self.hyoff = self.hdb / 6
        self.hxoff = self.hyoff/2
        self.hinst = 1
        self.hvoice = 0
        self.hinstch = 0
        self.hregion = 0
        self.oldhregion = 0
        self.hoffsetx = 10
        self.hoffsety = -30
        self.entrydur = 2
        self.entrycolor = "#888888"
        self.hdur = self.myparent.xperquarter * self.entrydur
        self.hnum = 1
        self.hden = 1
        self.posx = 120
        self.hovx0 = 120# + self.hoffsetx
        self.hovy0 = 225# + self.hoffsety
        self.hovx1 = 120# + self.hoffsetx
        self.hovy1 = 255# + self.hoffsety
        self.hovx2 = 120 + self.hxoff# + self.hoffsetx
        self.hovy2 = 240# + self.hoffsety
        self.hovx3 = 120# + self.hoffsetx
        self.hovy3 = 225# + self.hoffsety
        self.hcrossx0 = self.hovx0 + 1
        self.hcrossy0 = self.hovy2 - 16
        self.hcrossx1 = self.hovx0 + 1
        self.hcrossy1 = self.hovy2 + 16
        self.hcrossx2 = self.hovx0
        self.hcrossy2 = self.hovy2
        self.hcrossx3 = self.hovx0 + self.hdur
        self.hcrossy3 = self.hovy2
        self.hcrossx4 = self.hovx0
        self.hcrossy4 = self.hovy2
        self.widget = self.myparent.score.create_polygon(self.hovx0,self.hovy0,self.hovx1,self.hovy1,self.hovx2,self.hovy2,self.hovx3,self.hovy3,fill=self.entrycolor, tags=("hover", "all"))
        self.hcross1 = self.myparent.score.create_line(self.hcrossx0,self.hcrossy0,self.hcrossx0,self.hcrossy1,width=2, tags=("hover", "all"))
        self.hcross2 = self.myparent.score.create_line(self.hcrossx0,self.hcrossy2,self.hcrossx3,self.hcrossy3,width=2, tags=("hover", "all"))
        self.hnumdisp = self.myparent.score.create_text(120,240,anchor="se",fill=self.entrycolor,text=str(self.hnum), font=("Helvetica",12), tags=("hover", "all"))
        self.hdendisp = self.myparent.score.create_text(120,240,anchor="ne",fill=self.entrycolor,text=str(self.hden), font=("Helvetica",12), tags=("hover", "all"))
        region = self.hregion
        rnum = self.myparent.regionlist[region].num
        rden = self.myparent.regionlist[region].den
        rcolor = self.myparent.regionlist[region].color
        self.hrnumdisp = self.myparent.score.create_text(125,225,anchor="se",fill=rcolor,text=str(rnum),font=("Times",10), tags=("hover", "all"))
        self.hrdendisp = self.myparent.score.create_text(125,255,anchor="ne",fill=rcolor,text=str(rden),font=("Times",10), tags=("hover", "all"))
        self.hregiondisp = self.myparent.score.create_text(125, 240, anchor="sw", fill=rcolor, text='r' + str(region), font=("Times",10), tags=("hover", "all"))
        self.hvoicedisp = self.myparent.score.create_text(125, 240, anchor="nw", fill=self.entrycolor, text=str(self.hvoice), font=("Times",10), tags=("hover", "all"))

    ### Move the Hover ###
    def hovermotion(self,event):
        '''Called every time the mouse moves over the score in ADD mode.'''
        winfo = (str(self.myparent.scorewin.winfo_name()))
        winfocus = (str(self.myparent.scorewin.focus_get()))
        # conditional based on whether window is active #
        #if (winfocus.endswith(winfo)):
        if winfocus != None and self.myparent.mode.get() == 0:
            canv = event.widget
            x = canv.canvasx(event.x)
            y = canv.canvasy(event.y)
            self.posx = self.myparent.xpxquantize * math.floor((x + self.hoffsetx)/self.myparent.xpxquantize)
            self.hovx0 = self.posx
            self.hovx1 = self.posx
            self.hovx2 = self.posx + self.hxoff
            self.hovx3 = self.posx
            self.hovy0 = (y + self.hoffsety - self.hyoff)
            self.hovy1 = (y + self.hoffsety + self.hyoff)
            self.hovy2 = (y + self.hoffsety + 0)
            self.hovy3 = (y + self.hoffsety - self.hyoff)
            self.myparent.score.coords(self.widget,self.posx,self.hovy0,self.posx,self.hovy1,self.posx+self.hxoff,self.hovy2,self.posx,self.hovy3)
            self.hcrossx0 = self.posx
            self.hcrossy0 = self.hovy2 - 16
            self.hcrossx1 = self.posx
            self.hcrossy1 = self.hovy2 + 16
            self.hcrossx2 = self.posx
            self.hcrossy2 = self.hovy2
            self.hcrossx3 = self.posx + self.hdur
            self.hcrossy3 = self.hovy2
            self.hcrossx4 = self.posx
            self.hcrossy4 = self.hovy2
            self.myparent.score.coords(self.hcross1,self.hovx0,self.hcrossy0,self.hovx0,self.hcrossy1)
            self.myparent.score.coords(self.hcross2,self.hovx0,self.hcrossy2,self.hcrossx3,self.hcrossy3)
            self.yloc = self.myparent.octave11 - self.hovy2
            self.ynotestorage = int(self.yloc * 240 / self.myparent.octaveres) % self.myparent.octaveres
            prenum = notestorage.notebank[self.ynotestorage][1]
            preden = notestorage.notebank[self.ynotestorage][2]
            if self.yloc > self.myparent.octaveres:
                prenum *= 2**int((self.yloc)/self.myparent.octaveres)
            elif self.yloc < 0:
                preden *= 2**(0-((int(self.yloc)/self.myparent.octaveres)))
            hratio = self.myparent.ratioreduce(prenum,preden,self.myparent.primelimit)
            self.hnum = hratio[0]
            self.hden = hratio[1]
            self.log1 = math.log(float(self.hnum)/float(self.hden))
            self.logged = self.log1/self.myparent.log2
            self.myparent.yadj = self.myparent.octave11 - (self.logged * self.myparent.octaveres)
            self.myparent.score.coords(self.hnumdisp,self.hovx0-2,self.hovy2)
            self.myparent.score.coords(self.hdendisp,self.hovx0-2,self.hovy2)
            self.myparent.score.itemconfigure(self.hnumdisp,text=str(self.hnum))
            self.myparent.score.itemconfigure(self.hdendisp,text=str(self.hden))
            ry0 = (y + self.hoffsety - 15)
            ry1 = (y + self.hoffsety + 15)
            self.myparent.score.coords(self.hrnumdisp,self.hovx2,ry0)
            self.myparent.score.coords(self.hrdendisp,self.hovx2,ry1)
            self.myparent.score.coords(self.hregiondisp,self.hovx2, self.hovy2)
            self.myparent.score.coords(self.hvoicedisp, self.hovx2, self.hovy2)
            self.myparent.tiedraw(self.hinst, self.hvoice)

    def colorupdate(self, event):
        try:
            self.entrycolor = str(self.myparent.instlist[self.hinst].color)
            self.myparent.score.itemconfigure(self.widget, fill=self.entrycolor)
            self.myparent.score.itemconfigure(self.widget+3, fill=self.entrycolor)
            self.myparent.score.itemconfigure(self.widget+4, fill=self.entrycolor)
            self.myparent.score.itemconfigure(self.widget+8, fill=self.entrycolor)
        except:
            pass

    def increase(self, event):
        if self.hdb <= 84:
            self.hdb = self.hdb + 6
            self.hyoff = self.hdb / 6
            self.hxoff = self.hyoff/2
            self.hovx2 = self.posx + self.hxoff
            self.hovy0 -= 1
            self.hovy1 += 1
            self.hovy3 -= 1
            self.myparent.score.coords(self.widget,self.posx,self.hovy0,self.posx,self.hovy1,self.posx+self.hxoff,self.hovy2,self.posx,self.hovy3)
            self.hcrossy0 = self.hovy2 - 16
            self.hcrossy1 = self.hovy2 + 16
            self.myparent.score.coords(self.hcross1,self.hovx0,self.hcrossy0,self.hovx0,self.hcrossy1)

    def decrease(self, event):
        if self.hdb >= 6:
            self.hdb = self.hdb - 6
            self.hyoff = self.hdb / 6
            self.hxoff = self.hyoff/2
            self.hovx2 = self.posx + self.hxoff
            self.hovy0 += 1
            self.hovy1 -= 1
            self.hovy3 += 1
            self.myparent.score.coords(self.widget,self.posx,self.hovy0,self.posx,self.hovy1,self.posx+self.hxoff,self.hovy2,self.posx,self.hovy3)
            self.hcrossy0 = self.hovy2 - 16
            self.hcrossy1 = self.hovy2 + 16
            self.myparent.score.coords(self.hcross1,self.hovx0,self.hcrossy0,self.hovx0,self.hcrossy1)
        

class cursor:
    def __init__(self, parent):
        self.myparent = parent
        self.beat = 0
        self.center = 0
        self.widget = self.myparent.score.create_rectangle(-3,self.myparent.miny,3,self.myparent.maxy, fill="#99cccc", outline="#555555", stipple="gray25", tags=("timecursor", "all"))

    def scroll(self, time):
        pos = time * self.myparent.xperquarter + self.center
        self.myparent.score.coords("timecursor", pos-3, self.myparent.miny, pos+3, self.myparent.maxy)
#        x = self.myparent.score.coords(self.widget)[2] - 3
#        if x - self.myparent.viewwidthtotal > self.myparent.viewwidth:
#            toscroll = x/self.myparent.scrolltotal
#            print toscroll
#            self.myparent.scorexscroll('moveto', toscroll)

    def nextbar(self, event):
        for i in range(self.beat, len(self.myparent.barlist)):
            self.beat = int(self.beat + 1)
            if "barline" in self.myparent.score.gettags(self.myparent.barlist[self.beat]):
                oldcoords = self.myparent.score.coords(self.myparent.barlist[self.beat])
                self.center = oldcoords[0]
                self.myparent.score.coords(self.widget, self.center-3, self.myparent.miny, self.center+3, self.myparent.maxy)
                break

    def previousbar(self, event):
        for i in range(0, self.beat):
            self.beat = int(self.beat - 1)
            if "barline" in self.myparent.score.gettags(self.myparent.barlist[self.beat]):
                oldcoords = self.myparent.score.coords(self.myparent.barlist[self.beat])
                self.center = oldcoords[0]
                self.myparent.score.coords(self.widget, self.center-3, self.myparent.miny, self.center+3, self.myparent.maxy)
                break

    def nextbeat(self, event):
        for i in range(self.beat, len(self.myparent.barlist)):
            self.beat = int(self.beat + 1)
            oldcoords = self.myparent.score.coords(self.myparent.barlist[self.beat])
            self.center = oldcoords[0]
            self.myparent.score.coords(self.widget, self.center-3, self.myparent.miny, self.center+3, self.myparent.maxy)
            break

    def previousbeat(self, event):
        for i in range(0, self.beat):
            self.beat = int(self.beat - 1)
            oldcoords = self.myparent.score.coords(self.myparent.barlist[self.beat])
            self.center = oldcoords[0]
            self.myparent.score.coords(self.widget, self.center-3, self.myparent.miny, self.center+3, self.myparent.maxy)
            break

    def home(self, event):
        self.beat = 0
        self.center = 0
        self.myparent.score.coords(self.widget, -3, self.myparent.miny, 3, self.myparent.maxy)

class selectbox:
    def __init__(self, parent, event):
        self.myparent = parent
        x = self.myparent.score.canvasx(event.x)
        y = self.myparent.score.canvasy(event.y)
        self.corners = (x, y, x, y)
        self.widget = self.myparent.score.create_rectangle(self.corners, outline="#888888", tags="selectbox")
        selectall = self.myparent.score.find_overlapping(self.corners[0], self.corners[1], self.corners[2], self.corners[3])
        for notewidget in self.myparent.notewidgetlist:
            note = notewidget.note
            if notewidget.notewidget in selectall:
                note.sel = 1
                self.myparent.score.itemconfig(notewidget.notewidget, outline="#ff6670", width=3)
            elif self.myparent.shiftkey == 0:
                note.sel = 0
                outline = self.myparent.score.itemcget(notewidget.notewidget, "fill")
                self.myparent.score.itemconfig(notewidget.notewidget, width=1, outline=outline)

    def adjust(self, event):
        x = self.myparent.score.canvasx(event.x)
        y = self.myparent.score.canvasy(event.y)
        self.corners = (self.corners[0], self.corners[1], x, y)
        self.myparent.score.coords(self.widget, self.corners)
        selectall = self.myparent.score.find_overlapping(self.corners[0], self.corners[1], self.corners[2], self.corners[3])
        for notewidget in self.myparent.notewidgetlist:
            note = notewidget.note
            if notewidget.notewidget in selectall:
                note.sel = 1
                self.myparent.score.itemconfig(notewidget.notewidget, outline="#ff6670", width=3)
            elif self.myparent.shiftkey == 0:
                note.sel = 0
                outline = self.myparent.score.itemcget(notewidget.notewidget, "fill")
                self.myparent.score.itemconfig(notewidget.notewidget, width=1, outline=outline)

class pastedialog:
    def __init__(self, parent, event):
        self.myparent = parent
        self.widget = tk.Toplevel()

class regioneditlist:
    def __init__(self, parent):
        self.myparent = parent
        self.widget = tk.Toplevel()
        self.widget.title("Regions")
        row = 0
        for reg in self.myparent.regionlist:
            self.widget.rowconfigure(row, weight=0)
            frame = tk.Frame(self.widget)
            frame.grid(row=row, column=0)
            frame.columnconfigure(0, weight=0)
            frame.columnconfigure(1, weight=0)
            frame.columnconfigure(2, weight=0)
            frame.columnconfigure(3, weight=0)
            frame.columnconfigure(4, weight=1)
            tk.Label(frame, text='%s' % row).grid(row=0, column=0, rowspan=2)
#            num = tk.Entry(frame, width=4)
#            num.insert("end", str(self.myparent.regionlist[row][0]))
            num = tk.Control(frame, value=self.myparent.regionlist[row].num, min=1)
            num.grid(row=0, column=1)
#            den = tk.Entry(frame, width=4)
#            den.insert("end", str(self.myparent.regionlist[row][1]))
            den = tk.Control(frame, value=self.myparent.regionlist[row].den, min=1)
            den.grid(row=1, column=1)
            colorwidget = tk.Frame(frame, width=40, height=40, bg=str(self.myparent.regionlist[row].color))
#            entry3 = tk.Entry(frame, width=8)
#            entry3.insert("end", str(self.myparent.regionlist[row][2]))
#            entry3.grid(row=0, column=2, rowspan=2)
            colorwidget.grid(row=0, column=2, rowspan=2)
            row += 1
        self.widget.rowconfigure(row, weight=0)
        frame = tk.Frame(self.widget)
        frame.grid(row=row, column=0)
        frame.columnconfigure(0, weight=0)
        frame.columnconfigure(1, weight=0)
        frame.columnconfigure(2, weight=0)
        frame.columnconfigure(3, weight=1)
        tk.Label(frame, text='%s' % row).grid(row=0, column=0, rowspan=2)
        num = tk.Control(frame, min=1)
        num.grid(row=0, column=1)
        den = tk.Control(frame, min=1)
        den.grid(row=1, column=1)
        colorwidget = tk.Frame(frame, width=40, height=40, bg='#999999')
        colorwidget.grid(row=0, column=2, rowspan=2)
        row += 1
        frame = tk.Frame(self.widget)
        frame.grid(row=row, column=0)
        frame.columnconfigure(0, weight=1)
        frame.columnconfigure(1, weight=1)
        ok = tk.Button(frame, text="OK", command=self.okay)
        ok.grid(row=0, column=0)
        cancel = tk.Button(frame, text="Cancel", command=self.cancel)
        cancel.grid(row=0, column=0)

    def okay(self):
        pass

    def cancel(self):
        pass

root = tk.Tk()
root.title("Rationale 0.1")
app = rationaleApp(root)
#imagebroken = Image.open("img/rat32.png")
#photobroken = ImageTk.PhotoImage(imagebroken)
#root.wm_iconbitmap = photobroken

root.mainloop()


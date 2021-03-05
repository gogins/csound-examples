#!/usr/bin/python2.5

import Tix as tk
import tkColorChooser as tkcc
import copy

class regiondialog:
    def __init__(self, parent=None):
        self.myparent = parent
        self.myroot = self.myparent.myparent
        self.regionmaybe = copy.deepcopy(self.myparent.regionlist)
        self.regionfr = tk.Toplevel(self.myroot, width=640, height=480)
        self.regionfr.title("Regions")
        self.regionfr.rowconfigure(0, weight=1)
        self.regionfr.rowconfigure(1, weight=0)
        self.regionfr.columnconfigure(0, weight=1)
        self.regionbuttons = tk.ButtonBox(self.regionfr, width=640, height=80)
        self.regionbuttons.add('ok', text='OK', command=self.ok)
        self.regionbuttons.add('cancel', text='Cancel', command=self.cancel)
        self.regionbuttons.add('apply', text='Apply', command=self.apply)
        self.regionbuttons.grid(row=1, column=0, sticky='ew')
        self.canvas = tk.Canvas(self.regionfr)
        self.canvas.grid(row=0, column=0, sticky='nesw')
        self.canvas.rowconfigure(2, weight=1)
        self.canvas.columnconfigure(0, weight=1)
        self.toprow = tk.Frame(self.canvas)
        self.toprowoncanvas = self.canvas.create_window(0, 0, window=self.toprow, anchor="nw")
        self.toprow.columnconfigure(0, weight=0)
        self.toprow.columnconfigure(1, weight=1)
        self.botrow = tk.Frame(self.canvas, bd=3, relief="ridge")
#        self.botrow.grid(row=1, column=0, sticky='we')
        self.botrow.columnconfigure(0, weight=0)
        self.botrow.columnconfigure(1, weight=1)
        self.scroll = tk.Scrollbar(self.regionfr, orient='vertical', takefocus=0)
        self.canvas.config(yscrollcommand=self.scroll.set)
        self.canvas.config(scrollregion=self.canvas.bbox("all"))
        self.scroll.config(command=self.canvas.yview)
        self.regionfr.bind("<Button-4>",
                              lambda
                              event, arg1="scroll", arg2=-1, arg3="units":
                              self.canvas.yview(arg1, arg2, arg3), "+")
        self.regionfr.bind("<Button-5>",
                              lambda
                              event, arg1="scroll", arg2=1, arg3="units":
                              self.canvas.yview(arg1, arg2, arg3), "+")

        self.regionlinelist = []

#        print self.regionmaybe
        for reg in self.regionmaybe:
            number = self.regionmaybe.index(reg)
            newline = self.addregionline(reg, number)

#        self.blankcolor = tk.Frame(self.botrow, width=40, height=40, bg='#999999')
#        self.blankcolor.grid(row=0, column=0, rowspan=2, padx=10)

#        self.blanknum = tk.Control(self.botrow, width=2, min=1, max=9999)
#        self.blanknum.grid(row=0, column=1, padx=20, sticky='w')
#        self.blankden = tk.Control(self.botrow, width=2, min=1, max=9999)
#        self.blankden.grid(row=1, column=1, padx=20, sticky='w')
#        self.blanksubmit = tk.Button(self.botrow, text="Submit")
#        self.blanksubmit.grid(row=0, column=2, padx=10, rowspan=2)

#        self.regionfr.update_idletasks()
#        bottomy = self.toprow.winfo_reqheight()
#        print bottomy
#        self.botrowoncanvas = self.canvas.create_window(0, bottomy, window=self.botrow, anchor="nw")
        self.regionfr.bind("<Return>", self.ok)
        self.regionfr.bind("<Escape>", self.cancel)

    def newregion(self):
        number = len(self.regionmaybe)
        newregion = 3
        self.addregionline(newregion, number)
        self.regionmaybe.append(newregion)

    def addregionline(self, region, number):
        newline = regionline(self, region, number)
        self.regionlinelist.append(newline)
        return newline

    def ok(self, *args):
        self.apply()
        self.cancel()
#        self.myparent.regionlist = copy.deepcopy(self.regionmaybe)
#        self.regionfr.destroy()
#        del self.myparent.

    def cancel(self, *args):
        self.regionfr.destroy()
#        del self.myparent.

    def apply(self):
        self.myparent.regionlist = copy.deepcopy(self.regionmaybe)
        for notewidget in self.myparent.notewidgetlist:
            note = notewidget.note
            notewidget.updateregion()
        self.myparent.score.itemconfigure(self.myparent.hover.hrnumdisp, fill=self.myparent.regionlist[self.myparent.hover.hregion].color)
        self.myparent.score.itemconfigure(self.myparent.hover.hrdendisp, fill=self.myparent.regionlist[self.myparent.hover.hregion].color)
        self.myparent.score.itemconfigure(self.myparent.hover.hregiondisp, fill=self.myparent.regionlist[self.myparent.hover.hregion].color)

class region:
    def __init__(self, parent, num, den, color, octave11):
        self.num = num
        self.den = den
        self.color = color
        self.octave11 = octave11

class regionline:
    def __init__(self, parent, region, number):
        self.myparent = parent
        self.region = region

        self.number = number
        self.frame = tk.Frame(self.myparent.toprow, bd=4, relief='ridge')
        self.frame.grid(row=self.number, column=0, sticky='ew')
        self.numberwidget = tk.Label(self.frame, text=self.number)
        self.numberwidget.grid(row=0, column=0, rowspan=2, padx=10)
        self.color = tk.StringVar()
        self.color.set(self.region.color)
#        self.color.trace("w", self.colorchange)
        self.colorwidget = tk.Frame(self.frame, width=40, height=40, bg=self.color.get())
        self.colorwidget.grid(row=0, column=1, rowspan=2, padx=10)
        self.colorwidget.bind("<Button-1>", self.colorchoose)
#        self.num = tk.IntVar()
#        self.num.set(self.region.num)
#        self.num.trace("w", self.numchange)
#        self.numlabel = tk.Label(self.frame, text="Num")
#        self.numlabel.grid(row=0, column=2, padx=4, sticky='e')
#        self.numwidget = tk.Control(self.frame, min=1, max=99999, width=4, variable=self.num)
#        self.numwidget.grid(row=0, column=3, padx=10)
#        self.den = tk.IntVar()
#        self.den.set(self.region.den)
#        self.den.trace("w", self.denchange)
#        self.denlabel = tk.Label(self.frame, text="Den")
#        self.denlabel.grid(row=1, column=2, padx=4, sticky='e')
#        self.denwidget = tk.Control(self.frame, min=1, max=99999, width=4, variable=self.den)
#        self.denwidget.grid(row=1, column=3, padx=10)
        self.myparent.canvas.config(scrollregion=self.myparent.canvas.bbox("all"))
        self.myparent.canvas.yview_moveto(1.0)
        if self.myparent.scroll.winfo_ismapped():
#            print self.page.scroll.get()
            pass
        else:
            self.myparent.regionfr.update_idletasks()
#            print self.page.scroll.get()
            if self.myparent.scroll.get() != (0.0, 1.0):
                self.myparent.scroll.grid(row=0, column=1, sticky='ns')


    def numchange(self, *args):
        self.region.num = self.num.get()

    def denchange(self, *args):
        self.region.den = self.den.get()

    def colorchange(self, *args):
        self.region.color = self.color.get()

    def colorchoose(self, event):
        tempcolor = tkcc.askcolor(self.color.get(), parent=self.myparent.regionfr, title="Select Color")
        if None not in tempcolor:
            self.region.color = '#%02x%02x%02x' % (tempcolor[0][0], tempcolor[0][1], tempcolor[0][2])
            self.color.set(self.region.color)
            self.colorwidget.configure(bg=self.color.get())
#            self.myparent.myparent.hover.colorupdate(self.myparent.myparent.hover)
#            for note in self.myparent.myparent.notelist:
#                if note.region == self.myparent.regionmaybe.index(self):
#                    reference = note.widget + 3
#                    self.myparent.myparent.score.itemconfigure(reference, fill=self.color, outline=self.color)
#                    for i in range(1, 3):
#                        self.myparent.myparent.score.itemconfigure(reference+i, fill=self.color)

    def lineremove(self, line):
        pass

    def lineadd(self, type):
        pass

class dummy:
    def __init__(self, parent, out):
        self.page = parent
        self.out = out
        self.flag = 'c'
#        self.place = len(self.page.linelist)
        self.place = self.out.instrument.outlist.index(self.out)
        self.mute = tk.BooleanVar()
        self.mute.set(self.out.mute)
        self.mute.trace("w", self.mutechange)
        self.solo = tk.BooleanVar()
        self.solo.set(self.out.solo)
        self.solo.trace("w", self.solochange)
        self.volume = tk.DoubleVar()
        self.volume.set(self.out.volume)
        self.volume.trace("w", self.volumechange)
        self.instnum = tk.StringVar()
        self.instnum.set(self.out.instnum)
        self.instnum.trace("w", self.instnumchange)
        self.csdstring = tk.StringVar()
        self.csdstring.set(self.out.pfields)
        self.csdstring.trace("w", self.csdstringchange)
        self.frame = tk.Frame(self.page.toprow, bd=5, relief="ridge")
        self.frame.grid(row=self.place, column=0, columnspan=2, sticky='ew')
        self.frame.columnconfigure(0, weight=0)
        self.frame.columnconfigure(1, weight=0)
        self.frame.columnconfigure(2, weight=0)
        self.frame.columnconfigure(3, weight=0)
        self.frame.columnconfigure(4, weight=0)
        self.frame.columnconfigure(5, weight=0)
        self.frame.columnconfigure(6, weight=0)
        self.frame.columnconfigure(7, weight=0)
        self.frame.columnconfigure(8, weight=1)
        self.field1 = tk.Entry(self.frame, width=2)
        self.field1.grid(row=0, column=0, sticky='w', pady=10, padx=20)
        self.field1.insert(0, 'c')
        self.field1.configure(state='disabled')
        self.mutewidget = tk.Checkbutton(self.frame, height=1, width=1, variable=self.mute, bg='#ffaaaa', selectcolor='#996666', padx=2, pady=0, indicatoron=0, activebackground='#ff8888')
        self.mutewidget.grid(row=0, column=1, rowspan=1)
        self.solowidget = tk.Checkbutton(self.frame, height=1, width=1, variable=self.solo, bg='#aaffaa', selectcolor='#669966', padx=2, pady=0, indicatoron=0, activebackground='#88ff88')
        self.solowidget.grid(row=0, column=2, rowspan=1)
        self.field2label = tk.Label(self.frame, text="inst")
        self.field2label.grid(row=0, column=self.page.cc1, rowspan=1, columnspan=self.page.ccs1, sticky='w')
        self.field2 = tk.Entry(self.frame, width=8, textvariable=self.instnum)
        self.field2.grid(row=0, column=self.page.cc2, rowspan=1, columnspan=self.page.ccs2, sticky='w')
        self.field2.focus_set()
        self.field2.select_range(0, "end")
        self.field2.bind("<FocusOut>", self.stringupdate)
        self.field3label = tk.Label(self.frame, text="   time dur ")
        self.field3label.grid(row=0, column=self.page.cc3, rowspan=1, columnspan=self.page.ccs3)
        self.field3 = tk.Entry(self.frame, width=30, textvariable=self.csdstring)
        self.field3.grid(row=0, column=self.page.cc4, rowspan=1, columnspan=self.page.ccs4, sticky='w')
        self.field3.bind("<FocusOut>", self.stringupdate)
        self.x = tk.Button(self.frame, text="x", padx=0, pady=0, command=self.remove)
        self.x.grid(row=0, column=self.page.cc5, sticky='e', padx=40)
        self.volumewidget = tk.Scale(self.frame, orient="horizontal", width=7, fg='#552288', sliderlength=10, sliderrelief='raised', tickinterval=10, from_=-90, to=10, resolution=.1, variable=self.volume)
        self.volumewidget.set(self.out.volume)
        self.volumewidget.grid(row=1, column=0, columnspan=11, sticky='ew', pady=2)
        self.page.widget.update_idletasks()
        bottomy = self.page.toprow.winfo_reqheight()
        self.page.canvas.coords(self.page.botrowoncanvas, 0, bottomy)
        self.page.canvas.config(scrollregion=self.page.canvas.bbox("all"))
        self.page.canvas.yview_moveto(1.0)
        if self.page.scroll.winfo_ismapped():
#            print self.page.scroll.get()
            pass
        else:
            self.page.widget.update_idletasks()
#            print self.page.scroll.get()
            if self.page.scroll.get() != (0.0, 1.0):
                self.page.scroll.grid(row=1, column=1, sticky='ns')

#        self.string = ''

    def mutechange(self, *args):
        self.out.mute = self.mute.get()

    def solochange(self, *args):
        self.out.solo = self.solo.get()

    def volumechange(self, *args):
        self.out.volume = self.volume.get()

    def instnumchange(self, *args):
        self.stringupdate(self)
        self.out.instnum = self.instnum.get()

    def csdstringchange(self, *args):
        self.stringupdate(self)
        self.out.pfields = self.csdstring.get()

    def stringupdate(self, *args):
        instnum = self.instnum.get()
        try:
            inst = instnum.split()[0]
            csdstring = self.csdstring.get()
            self.out.string = '%s %s %s' % (inst, ' time dur ', csdstring)
        except:
            pass

    def remove(self):
        index = self.place
        self.frame.destroy()
        for line in self.page.linelist:
            if line.place > index:
                line.place -= 1
                line.frame.grid(row=line.place)
        del self.page.myinst.outlist[index]
        self.page.widget.update_idletasks()
        if len(self.page.linelist) > 0:
            bottomy = self.page.toprow.winfo_reqheight()
        else:
            bottomy=0
#        bottomy = self.page.toprow.winfo_reqheight()
        self.page.canvas.coords(self.page.botrowoncanvas, 0, bottomy)
        if self.page.scroll.winfo_ismapped():
            self.page.canvas.config(scrollregion=self.page.canvas.bbox("all"))
            self.page.widget.update_idletasks()
            if self.page.scroll.get() == (0.0, 1.0):
                self.page.scroll.grid_remove()
        del self.page.linelist[index]


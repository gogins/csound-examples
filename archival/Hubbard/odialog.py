#!/usr/bin/python2.5

#if __name__ == '__main__':
import Tix as tk
import tkColorChooser as tkcc
import tkFileDialog as tkfd
import copy

class outputdialog:
    def __init__(self, parent=None):
        if __name__ == '__main__':
            self.myparent = self.myroot = parent
            self.myparent.rowconfigure(0, weight=1)
            self.myparent.columnconfigure(0, weight=1)
            self.outputfr = tk.Frame(self.myparent, width=640, height=480)
            self.outputfr.rowconfigure(0, weight=1)
            self.outputfr.rowconfigure(1, weight=0)
            self.outputfr.columnconfigure(0, weight=1)
            self.outputfr.grid(row=0, column=0, sticky='nesw')
            self.nb = tk.NoteBook(self.outputfr, width=640, height=400)
            self.nb.rowconfigure(0, weight=1)
            self.nb.columnconfigure(0, weight=1)
            self.outputbuttons = tk.ButtonBox(self.outputfr, width=640, height=80)
            self.outputbuttons.add('ok', text='OK', command=self.ok)
            self.outputbuttons.add('cancel', text='Cancel', command=self.cancel)
            self.outputbuttons.add('apply', text='Apply', command=self.apply)
            self.outputbuttons.add('play', text='Play', command=self.audition)
            self.outputbuttons.add('newinst', text='New Instrument', command=self.newinstrument)
            self.outputbuttons.grid(row=1, column=0, sticky='')
        else:
            self.myparent = parent
            self.myroot = self.myparent.myparent
            self.instmaybe = copy.deepcopy(self.myparent.instlist)
            self.outputfr = tk.Toplevel(self.myroot, width=640, height=480)
            self.outputfr.bind("<Return>", self.ok)
            self.outputfr.bind("<Escape>", self.cancel)
            self.outputfr.title("Output")
            self.outputfr.rowconfigure(0, weight=1)
            self.outputfr.rowconfigure(1, weight=0)
            self.outputfr.columnconfigure(0, weight=1)
            self.nb = tk.NoteBook(self.outputfr, width=640, height=480)
            self.nb.rowconfigure(0, weight=1)
            self.nb.columnconfigure(0, weight=1)
            self.nb.grid(row=0, column=0, sticky='nesw')
            self.outputbuttons = tk.ButtonBox(self.outputfr, width=640, height=80)
            self.outputbuttons.add('ok', text='OK', command=self.ok)
            self.outputbuttons.add('cancel', text='Cancel', command=self.cancel)
            self.outputbuttons.add('apply', text='Apply', command=self.apply)
            self.outputbuttons.add('play', text='Play', command=self.audition)
            self.outputbuttons.add('newinst', text='New Instrument', command=self.newinstrument)
            self.outputbuttons.grid(row=1, column=0, sticky='')

        self.instpagelist = []
        self.csdpage = self.nb.add('csd', label='CSD')
        self.csdpage.rowconfigure(0, weight=1)
        self.csdpage.rowconfigure(1, weight=0)
        self.csdpage.columnconfigure(0, weight=1)
        self.csdpage.columnconfigure(1, weight=1)
        self.csdtext = tk.Text(self.csdpage)
        self.csdtext.grid(row=0, column=0, columnspan=2, sticky='nesw')
        self.csdtext.insert('0.0', self.myparent.csdimported)
        for i in range(1, len(self.instmaybe)):
            inst = self.instmaybe[i]
            newpage = self.addinstpage(inst)
            for out in inst.outlist:
                if out.__class__.__name__ == 'csdout':
                    newline = csdline(newpage, out)
                elif out.__class__.__name__ == 'sf2out':
                    newline = sf2line(newpage, out)
        self.autoload = tk.BooleanVar()
        self.autoload.set(self.myparent.outautoload)
        self.autocheck = tk.Checkbutton(self.csdpage, variable=self.autoload)
        self.autocheck.grid(row=1, column=0, sticky='e')
        self.csdloadbutton = tk.Button(self.csdpage, text="Load", command=self.csdload)
        self.csdloadbutton.grid(row=1, column=1, sticky='w')

    def newinstrument(self):
        number = len(self.instmaybe)
        newinst = instrument(self.myparent, number, '#999999')
        self.addinstpage(newinst)
        self.instmaybe.append(newinst)

    def csdload(self):
        self.myparent.csdimport = tkfd.askopenfilename()
        if self.myparent.csdimport:
            file = open(self.myparent.csdimport)
            if file:
                self.myparent.csdimported = ''
                for line in file:
                    self.myparent.csdimported += line
                self.csdtext.delete(1.0, "end")
                self.csdtext.insert("end", self.myparent.csdimported)

    def addinstpage(self, inst):
        newpage = instrumentpage(self, inst)
        self.instpagelist.append(newpage)
        return newpage

    def removeinstpage(self, inst):
        pass

    def save(self):
        print "Save"

    def ok(self, *args):
        self.apply()
        self.cancel()

    def cancel(self, *args):
        self.outputfr.destroy()
        del self.myparent.out

    def audition(self):
        self.myparent.play(self.instmaybe)

    def apply(self):
        self.myparent.outautoload = self.autoload.get()
        self.myparent.csdimported = self.csdtext.get(0.0, "end")
        self.myparent.instlist = copy.deepcopy(self.instmaybe)
        for notewidget in self.myparent.notewidgetlist:
            note = notewidget.note
            notewidget.updateinst()
        color = self.myparent.instlist[self.myparent.hover.hinst].color
        self.myparent.hover.entrycolor = color
        self.myparent.score.itemconfigure(self.myparent.hover.widget, fill=color)
        self.myparent.score.itemconfigure(self.myparent.hover.hnumdisp, fill=color)
        self.myparent.score.itemconfigure(self.myparent.hover.hdendisp, fill=color)
        self.myparent.score.itemconfigure(self.myparent.hover.hvoicedisp, fill=color)

class instrument:
    def __init__(self, parent, number, color):
        self.number = number
        self.color = color
        self.outlist = []
        self.mute = 0
        self.solo = 0

class instrumentpage:
    def __init__(self, parent, inst):
        self.myparent = parent
        self.myinst = inst
        number = self.myinst.number
        self.linelist = []
        self.mute = tk.BooleanVar()
        self.mute.set(self.myinst.mute)
        self.mute.trace("w", self.mutechange)
        self.solo = tk.BooleanVar()
        self.solo.set(self.myinst.solo)
        self.solo.trace("w", self.solochange)
        self.widget = self.myparent.nb.add('inst%.4d' % number, label='i%d' % number, raisecmd=lambda arg1=0.0: self.canvas.yview_moveto(arg1))

        self.widget.rowconfigure(0, weight=0)
        self.widget.rowconfigure(1, weight=1)
#        self.widget.rowconfigure(2, weight=1)
#        self.widget.rowconfigure(3, weight=1)
        self.widget.columnconfigure(0, weight=1)
#        self.widget.columnconfigure(1, weight=1)
        self.toprow = tk.Frame(self.widget)
        self.toprow.grid(row=0, column=0, sticky='we')
        self.toprow.columnconfigure(0, weight=0)
        self.toprow.columnconfigure(1, weight=0)
        self.toprow.columnconfigure(2, weight=0)
        self.toprow.columnconfigure(3, weight=1)
        self.canvas = tk.Canvas(self.widget)
        self.canvas.grid(row=1, column=0, sticky='nesw')
        self.canvas.rowconfigure(2, weight=1)
        self.canvas.columnconfigure(0, weight=1)
        self.midrow = tk.Frame(self.canvas)
#        self.midrow.grid(row=0, column=0, sticky='we')
        self.midrowoncanvas = self.canvas.create_window(0, 0, window=self.midrow, anchor="nw")
        self.midrow.columnconfigure(0, weight=0)
        self.midrow.columnconfigure(1, weight=1)
        self.botrow = tk.Frame(self.canvas, bd=5, relief="ridge")
#        self.botrow.grid(row=1, column=0, sticky='we')
        self.botrow.columnconfigure(0, weight=0)
        self.botrow.columnconfigure(1, weight=1)
#        self.scroll = tk.Scrollbar(self.widget, orient='vertical', takefocus=0, troughcolor="#ccaaaa", activebackground="#cc7777", bg="#cc8f8f")
        self.scroll = tk.Scrollbar(self.widget, orient='vertical', takefocus=0)
        self.canvas.config(yscrollcommand=self.scroll.set)
        self.canvas.config(scrollregion=self.canvas.bbox("all"))
        self.scroll.config(command=self.canvas.yview)
        self.myparent.outputfr.bind("<Button-4>",
                              lambda
                              event, arg1="scroll", arg2=-1, arg3="units":
                              self.canvas.yview(arg1, arg2, arg3), "+")
        self.myparent.outputfr.bind("<Button-5>",
                              lambda
                              event, arg1="scroll", arg2=1, arg3="units":
                              self.canvas.yview(arg1, arg2, arg3), "+")
#        self.scroll.grid(row=1, column=1, sticky='ns')
#       SF2 LINE GRID COLUMNS
        self.sc1 = 3
        self.scs1 = 1
        self.sc2 = 4
        self.scs2 = 1
        self.sc3 = 5
        self.scs3 = 1
        self.sc4 = 6
        self.scs4 = 1
        self.sc5 = 7
        self.scs5 = 1
        self.sc6 = 8
        self.scs6 = 1
        self.sc7 = 9
        self.scs7 = 1
#       CSOUND LINE GRID COLUMNS
        self.cc1 = 3
        self.ccs1 = 1
        self.cc2 = 4
        self.ccs2 = 1
        self.cc3 = 5
        self.ccs3 = 1
        self.cc4 = 6
        self.ccs4 = 1
        self.cc5 = 7
        self.ccs5 = 1
        self.color = tk.StringVar()
        self.color.set(self.myinst.color)
        self.color.trace("w", self.colorchange)
        self.colorwidget = tk.Frame(self.toprow, width=40, height=40, bg=self.color.get())
        self.colorwidget.grid(row=0, column=0, padx=10)
        self.colorwidget.bind("<Button-1>", self.colorchoose)
        self.mutewidget = tk.Checkbutton(self.toprow, bg='#ffaaaa', text='M', variable=self.mute, indicatoron=1, activebackground='#ffaaaa', selectcolor='#ff0000', width=1, height=1, bd=2, highlightthickness=0)
        self.mutewidget.grid(row=0, column=1, padx=4)
        self.solowidget = tk.Checkbutton(self.toprow, bg='#00aa00', text='S', variable=self.solo, indicatoron=1, activebackground='#00aa00', selectcolor='#00ff00', width=1, height=1, bd=2, highlightthickness=0)
        self.solowidget.grid(row=0, column=2)
        self.blank = tk.Entry(self.botrow, width=2)
        self.blank.grid(row=0, column=0, pady=10, padx=20, sticky='w')
        self.blank.bind("<Tab>", self.outputselect)
        self.widget.update_idletasks()
        bottomy = self.midrow.winfo_reqheight()
#        print bottomy
        self.botrowoncanvas = self.canvas.create_window(0, bottomy, window=self.botrow, anchor="nw")
#        self.myparent.outputfr.bind("<Return>", self.myparent.ok)
#        self.myparent.outputfr.bind("<Escape>", self.myparent.cancel)

    def mutechange(self, *args):
        self.myinst.mute = self.mute.get()

    def solochange(self, *args):
        self.myinst.solo = self.solo.get()

    def colorchange(self, *args):
        self.myinst.color = self.color.get()

    def colorchoose(self, event):
        tempcolor = tkcc.askcolor(self.color.get(), parent=self.widget, title="Select Color")
        if None not in tempcolor:
            self.myinst.color = '#%02x%02x%02x' % (tempcolor[0][0], tempcolor[0][1], tempcolor[0][2])
            self.color.set(self.myinst.color)
            self.colorwidget.configure(bg=self.color.get())
#            self.myparent.myparent.hover.colorupdate(self.myparent.myparent.hover)
#            for note in self.myparent.myparent.notelist:
#                if note.inst == self.myparent.instmaybe.index(self):
#                    reference = note.widget
#                    self.myparent.myparent.score.itemconfigure(reference, fill=self.color.get(), outline=self.color.get())
#                    for i in range(1, 3):
#                        self.myparent.myparent.score.itemconfigure(reference+i, fill=self.color.get())
#                    self.myparent.myparent.score.itemconfigure(reference+6, fill=self.color.get())

    def lineremove(self, line):
        pass

    def lineadd(self, type):
        pass

    def outputselect(self, event):
        type = event.widget.get()
        if event.widget == self.blank:
            if type == 's' or type == 'S':
                newout = sf2out(self.myinst)
                self.myinst.outlist.append(newout)
                newline = sf2line(self, newout)
                self.linelist.append(newline)
            elif type == 'c' or type == 'C':
                newout = csdout(self.myinst)
                self.myinst.outlist.append(newout)
                newline = csdline(self, newout)
                self.linelist.append(newline)
            self.blank.delete(0,last='end')

class sf2out:
    '''Created only by 's' type selection.

    ...Currently not quite implemented.
    '''
    def __init__(self, parent):
        self.instrument = parent
        self.file = ''
        self.bank = 0
        self.program = 0
        self.mute = 0
        self.solo = 0
        self.volume = 0

class sf2line:
    def __init__(self, parent, out):
        self.page = parent
        self.out = out
        self.flag = 's'
        self.place = self.out.instrument.outlist.index(self.out)
        self.mute = tk.BooleanVar()
        self.mute.set(self.out.mute)
        self.mute.trace("w", self.mutechange)
        self.solo = tk.BooleanVar()
        self.solo.set(self.out.solo)
        self.solo.trace("w", self.solochange)
        self.sf2file = tk.StringVar()
        self.sf2file.set(self.out.file)
        self.sf2file.trace("w", self.filechange)
        self.bank = tk.IntVar()
        self.bank.set(self.out.bank)
        self.bank.trace("w", self.bankchange)
        self.program = tk.IntVar()
        self.program.set(self.out.program)
        self.program.trace("w", self.programchange)
        self.csdstring = tk.StringVar()
        self.string = ''
        self.frame = tk.Frame(self.page.midrow, bd=5, relief="ridge")
        self.frame.columnconfigure(0, weight=0)
        self.frame.columnconfigure(1, weight=0)
        self.frame.columnconfigure(2, weight=0)
        self.frame.columnconfigure(3, weight=0)
        self.frame.columnconfigure(4, weight=0)
        self.frame.columnconfigure(5, weight=0)
        self.frame.columnconfigure(6, weight=0)
        self.frame.columnconfigure(7, weight=0)
        self.frame.columnconfigure(8, weight=0)
        self.frame.columnconfigure(9, weight=0)
        self.frame.columnconfigure(10, weight=1)
        self.field1 = tk.Entry(self.frame, width=2)
        self.field1.grid(row=0, column=0, sticky='w', pady=10, padx=20)
        self.field1.insert(0, 's')
        self.field1.configure(state='disabled')
        self.mutewidget = tk.Checkbutton(self.frame, height=1, width=1, variable=self.mute, bg='#ffaaaa', selectcolor='#996666', padx=2, pady=0, indicatoron=0, activebackground='#ff8888')
        self.mutewidget.grid(row=0, column=1, rowspan=1)
        self.solowidget = tk.Checkbutton(self.frame, height=1, width=1, variable=self.solo, bg='#aaffaa', selectcolor='#669966', padx=2, pady=0, indicatoron=0, activebackground='#88ff88')
        self.solowidget.grid(row=0, column=2, rowspan=1)
        self.field2label = tk.Label(self.frame, text="sf2")
        self.field2label.grid(row=0, column=self.page.sc1, rowspan=1, columnspan=self.page.scs1, sticky='w')
        self.field2 = tk.ComboBox(self.frame, variable=self.sf2file, editable=0, value="Load")
        self.field2.entry.configure(width=10)
        self.field2.grid(row=0, column=self.page.sc2, rowspan=1, columnspan=self.page.scs2, sticky='w', padx=0)
        self.field2.focus_set()
#        self.field2.appendhistory("Load")
        self.field3label = tk.Label(self.frame, text="   bank")
        self.field3label.grid(row=0, column=self.page.sc3, rowspan=1, columnspan=self.page.scs3, sticky='w')
        self.field3 = tk.Control(self.frame, min=0, max=128, variable=self.bank)
        self.field3.grid(row=0, column=self.page.sc4, rowspan=1, columnspan=self.page.scs4, sticky='w')
        self.field4label = tk.Label(self.frame, text="   prog")
        self.field4label.grid(row=0, column=self.page.sc5, rowspan=1, columnspan=self.page.scs5, sticky='w')
        self.field4 = tk.Control(self.frame, min=0, max=128, variable=self.program)
        self.field4.grid(row=0, column=self.page.sc6, rowspan=1, columnspan=self.page.scs6, sticky='w')
        self.x = tk.Button(self.frame, text="x", padx=0, pady=0, command=self.remove)
        self.x.grid(row=0, column=self.page.sc7, sticky='e', padx=40)
        self.volumewidget = tk.Scale(self.frame, orient="horizontal", width=7, fg='#552288', sliderlength=10, sliderrelief='raised', tickinterval=10, from_=-90, to=10, resolution=.1, variable=self.volume)
        self.volumewidget.grid(row=1, column=0, columnspan=11, sticky='ew', pady=2)
        self.page.widget.update_idletasks()
        bottomy = self.page.midrow.winfo_reqheight()
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

        self.string = ''

    def mutechange(self, *args):
        self.out.mute = self.mute.get()

    def solochange(self, *args):
        self.out.solo = self.solo.get()

    def filechange(self, *args):
        self.out.file = self.sf2file.get()

    def bankchange(self, *args):
        self.out.bank = self.bank.get()

    def programchange(self, *args):
        self.out.program = self.program.get()

    def volumechange(self, *args):
        self.out.volume = self.volume.get()

    def printbank(self, value):
        print 'Bank: %d' % int(value)

    def printprogram(self, value):
        print 'Program: %d' % int(value)

    def remove(self):
        index = self.place
        self.frame.destroy()
        for line in self.page.linelist:
            if line.place > index:
                line.place -= 1
                line.frame.grid(row=line.place)
        del self.page.myinst.outlist[index]
        self.page.widget.update_idletasks()
        if len(self.page.linelist) > 1:
            bottomy = self.page.midrow.winfo_reqheight()
        else:
            bottomy=0
        self.page.canvas.coords(self.page.botrowoncanvas, 0, bottomy)
        if self.page.scroll.winfo_ismapped():
            self.page.canvas.config(scrollregion=self.page.canvas.bbox("all"))
            self.page.widget.update_idletasks()
            if self.page.scroll.get() == (0.0, 1.0):
                self.page.scroll.grid_remove()
        del self.page.linelist[index]

class csdout:
    '''Created only by 'c' type selection.'''
    def __init__(self, parent):
        self.instrument = parent
        self.instnum = 'ratdefault'
        self.pfields = 'db freq'
        self.mute = 0
        self.solo = 0
        self.volume = 0
        self.string = self.instnum + 'time dur' + self.pfields

class csdline:
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
        self.frame = tk.Frame(self.page.midrow, bd=5, relief="ridge")
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
        bottomy = self.page.midrow.winfo_reqheight()
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
        if len(self.page.linelist) > 1:
            bottomy = self.page.midrow.winfo_reqheight()
        else:
            bottomy=0
        self.page.canvas.coords(self.page.botrowoncanvas, 0, bottomy)
        if self.page.scroll.winfo_ismapped():
            self.page.canvas.config(scrollregion=self.page.canvas.bbox("all"))
            self.page.widget.update_idletasks()
            if self.page.scroll.get() == (0.0, 1.0):
                self.page.scroll.grid_remove()
        del self.page.linelist[index]

if __name__ == '__main__':
    root = tk.Tk()
#    root.withdraw()
    output = outputdialog(root)
    root.title("Output")
    root.mainloop()

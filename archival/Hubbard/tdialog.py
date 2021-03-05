#!/usr/bin/python2.5

import Tix as tk
import copy

class tempodialog:
    def __init__(self, parent=None):
        self.myparent = parent
        self.myroot = self.myparent.myparent
        self.tempomaybe = copy.deepcopy(self.myparent.tempolist)
        self.tempofr = tk.Toplevel(self.myroot, width=480, height=360)
        self.tempofr.title("Tempo Changes")
        self.tempofr.rowconfigure(0, weight=1)
        self.tempofr.rowconfigure(1, weight=0)
        self.tempofr.columnconfigure(0, weight=1)
        self.tempobuttons = tk.ButtonBox(self.tempofr, width=480, height=360)
        self.tempobuttons.add('ok', text='OK', command=self.ok)
        self.tempobuttons.add('cancel', text='Cancel', command=self.cancel)
        self.tempobuttons.add('apply', text='Apply', command=self.apply)
        self.tempobuttons.add('sort', text='Sort', command=self.reorder)
        self.tempobuttons.grid(row=1, column=0, sticky='')
        self.canvas = tk.Canvas(self.tempofr, width=480, height=360)
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
        bottomy = self.toprow.winfo_reqheight()
#        print bottomy
        self.botrowoncanvas = self.canvas.create_window(0, bottomy, window=self.botrow, anchor="nw")
        self.tempolinelist = []

#        print self.tempomaybe
        self.scroll = tk.Scrollbar(self.tempofr, orient='vertical', takefocus=0)
        self.canvas.config(yscrollcommand=self.scroll.set)
        self.canvas.config(scrollregion=self.canvas.bbox("all"))
        self.scroll.config(command=self.canvas.yview)
        self.tempofr.bind("<Button-4>",
                              lambda
                              event, arg1="scroll", arg2=-1, arg3="units":
                              self.canvas.yview(arg1, arg2, arg3), "+")
        self.tempofr.bind("<Button-5>",
                              lambda
                              event, arg1="scroll", arg2=1, arg3="units":
                              self.canvas.yview(arg1, arg2, arg3), "+")
        for tempo in self.tempomaybe:
            number = self.tempomaybe.index(tempo)
            newline = self.addtempoline(tempo, number)

        self.addbar = tk.IntVar()
        self.addbeat = tk.IntVar()
        self.addbpm = tk.DoubleVar()
        self.addunit = tk.IntVar()
        self.blankbar = tk.Entry(self.botrow, width=4, textvariable=self.addbar)
        self.blankbar.focus_set()
        self.blankbar.select_range(0, "end")
        self.blankbar.grid(padx=10, sticky='')
        self.blankbeat = tk.Entry(self.botrow, width=3, textvariable=self.addbeat)
        self.blankbeat.grid(row=0, column=1, padx=10, sticky='')
        self.blankbpm = tk.Entry(self.botrow, width=5, textvariable=self.addbpm)
        self.blankbpm.grid(row=0, column=2, padx=10, sticky='')
        self.blankunit = tk.ComboBox(self.botrow, editable=1, variable=self.addunit, listwidth=8)
        self.blankunit.entry.configure(width=3)
        self.blankunit.append_history(1)
        self.blankunit.append_history(2)
        self.blankunit.append_history(3)
        self.blankunit.append_history(4)
        self.blankunit.append_history(6)
        self.blankunit.append_history(8)
        self.blankunit.append_history(12)
        self.blankunit.append_history(16)
        self.blankunit.grid(row=0, column=3, padx=10, sticky='')

        self.blankaddtempo = tk.Button(self.botrow, text="Add Tempo", command=self.newtempo)
        self.blankaddtempo.grid(row=0, column=4, padx=10, rowspan=1)

        self.tempofr.update_idletasks()
        self.tempofr.bind("<Return>", self.ok)
        self.tempofr.bind("<Escape>", self.cancel)

    def newtempo(self):
        number = len(self.tempomaybe)
        bar = self.addbar.get()
        beat = self.addbeat.get()
        bpm = self.addbpm.get()
        unit = self.addunit.get()
        if bar > 0 and beat > 0 and bpm > 0 and unit > 0:
            newtempo = tempo(self.myparent, bar, beat, bpm, unit)
            self.addtempoline(newtempo, number)
            self.tempomaybe.append(newtempo)
#            self.addbar.set(0)
#            self.addbeat.set(0)
#            self.addbpm.set(0)
#            self.addunit.set(4)
            self.blankbar.focus_set()
            self.blankbar.select_range(0, "end")

    def addtempoline(self, tempo, number):
        newline = tempoline(self, tempo, tempo.bar, tempo.beat, tempo.bpm, tempo.unit, number)
        self.tempolinelist.append(newline)
#        self.tempofr.update_idletasks()
#        bottomy = self.toprow.winfo_reqheight()
#        print bottomy
#        self.botrowoncanvas
#        self.tempofr.grid_propagate()
        return newline

    def ok(self, *args):
        self.apply()
        self.cancel()

    def cancel(self, *args):
        self.tempofr.destroy()

    def apply(self):
        self.reorder()
        self.myparent.tempolist = copy.deepcopy(self.tempomaybe)
        for tempo in self.myparent.tempolist:
            tempo.findcsdbeat(self.myparent)

    def reorder(self, *args):
        self.tempolinelist.sort(key=self.sortextract)
        for tempoline in self.tempolinelist:
            tempoline.number = self.tempolinelist.index(tempoline)
            tempoline.frame.grid(row=tempoline.number, column=0, sticky='ew')
        self.tempomaybe = [line.tempo for line in self.tempolinelist]

    def sortextract(self, item):
        if item.bar.get() != '':
            bar = int(item.bar.get())
        else: bar = '0'
        if item.beat != '':
            beat = float(item.beat.get())
        else: beat = '0'
        return (bar, beat)

class tempo:
    def __init__(self, parent, bar, beat, bpm, unit):
        '''Left-click: add new or edit existing tempo;
                tempo may be dragged left and right,
                and dragging up and down raises or lowers tempo value
           Right-click: edit list of tempos'''
#        self.myparent = parent
        self.bar = bar
        self.beat = beat
        self.bpm = bpm
        self.unit = unit

#        self.tick = tick
#        self.widget = widget
        self.findcsdbeat(parent)

    def findcsdbeat(self, app):
        sum = 0
        if len(app.meterlist):
            for i in range(len(app.meterlist)):
                if self.bar > app.meterlist[i].bar:
                    sum += (app.meterlist[i].bar - app.meterlist[i-1].bar) * 4 * float(app.meterlist[i-1].top)/float(app.meterlist[i-1].bottom)
                else:
                    sum += (self.bar - app.meterlist[i-1].bar) * 4 * float(app.meterlist[i-1].top)/float(app.meterlist[i-1].bottom) + (self.beat - 1) * 4 / app.meterlist[i-1].bottom
                    break
        else:
            sum = 4 * (self.bar - 1) + self.beat - 1
#            print self.bar.get(), self.beat.get()
        self.scobeat = sum
#        print sum

class tempoline:
    def __init__(self, parent, tempo, bar, beat, bpm, unit, number):
        self.myparent = parent
        self.tempo = tempo
        self.number = number
        self.frame = tk.Frame(self.myparent.toprow, bd=4, relief='ridge')
        self.frame.grid(row=self.number, column=0, sticky='ew')
        self.bar = tk.IntVar()
        self.bar.set(bar)
        self.bar.trace("w", self.barchange)
        self.barlabel = tk.Label(self.frame, text="Bar:")
        self.barlabel.grid(row=0, column=0, padx=4, sticky='e')
        self.barwidget = tk.Control(self.frame, min=1, max=99999, width=4, variable=self.bar)
        self.barwidget.grid(row=0, column=1, padx=4, sticky='')
        self.beat = tk.IntVar()
        self.beat.set(beat)
        self.beat.trace("w", self.beatchange)
        self.beatlabel = tk.Label(self.frame, text="Beat:")
        self.beatlabel.grid(row=0, column=2, padx=4, sticky='e')
        self.beatwidget = tk.Control(self.frame, min=1, max=32, width=2, variable=self.beat)
        self.beatwidget.grid(row=0, column=3, padx=4, sticky='')
        self.bpm = tk.DoubleVar()
        self.bpm.set(bpm)
        self.bpm.trace("w", self.bpmchange)
        self.bpmlabel = tk.Label(self.frame, text="BPM:")
        self.bpmlabel.grid(row=0, column=4, padx=4, sticky='e')
        self.bpmwidget = tk.Entry(self.frame, width=4, textvariable=self.bpm)
        self.bpmwidget.grid(row=0, column=5, padx=4)
        self.unit = tk.IntVar()
        self.unit.set(unit)
        self.unit.trace("w", self.unitchange)
        self.unitlabel = tk.Label(self.frame, text="Unit:")
        self.unitlabel.grid(row=0, column=6, padx=4, sticky='e')
        self.unitwidget = tk.ComboBox(self.frame, variable=self.unit, editable=0)
        self.unitwidget.entry.configure(width=3)
        self.unitwidget.append_history(1)
        self.unitwidget.append_history(2)
        self.unitwidget.append_history(3)
        self.unitwidget.append_history(4)
        self.unitwidget.append_history(6)
        self.unitwidget.append_history(8)
        self.unitwidget.append_history(12)
        self.unitwidget.append_history(16)

        self.unitwidget.entry.configure(width=3)
#        for value in ('Sixteenth', 'Dotted Sixteenth', 'Eighth', 'Dotted Eighth', 'Quarter', 'Dotted Quarter', 'Half', 'Dotted Half', 'Whole'):
#            self.unitwidget.append_history(value)
        self.unitwidget.grid(row=0, column=7, padx=4, sticky='')
        self.x = tk.Button(self.frame, text="x", padx=0, pady=0, command=self.remove)
        self.x.grid(row=0, column=8, sticky='e', padx=40)

        self.myparent.tempofr.update_idletasks()
        bottomy = self.myparent.toprow.winfo_reqheight()
#        print bottomy

        self.myparent.canvas.coords(self.myparent.botrowoncanvas, 0, bottomy)
        if self.myparent.scroll.winfo_ismapped():
#            print self.page.scroll.get()
            pass
        else:
            self.myparent.tempofr.update_idletasks()
#            print self.page.scroll.get()
            if self.myparent.scroll.get() != (0.0, 1.0):
                self.myparent.scroll.grid(row=1, column=1, sticky='ns')

        self.myparent.canvas.config(scrollregion=self.myparent.canvas.bbox("all"))
        self.myparent.canvas.yview_moveto(1.0)
        if self.myparent.scroll.winfo_ismapped():
#            print self.page.scroll.get()
            pass
        else:
            self.myparent.tempofr.update_idletasks()
#            print self.page.scroll.get()
            if self.myparent.scroll.get() != (0.0, 1.0):
                self.myparent.scroll.grid(row=0, column=1, sticky='ns')


    def barchange(self, *args):
        self.tempo.bar = self.bar.get()

    def beatchange(self, *args):
        self.tempo.beat = self.beat.get()

    def bpmchange(self, *args):
        self.tempo.bpm = self.bpm.get()

    def unitchange(self, *args):
        self.tempo.unit = self.unit.get()

    def remove(self):
        num = self.myparent.tempolinelist.index(self)
        self.frame.destroy()
        for tempoline in self.myparent.tempolinelist:
            if tempoline.number > num:
                tempoline.number -= 1
                tempoline.frame.grid(row=tempoline.number, column=0, sticky='ew')
        todel1 = self.myparent.tempomaybe.pop(num)
        todel2 = self.myparent.tempolinelist.pop(num)
        del todel1
        self.myparent.tempofr.update_idletasks()
        if len(self.myparent.tempolinelist) > 0:
            bottomy = self.myparent.toprow.winfo_reqheight()
        else:
            bottomy=0
#        bottomy = self.myparent.toprow.winfo_reqheight()
        print 'bottomy', bottomy
        self.myparent.canvas.coords(self.myparent.botrowoncanvas, 0, bottomy)

        del todel2


    def lineremove(self, line):
        pass

    def lineadd(self, type):
        pass


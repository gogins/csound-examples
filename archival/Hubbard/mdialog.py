#!/usr/bin/python2.5

import Tix as tk
import copy

class meterdialog:
    def __init__(self, parent=None):
        self.myparent = parent
        self.myroot = self.myparent.myparent
        self.metermaybe = copy.deepcopy(self.myparent.meterlist)
        self.meterfr = tk.Toplevel(self.myroot, width=400, height=300)
        self.meterfr.title("Meter Changes")
        self.meterfr.rowconfigure(0, weight=1)
        self.meterfr.rowconfigure(1, weight=0)
        self.meterfr.columnconfigure(0, weight=1)
        self.meterbuttons = tk.ButtonBox(self.meterfr, width=400, height=300)
        self.meterbuttons.add('ok', text='OK', command=self.ok)
        self.meterbuttons.add('cancel', text='Cancel', command=self.cancel)
        self.meterbuttons.add('apply', text='Apply', command=self.apply)
        self.meterbuttons.add('sort', text='Sort', command=self.reorder)
        self.meterbuttons.grid(row=1, column=0, sticky='')
        self.canvas = tk.Canvas(self.meterfr, width=400, height=300)
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
        self.meterlinelist = []

#        print self.metermaybe
        self.scroll = tk.Scrollbar(self.meterfr, orient='vertical', takefocus=0)
        self.canvas.config(yscrollcommand=self.scroll.set)
        self.canvas.config(scrollregion=self.canvas.bbox("all"))
        self.scroll.config(command=self.canvas.yview)
        self.meterfr.bind("<Button-4>",
                              lambda
                              event, arg1="scroll", arg2=-1, arg3="units":
                              self.canvas.yview(arg1, arg2, arg3), "+")
        self.meterfr.bind("<Button-5>",
                              lambda
                              event, arg1="scroll", arg2=1, arg3="units":
                              self.canvas.yview(arg1, arg2, arg3), "+")
        for meter in self.metermaybe:
            number = self.metermaybe.index(meter)
            newline = self.addmeterline(meter, number)

        self.addbar = tk.IntVar()
        self.addbar.set(1)
        self.addtop = tk.IntVar()
        self.addtop.set(4)
        self.addbottom = tk.IntVar()
        self.addbottom.set(4)
        self.blankbar = tk.Entry(self.botrow, width=4, textvariable=self.addbar)
        self.blankbar.focus_set()
        self.blankbar.select_range(0, "end")
        self.blankbar.grid(padx=10, sticky='')
        self.blanktop = tk.Entry(self.botrow, width=3, textvariable=self.addtop)
        self.blanktop.grid(row=0, column=1, padx=10, sticky='')
        self.blankbottom = tk.Entry(self.botrow, width=5, textvariable=self.addbottom)
        self.blankbottom.grid(row=0, column=2, padx=10, sticky='')

        self.blankaddmeter = tk.Button(self.botrow, text="Add Meter", command=self.newmeter)
        self.blankaddmeter.grid(row=0, column=4, padx=10, rowspan=1)

        self.meterfr.update_idletasks()
        self.meterfr.bind("<Return>", self.ok)
        self.meterfr.bind("<Escape>", self.cancel)

    def newmeter(self):
        number = len(self.metermaybe)
        bar = self.addbar.get()
        top = self.addtop.get()
        bottom = self.addbottom.get()
        if bar > 0 and top > 0 and bottom > 0:
            if bar in (existingmeter.bar for existingmeter in self.metermaybe):
                for existingmline in self.meterlinelist:
                    if bar == existingmline.bar.get():
                        existingmline.top.set(top)
                        existingmline.bottom.set(bottom)
                        existingmline.meter.top = top
                        existingmline.meter.bottom = bottom
                        break
            else:
                newmeter = meter(self.myparent, bar, top, bottom)
#        print bar, top, bottom
                self.addmeterline(newmeter, number)
                self.metermaybe.append(newmeter)
        self.addbar.set(0)
        self.addtop.set(0)
        self.addbottom.set(0)
        self.blankbar.focus_set()

    def addmeterline(self, meter, number):
        newline = meterline(self, meter, meter.bar, meter.top, meter.bottom, number)
        self.meterlinelist.append(newline)
#        self.meterfr.update_idletasks()
#        bottomy = self.toprow.winfo_reqheight()
#        print bottomy
#        self.botrowoncanvas
#        self.meterfr.grid_propagate()
        return newline

    def ok(self, *args):
        self.apply()
        self.cancel()

    def cancel(self, *args):
        self.meterfr.destroy()
        del self.myparent.meterdialog

    def apply(self, *args):
        self.reorder()
        self.myparent.meterlist = copy.deepcopy(self.metermaybe)
        self.myparent.redrawlines()
        for tempo in self.myparent.tempolist:
            tempo.findcsdbeat(self.myparent)

    def reorder(self, *args):
        self.meterlinelist.sort(key=self.sortextract)
        for meterline in self.meterlinelist:
            meterline.number = self.meterlinelist.index(meterline)
            meterline.frame.grid(row=meterline.number, column=0, sticky='ew')
        self.metermaybe = [line.meter for line in self.meterlinelist]
        self.myparent.redrawlines()

    def sortextract(self, item):
        if item.bar.get() != '':
            bar = int(item.bar.get())
        else: bar = '0'
        return bar

class meter:
    def __init__(self, parent, bar, top, bottom):

        self.bar = bar
        self.top = top
        self.bottom = bottom

#        self.findcsdtop(parent)

#    def findcsdtop(self, app):
#        sum = 0
#        if len(app.meterlist):
#            for i in range(len(app.meterlist)):
#                if self.bar > app.meterlist[i].bar.get():
#                    sum += (app.meterlist[i].bar.get() - app.meterlist[i-1].bar.get()) * 4 * float(app.meterlist[i-1].top.get())/float(app.meterlist[i-1].bottom.get())
#                else:
#                    sum += (self.bar - app.meterlist[i-1].bar.get()) * 4 * float(app.meterlist[i-1].top.get())/float(app.meterlist[i-1].bottom.get()) + (self.top - 1) * 4 / app.meterlist[i-1].bottom.get()
#                    break
#        else:
#            sum = 4 * (self.bar - 1) + self.top - 1
##            print self.bar.get(), self.top.get()
#        self.scotop = sum
#        print sum

class meterline:
    def __init__(self, parent, meter, bar, top, bottom, number):
        self.myparent = parent
        self.meter = meter
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
        self.top = tk.IntVar()
        self.top.set(top)
        self.top.trace("w", self.topchange)
        self.toplabel = tk.Label(self.frame, text="Top:")
        self.toplabel.grid(row=0, column=2, padx=4, sticky='e')
        self.topwidget = tk.Control(self.frame, min=1, max=32, width=2, variable=self.top)
        self.topwidget.grid(row=0, column=3, padx=4, sticky='')
        self.bottom = tk.IntVar()
        self.bottom.set(bottom)
        self.bottom.trace("w", self.bottomchange)
        self.bottomlabel = tk.Label(self.frame, text="Bottom:")
        self.bottomlabel.grid(row=0, column=4, padx=4, sticky='e')
        self.bottomwidget = tk.Entry(self.frame, width=4, textvariable=self.bottom)
        self.bottomwidget.grid(row=0, column=5, padx=4)
        self.x = tk.Button(self.frame, text="x", padx=0, pady=0, command=self.remove)
        self.x.grid(row=0, column=6, sticky='e', padx=40)

        self.myparent.meterfr.update_idletasks()
        bottomy = self.myparent.toprow.winfo_reqheight()
#        print bottomy

        self.myparent.canvas.coords(self.myparent.botrowoncanvas, 0, bottomy)
        if self.myparent.scroll.winfo_ismapped():
#            print self.page.scroll.get()
            pass
        else:
            self.myparent.meterfr.update_idletasks()
#            print self.page.scroll.get()
            if self.myparent.scroll.get() != (0.0, 1.0):
                self.myparent.scroll.grid(row=1, column=1, sticky='ns')

        self.myparent.canvas.config(scrollregion=self.myparent.canvas.bbox("all"))
        self.myparent.canvas.yview_moveto(1.0)
        if self.myparent.scroll.winfo_ismapped():
#            print self.page.scroll.get()
            pass
        else:
            self.myparent.meterfr.update_idletasks()
#            print self.page.scroll.get()
            if self.myparent.scroll.get() != (0.0, 1.0):
                self.myparent.scroll.grid(row=0, column=1, sticky='ns')


    def barchange(self, *args):
        self.meter.bar = self.bar.get()

    def topchange(self, *args):
        self.meter.top = self.top.get()

    def bottomchange(self, *args):
        self.meter.bottom = self.bottom.get()

    def remove(self):
        num = self.myparent.meterlinelist.index(self)
        self.frame.destroy()
        for meterline in self.myparent.meterlinelist:
            if meterline.number > num:
                meterline.number -= 1
                meterline.frame.grid(row=meterline.number, column=0, sticky='ew')
        todel1 = self.myparent.metermaybe.pop(num)
        todel2 = self.myparent.meterlinelist.pop(num)
        del todel1
        self.myparent.meterfr.update_idletasks()
        if len(self.myparent.meterlinelist) > 0:
            bottomy = self.myparent.toprow.winfo_reqheight()
        else:
            bottomy=0
        self.myparent.canvas.coords(self.myparent.botrowoncanvas, 0, bottomy)
        
        del todel2

    def lineremove(self, line):
        pass

    def lineadd(self, type):
        pass


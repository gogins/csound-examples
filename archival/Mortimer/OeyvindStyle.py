
import csnd
import threading
import traceback

s = ""

def midiNoteInput(kdata1):
        
    """
    
    Receives realtime midi note on data from csound.
    via pycall opcode
    
    """
    
    a = int(kdata1)
    
    if a == 60:
        
        # play some note or phrase
        s = "i 10 0 2 60"
    
    elif a == 61:
        
        # play some other note or phrase
        s = "i 10 0 2 72"
    
    else:
        
        # do nothing
        s = ""

def csoundThreadRoutine(s):
    
    '''
    
    some stuff i copied & hacked from both
    victors cb.py example
    & the wxController.py example
    
    as ultimately there will be wx components
    introduced, i wanted to make sure
    some token representation
    of any necessary threading capability 
    was in place
    
    '''
    
    cs = csnd.CppSound()
    
    # this to me seems the neatest way to wrap csound code
    cs.Compile("gns003.csd")
    
    # Perform in blocks of ksmps
    performanceThread = csnd.CsoundPerformanceThread(cs)
    
    if s != "":
        
        print s
        performanceThread.InputMessage(s)

    s = ""

csoundThread = threading.Thread(None, csoundThreadRoutine(s))
csoundThread.start()




        
        

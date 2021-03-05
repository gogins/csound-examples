import os
from ctypes import *

# If not null, we have found winmm, which is the Windows Multi Media library.
print windll.winmm
# If not null, we have found this function.
print windll.winmm.waveOutGetNumDevs
# Now actually call the function.
print windll.winmm.waveOutGetNumDevs()
# Do we know the name of this function? Note that we need the ANSI version of the function.
print windll.winmm.waveOutGetDevCapsA
# Define a ctypes structure to get device capabilities.
# This is a Python version of the Windows WAVEOUTCAPS structure,
# which is declared as:
'''
typedef struct { 
    WORD      wMid; 
    WORD      wPid; 
    MMVERSION vDriverVersion; 
    TCHAR     szPname[MAXPNAMELEN]; // we know this is 32
    DWORD     dwFormats; 
    WORD      wChannels; 
    WORD      wReserved1; 
    DWORD     dwSupport; 
} WAVEOUTCAPS; 
'''
class WAVEOUTCAPS(Structure):
    _fields_ = [("wMid", c_ushort),
    ("wPid", c_ushort),
    ("vDriverVersion", c_uint),
    ("szPname", c_char * 32),
    ("dwFormats", c_uint),
    ("wChannels", c_ushort),
    ("wReserved1", c_ushort),
    ("dwSupport", c_uint)]
waveOutCaps = WAVEOUTCAPS()
print waveOutCaps
# How big is it?
print sizeof(waveOutCaps)
print
# Now get the capabilities for all devices.
# -1 is always the default device in Windows.
for device in xrange(-1, windll.winmm.waveOutGetNumDevs()):
    windll.winmm.waveOutGetDevCapsA(device, pointer(waveOutCaps), sizeof(waveOutCaps))
    print "DEVICE:                   ", device
    print "Device product identifier:", waveOutCaps.wPid
    print "Device driver version:    ", waveOutCaps.vDriverVersion
    print "Device name:              ", waveOutCaps.szPname
    print "Device channels:          ", waveOutCaps.wChannels
    # Would need to do OR-ing and AND-ing with symbolic constants to interpret these numbers.
    # All the constants are defined in Windows.h, I think.
    print "Device formats:           ", waveOutCaps.dwFormats
    print "Device support:           ", waveOutCaps.dwSupport
    print


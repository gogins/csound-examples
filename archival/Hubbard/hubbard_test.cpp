#include "CppSound.hpp"

#include <iostream>
#include <string>
#include <cstring>

extern "C" 
{
    // I have no idea why, and Google didn't help,
    // but this function is undefined at the link stage;
    // defining it here produces a program that runs.
    int _get_output_format(void)
    { 
        return 0; 
    } 
}

int main(int argc, char* argv[])
{
	CppSound cppSound;
    // It's always easier to use std::string than char.
    // A string constant in C or C++ can extend over any number of lines, 
    // as long as each line begins and ends with a quotation mark.
	std::string csd = ""
    "<CsoundSynthesizer>\n"
    "<CsOptions>\n"
    "csound -odac test.orc test.sco\n"
    "</CsOptions>\n"
    "<CsInstruments>\n"
    "sr     = 44100\n"
    "ksmps  =   100\n"
    "nchnls =     2\n"
    "0dbfs  =    40.0\n"
    "\n"
    "instr 1\n"
    "iamplitude              =                       dbamp(p5)\n"
    "ifrequency              =                       cpsmidinn(p4)\n"
    "aenvelope               transeg                 1.0, 10.0, -10, 0.0\n"
    "ipluckpoint             =                       .9\n"
    "ipickup                 =                       .1\n" 
    "ireflection             =                       .1\n"
    "asignal                 wgpluck2                ipluckpoint, iamplitude, ifrequency, ipickup, ireflection\n"
    "                        ; Sharp exponential decay.\n"
    "adamping                linsegr                 0, 0.001, 1.0, p3, 1.0, 0.05, 0.0\n"
    "asignal                 =                       asignal * aenvelope * adamping\n"
    "                        outs                    asignal, asignal\n"
    "endin\n"
    "</CsInstruments>\n"
    "<CsScore>\n"
    "i 1 1 5 60 60\n"
    "e\n"
    "</CsScore>\n"
    "</CsoundSynthesizer>\n"
    "";
	cppSound.setCSD(csd);
    // Obviously, it would now be possible to generate a Csound score in code
    // by appending i statements to the score inside cppSound.
	std::cout << cppSound.getCSD() << std::endl;
	cppSound.exportForPerformance();
    // CppSound::perform() internally calls CppSound::compile().
	cppSound.perform();
}

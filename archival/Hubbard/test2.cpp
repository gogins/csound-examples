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
	std::string csd = ""
    "<CsoundSynthesizer>\n"
    "<CsOptions>\n"
    "csound -odac test.orc test.sco\n"
    "</CsOptions>\n"
    "<CsInstruments>\n"
    "sr=44100\n"
    "ksmps=100\n"
    "nchnls=2\n"
    "instr 1\n"
    "endin\n"
    "</CsInstruments>\n"
    "<CsScore>\n"
    "i 1 0 1\n"
    "e\n"
    "</CsScore>\n"
    "</CsoundSynthesizer>\n"
    "";
	cppSound.setCSD(csd);
	std::cout << cppSound.getCSD() << std::endl;
	cppSound.exportForPerformance();
	cppSound.perform();
}

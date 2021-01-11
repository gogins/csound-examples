# csound-examples
![GitHub All Releases (total)](https://img.shields.io/github/downloads/gogins/csound-examples/total.svg)<br>
Michael Gogins<br>
https://github.com/gogins<br>
http://michaelgogins.tumblr.com

## Examples and Tests for Csound

This repository contains example compositions, some test compositions and 
programs, and extensions that can be used with: 
 - The canonical release of [csound](https://github.com/csound/csound): [examples here](https://gogins.github.io/csound-examples/csound-extended-wasm/message.html).
 - My [csound-aeolus](https://github.com/gogins/csound-aeolus) opcodes.
 - [My collection of extensions for Csound including CsoundAC for algorithmic composition](https://github.com/gogins/csound-extended). 
 - My [csound.node](https://github.com/gogins/csound-extended/tree/develop/csound.node) for NW.js.
 - My [csound-extended-wasm](https://github.com/gogins/csound-extended/tree/develop/WebAssembly) including Csound and CsoundAC for WebAssembly. 
 - My [Csound VST3 opcodes](https://github.com/gogins/csound-vst3-opcodes).
 - My [Csound for Android](https://github.com/gogins/csound-android) app.

These pieces are more or less segregated by directories named by programming 
language or Csound runtime environment.

The unit tests used in the canonical build of Csound are _not_ included here.

For more information, please read the examples themselves.

### Getting Started

## WebAssembly

## Other Platforms

Many of these pieces require external dependencies. Depending on the piece, 
these may include:

 - Canonical Csound.
 - My Aeolus opcodes and the Aeolus software organ (Linux).
 - Steel Bank Common Lisp and my nudruz code.
 - My VST3 opcodes for Csound (Linux).
 - Python 3 for 64 bit CPU architeture.
 - A C++ compiler.
 - csound.node and NW.js.
 - A local or remote Web server.
 - A Java development kit.
 - An Android device with 64 bit CPU architecture.
 - Various JavaScript libraries accessed by CDN.
 
For patches and WebAssembly modules, in this repository's root directory, run 
the following shell script to download dependencies:
```
bash update-dependencies.sh
```

That should be enough to get the WebAssembly stuff working with a local Web 
server, which can be run in the csound-extended-wasm directory with:
```
python httpd.py
```

For more information on the other dependencies, consult instructions in the 
respective repository for the runtime environment (csound.node, 
csound-extended-wasm, Csound for Android, etc.).

### Please note!

Not all of these examples or tests actually work. Some are of archival 
interest only.

Many of these examples are included in some of my other Git repositories, 
so please do not rename or move files or directories. 

Please feel free to contribute new pieces, examples, or extensions by pull 
request.
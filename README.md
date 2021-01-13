# csound-examples
![GitHub All Releases (total)](https://img.shields.io/github/downloads/gogins/csound-examples/total.svg)<br>
Michael Gogins<br>
https://github.com/gogins<br>
http://michaelgogins.tumblr.com

## Examples and Tests for Csound

This repository contains example compositions, some test compositions and 
programs, and extensions that can be used with: 
 - The canonical release of [csound](https://github.com/csound/csound).
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

#### Please note!

Not all of these examples or tests actually work. Some are of archival 
interest only.

Please feel free to contribute new pieces, examples, or extensions by pull 
request.

### WebAssembly Examples

Some of the examples herein will run from the [GitHub pages of this 
repository](https://gogins.github.io/csound-examples/). 

Examine `minimal.html` for a bare-bones example of using Csound for 
WebAssembly. Examine `player.html` for an example that uses the 
`csound_loader.js` helper script. These examples have comments that 
discuss all required points of usage.

### Local Examples

To run the examples locally, either clone and build this repository, or 
download the`csound-extended-wasm-version.zip` archive and unpack it.

Then, run the self-contained Web server, `httpd.py`, in the WebAssembly
directory, and navigate in your Web browser to localhost at the port reported
at server startup.

The `cmask.html` example will run with `csound.node` in NW.js 30.2 or later,
and will run with `CsoundAudioNode.js` in Chrome 66 or later, and Firefox 77 
or later.

The `csound_loader.js` script is provided as a convenient method of
detecting and using available implementations of Csound that run in HTML5
environments, including, in decreasing order of preference:

1. Android (using the CsoundAndroid library).
2. CsoundQt (using the built-in JavaScript wrapper).
3. NW.js (using `csound.node`).
4. Current Web browsers (using `CsoundAudioNode.js`).

Many of these pieces require external dependencies. Depending on the piece, 
these may include:

 - Canonical Csound.
 - csound-extended and its WebAssembly modules.
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
 
For more information on the other dependencies, consult instructions in the 
respective repository for the runtime environment (csound.node, 
csound-extended-wasm, Csound for Android, etc.).


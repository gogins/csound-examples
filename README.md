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
 - `archival`, a _haphazard_ directory of _almost all_ the Csound pieces and examples that 
   I have collected from the World Wide Web over many years. _This directory 
   contains many of the Csound pieces or examples I could find online._ In 
   many cases newer versions of the pieces may be found in other repositories (such as the 
   McCurdy examples found in CsoundQt or the examples found in the FLOSS Manual 
   for Csound. I have omitted renderings and larger soundfiles.

These pieces are more or less segregated by directories named by programming 
language or Csound runtime environment.

The unit tests used in the canonical build of Csound are _not_ included here.

For more information, please read the examples themselves.

#### Please note!

Not all of these examples or tests actually work. Some are of archival 
or historical interest only.

I have not secured explicit permission for most of the pieces in the `archival` 
directory. Rather, if they did not come with a license, I have interpreted 
their having been made available by their authors on the Web, or sent in 
emails, as permission to redistribute them. And of course, many of these 
pieces may be found in other places as well, for example in the examples menus 
of the CsoundQt program.

Anyone who finds their work in this repository but would like to have it 
removed, simply notify me, and I will remove it. Also, please notify me if you 
find I am in violation of any copyright.

Please feel free to contribute new pieces, examples, or extensions by pull 
request.

The `csound_loader.js` script is designed to facilitate the use of the Csound 
API in the same way, i.e. calling the same functions for the same results, in 
all environments that provide a JavaScript interface to the Csound API: that 
is, in Csound for Android, the csound-extended-wasm version of Csound for 
WebAssembly, and in csound.node for NW.js.

### WebAssembly Examples

## Important Note

In order for Csound to use audio, the microphone, and MIDI, the user must 
grant these permissions for the site hosting Csound to the Web browser 
(usually by right-clicking on the lock symbol to the left of the URL, or 
on a permissions icon to the left of the URL).

At this time, for reasons not yet known to me, the csound-extended-wasm build 
of Csound does not always run in Google Chrome, even after granting 
permissions. I have opened an issue to fix this.

In the meantime, after granting permissions, everything works fine in 
Firefox.

### Hosted Examples

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


#!/bin/bash
echo "Updating WebAssemby dependencies for csound-examples from the csound-extended repository..."

wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/cmask.js -O csound-extended-wasm/cmask.js
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/cmask.wasm -O csound-extended-wasm/cmask.wasm
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/csound_loader.js -O csound-extended-wasm/csound_loader.js
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/csound_samples.js -O csound-extended-wasm/csound_samples.js
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/CsoundAC.js -O csound-extended-wasm/CsoundAC.js
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/CsoundAudioNode.js -O csound-extended-wasm/CsoundAudioNode.js
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/CsoundAudioProcessor.js -O csound-extended-wasm/CsoundAudioProcessor.js
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/CsoundAudioProcessor.wasm -O csound-extended-wasm/CsoundAudioProcessor.wasm
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/piano-roll.js -O csound-extended-wasm/piano-roll.js

wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/cmask.js -O csound-for-android/Gogins/cmask.js
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/cmask.wasm -O csound-for-android/Gogins/cmask.wasm
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/csound_loader.js -O csound-for-android/Gogins/csound_loader.js
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/csound_samples.js -O csound-for-android/Gogins/csound_samples.js
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/CsoundAC.js -O csound-for-android/Gogins/CsoundAC.js
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/CsoundAudioNode.js -O csound-for-android/Gogins/CsoundAudioNode.js
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/CsoundAudioProcessor.js -O csound-for-android/Gogins/CsoundAudioProcessor.js
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/CsoundAudioProcessor.wasm -O csound-for-android/Gogins/CsoundAudioProcessor.wasm
wget -L https://raw.githubusercontent.com/gogins/csound-extended/develop/docs/piano-roll.js -O csound-for-android/Gogins/piano-roll.js

find . -name "*.js" -ls
find . -name "*.wasm" -ls
echo "Finished updating all WebAssembly dependencies for csound-examples."

#!/bin/bash
echo "Updating WebAssemby dependencies for csound-examples from my home directory..."

cp ~/csound-extended/docs/cmask.js csound-extended-wasm/cmask.js
cp ~/csound-extended/docs/cmask.wasm csound-extended-wasm/cmask.wasm
cp ~/csound-extended/docs/csound_loader.js csound-extended-wasm/csound_loader.js
cp ~/csound-extended/docs/csound_samples.js csound-extended-wasm/csound_samples.js
cp ~/csound-extended/docs/CsoundAC.js csound-extended-wasm/CsoundAC.js
cp ~/csound-extended/docs/CsoundAudioNode.js csound-extended-wasm/CsoundAudioNode.js
cp ~/csound-extended/docs/CsoundAudioProcessor.js csound-extended-wasm/CsoundAudioProcessor.js
cp ~/csound-extended/docs/CsoundAudioProcessor.wasm csound-extended-wasm/CsoundAudioProcessor.wasm
cp ~/csound-extended/docs/piano-roll.js csound-extended-wasm/piano-roll.js

cp ~/csound-extended/docs/cmask.js csound-for-android/Gogins/cmask.js
cp ~/csound-extended/docs/cmask.wasm csound-for-android/Gogins/cmask.wasm
cp ~/csound-extended/docs/csound_loader.js csound-for-android/Gogins/csound_loader.js
cp ~/csound-extended/docs/csound_samples.js csound-for-android/Gogins/csound_samples.js
cp ~/csound-extended/docs/CsoundAC.js csound-for-android/Gogins/CsoundAC.js
cp ~/csound-extended/docs/CsoundAudioNode.js csound-for-android/Gogins/CsoundAudioNode.js
cp ~/csound-extended/docs/CsoundAudioProcessor.js csound-for-android/Gogins/CsoundAudioProcessor.js
cp ~/csound-extended/docs/CsoundAudioProcessor.wasm csound-for-android/Gogins/CsoundAudioProcessor.wasm
cp ~/csound-extended/docs/piano-roll.js csound-for-android/Gogins/piano-roll.js

find . -name "*.js" -ls
find . -name "*.wasm" -ls
echo "Finished updating all WebAssembly dependencies for csound-examples."

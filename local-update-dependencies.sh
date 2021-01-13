#!/bin/bash
echo "Updating WebAssemby dependencies for csound-examples from my home directory..."

cp -rf ~/csound-extended/WebAssembly/dist-wasm/*.aif ./docs/
cp -rf ~/csound-extended/WebAssembly/dist-wasm/*.data ./docs/
cp -rf ~/csound-extended/WebAssembly/dist-wasm/*.inc ./docs/
cp -rf ~/csound-extended/WebAssembly/dist-wasm/*.js ./docs/
cp -rf ~/csound-extended/WebAssembly/dist-wasm/*.map ./docs/
cp -rf ~/csound-extended/WebAssembly/dist-wasm/*.wasm ./docs/

cp -rf ~/csound-extended/WebAssembly/dist-wasm/*.aif ./csound-for-android/Gogins/
cp -rf ~/csound-extended/WebAssembly/dist-wasm/*.data ./csound-for-android/Gogins/
cp -rf ~/csound-extended/WebAssembly/dist-wasm/*.inc ./csound-for-android/Gogins/
cp -rf ~/csound-extended/WebAssembly/dist-wasm/*.js ./csound-for-android/Gogins/
cp -rf ~/csound-extended/WebAssembly/dist-wasm/*.map ./csound-for-android/Gogins/
cp -rf ~/csound-extended/WebAssembly/dist-wasm/*.wasm ./csound-for-android/Gogins/

find . -name "*.js" -ls
find . -name "*.wasm" -ls
echo "Finished updating all WebAssembly dependencies for csound-examples."

#!/bin/bash
echo "Updating WebAssemby dependencies for csound-examples from my home directory..."

cp -rf ~/csound-extended/WebAssembly/csound-extended-wasm-1.1.0/*.aif ./csound-extended-wasm/
cp -rf ~/csound-extended/WebAssembly/csound-extended-wasm-1.1.0/*.data ./csound-extended-wasm/
cp -rf ~/csound-extended/WebAssembly/csound-extended-wasm-1.1.0/*.inc ./csound-extended-wasm/
cp -rf ~/csound-extended/WebAssembly/csound-extended-wasm-1.1.0/*.js ./csound-extended-wasm/
cp -rf ~/csound-extended/WebAssembly/csound-extended-wasm-1.1.0/*.map ./csound-extended-wasm/
cp -rf ~/csound-extended/WebAssembly/csound-extended-wasm-1.1.0/*.wasm ./csound-extended-wasm/

cp -rf ~/csound-extended/WebAssembly/csound-extended-wasm-1.1.0/*.aif ./csound-for-android/Gogins/
cp -rf ~/csound-extended/WebAssembly/csound-extended-wasm-1.1.0/*.data ./csound-for-android/Gogins/
cp -rf ~/csound-extended/WebAssembly/csound-extended-wasm-1.1.0/*.inc ./csound-for-android/Gogins/
cp -rf ~/csound-extended/WebAssembly/csound-extended-wasm-1.1.0/*.js ./csound-for-android/Gogins/
cp -rf ~/csound-extended/WebAssembly/csound-extended-wasm-1.1.0/*.map ./csound-for-android/Gogins/
cp -rf ~/csound-extended/WebAssembly/csound-extended-wasm-1.1.0/*.wasm ./csound-for-android/Gogins/

find . -name "*.js" -ls
find . -name "*.wasm" -ls
echo "Finished updating all WebAssembly dependencies for csound-examples."

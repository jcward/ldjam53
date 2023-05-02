#!/bin/bash

# exit on failure
set -e

rm -rf dist
mkdir -p dist

echo "Compiling Haxe..."
haxe build.hxml

cp html/index.html ./dist/
cp -rf images dist

# Build pixi externs if missing / old
cd lib/pixi
[ node_modules -ot package.json ] && ./build.sh
cd ../..

# build atlases
cd atlas
./build.sh
cd ..
mkdir -p dist/images/atlases/
cp -rf atlas/dist/* dist/images/atlases

# # rsync the images (only copies changed ones)
# rsync -ahv src/images ./dist/

echo "Compiling SCSS..."
sassc scss/style.scss dist/style.css

echo -e "Build \e[42mSUCCESS\e[0m"

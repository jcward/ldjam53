#!/bin/bash

set -e

# npm install if node_modules doesn't exist (first time only)
[[ -d node_modules ]] || yarn install

rm -rf dist
mkdir -p dist
node run_packer.js

#!/bin/bash

set -e

yarn install

yarn run dts2hx pixi.js --noModular

yarn run dts2hx pixi-spine --noModular 2>/dev/null || echo "Ignoring pixi-spine errors - it still works!"

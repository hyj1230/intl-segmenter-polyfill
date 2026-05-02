#!/bin/bash
set -euo pipefail

udocker build . --file Dockerfile.icu -t icu-data

rm -Rf build && mkdir build

udocker run -v "$PWD/build:/opt/mount" --rm "$(udocker images -q icu-data)" cp /artifacts/data.h /opt/mount
cp break_iterator.c icu.py build/
udocker build . --file Dockerfile -t build

udocker run -v "$PWD/src:/opt/mount" --rm "$(udocker images -q build)" cp /artifacts/break_iterator.wasm /opt/mount

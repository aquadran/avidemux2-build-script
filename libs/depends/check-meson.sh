#!/bin/sh

meson --version 1>/dev/null 2>&1 || { echo "ERROR: Install meson before continuing."; exit 1; }

#!/bin/sh

${MAKE:-make} -v 1>/dev/null 2>&1 || { echo "ERROR: Install make before continuing."; exit 1; }

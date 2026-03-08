#!/bin/sh

flex --version 1>/dev/null 2>&1 || { echo "ERROR: Install flex before continuing."; exit 1; }

#!/bin/sh

cd "`dirname $0`" || { echo "ERROR: Could not enter the directory."; exit 1; }

export ADM2_LIBS=${PWD}/target

mkdir -p build && cd build || { echo "ERROR: Could not create the build directory."; exit 1; }

which gmake 1>/dev/null 2>&1 && export MAKE=gmake

DEPEND_SCRIPTS=`ls ../depends/*.sh | sort`

for SCRIPT in $DEPEND_SCRIPTS; do "$SCRIPT" || { echo "$SCRIPT: Failed."; exit 1; } done

BUILD_SCRIPTS=`ls ../scripts/*.sh | sort`

if [ $1 ]; then

  REQUESTS=""

  for STEP in $@; do
    SCRIPT=""
    for i in $BUILD_SCRIPTS; do
      if [ `basename $i | cut -d'-' -f1` -eq $STEP ]; then
        SCRIPT=$i
        break
      fi
    done

    [ -z $SCRIPT ] && { echo "ERROR: unknown step $STEP"; exit 1; }

    REQUESTS="$REQUESTS $SCRIPT"
  done

  BUILD_SCRIPTS="$REQUESTS"
fi

for SCRIPT in $BUILD_SCRIPTS; do "$SCRIPT" || { echo "$SCRIPT: Failed."; exit 1; } done

#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=1.3.7
PKGNAME=xvidcore

if [ ! -f ${PKGNAME}-${VER}.tar.bz2 ]; then wget --continue https://downloads.xvid.com/downloads/${PKGNAME}-${VER}.tar.bz2; fi

rm -Rf ${PKGNAME} && tar xf ${PKGNAME}-${VER}.tar.bz2 && cd ${PKGNAME}/build/generic

if [ -f ../../../../patches/${PKGNAME}.patch ]; then cat ../../../../patches/${PKGNAME}.patch | patch -p1; fi

./configure \
    --prefix="$ADM2_LIBS"

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS && ${MAKE:-make} install

ln -s libxvidcore.4.dylib ${ADM2_LIBS}/lib/libxvidcore.dylib

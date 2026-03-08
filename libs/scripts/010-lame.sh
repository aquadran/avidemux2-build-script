#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=3.100
PKGNAME=lame

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue https://sourceforge.net/projects/lame/files/lame/${VER}/${PKGNAME}-${VER}.tar.gz/download -O ${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.gz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p0; fi

./configure \
    --prefix="$ADM2_LIBS" \
    --disable-gtktest

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS && ${MAKE:-make} install

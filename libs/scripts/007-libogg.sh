#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=1.3.5
PKGNAME=libogg

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue http://downloads.xiph.org/releases/ogg/${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.gz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

./configure \
    --prefix="$ADM2_LIBS"

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS && ${MAKE:-make} install

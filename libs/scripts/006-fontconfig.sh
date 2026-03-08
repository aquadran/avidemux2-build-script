#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=2.16.0
PKGNAME=fontconfig

if [ ! -f ${PKGNAME}-${VER}.tar.xz ]; then wget --continue https://www.freedesktop.org/software/${PKGNAME}/release/${PKGNAME}-${VER}.tar.xz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.xz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

./configure \
    --prefix="$ADM2_LIBS" \
    --disable-silent-rules \
    --enable-shared \
    --disable-static \
    --with-expat="$ADM2_LIBS" \
    HASDOCBOOK=no

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS && ${MAKE:-make} install

#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=0.17.4
PKGNAME=libass

if [ ! -f ${PKGNAME}-${VER}.tar.xz ]; then wget --continue https://github.com/${PKGNAME}/${PKGNAME}/releases/download/${VER}/${PKGNAME}-${VER}.tar.xz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.xz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

./configure \
    --prefix="$ADM2_LIBS" \
    --enable-shared \
    --disable-silent-rules \
    --enable-fontconfig

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS && ${MAKE:-make} install

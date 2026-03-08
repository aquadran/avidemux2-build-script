#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=0.8.0
PKGNAME=a52dec

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue https://distfiles.adelielinux.org/source/${PKGNAME}/${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.gz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p0; fi

CFLAGS=-std=gnu89 \
./configure \
    --prefix="$ADM2_LIBS" \
    --enable-shared \
    --disable-silent-rules \
    --disable-static \
    --disable-double \
    --disable-djbfft \
    --disable-oss \
    --disable-solaris-audio \
    --disable-al-audio \
    --disable-win

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS && ${MAKE:-make} install

#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=3520000
PKGNAME=sqlite

if [ ! -f ${PKGNAME}-${VER}.tar.xz ]; then wget --continue https://www.sqlite.org/2026/${PKGNAME}-autoconf-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-autoconf-${VER} && tar xf ${PKGNAME}-autoconf-${VER}.tar.gz && cd ${PKGNAME}-autoconf-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

AWK=/usr/bin/awk \
./configure \
    --prefix="$ADM2_LIBS" \
    --enable-shared \
    --enable-threadsafe \
    --disable-readline

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS && ${MAKE:-make} install

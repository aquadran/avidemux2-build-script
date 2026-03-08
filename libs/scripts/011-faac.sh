#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=1.31.1
PKGNAME=faac

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue https://github.com/knik0/faac/archive/refs/tags/${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.gz && cd ${PKGNAME}-${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p0; fi

./bootstrap

./configure \
    --prefix="$ADM2_LIBS"

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS && ${MAKE:-make} install

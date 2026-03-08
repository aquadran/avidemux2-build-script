#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=13.0.1
PKGNAME=harfbuzz

if [ ! -f ${PKGNAME}-${VER}.tar.xz ]; then wget --continue https://github.com/harfbuzz/harfbuzz/releases/download/${VER}/${PKGNAME}-${VER}.tar.xz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.xz

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch -d ${PKGNAME}-${VER} | patch -p1; fi

cd ${PKGNAME}-${VER}

mkdir build
meson setup build . \
    -Dprefix="${ADM2_LIBS}" \
    -Dchafa=disabled \
    -Ddocs=disabled \
    -Dcairo=disabled \
    -Dfreetype=enabled \
    -Dglib=disabled \
    -Dgraphite2=disabled \
    -Dicu=disabled

ninja -C build
ninja -C build install

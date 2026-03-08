#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=1.3.1
PKGNAME=zlib

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue https://www.zlib.net/fossils/${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.gz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

./configure \
    --prefix="$ADM2_LIBS"

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS

mkdir -p ${ADM2_LIBS}/include
cp zlib.h ${ADM2_LIBS}/include
cp zconf.h ${ADM2_LIBS}/include
mkdir -p ${ADM2_LIBS}/lib
cp -P *.dylib ${ADM2_LIBS}/lib
mkdir -p ${ADM2_LIBS}/lib/pkgconfig
cp zlib.pc ${ADM2_LIBS}/lib/pkgconfig

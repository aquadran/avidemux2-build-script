#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=2.11.2
PKGNAME=faad2

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue https://github.com/knik0/faad2/archive/refs/tags/${VER}.tar.gz -O ${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.gz

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch -d ${PKGNAME}-${VER} | patch -p0; fi

cd ${PKGNAME}-${VER}

mkdir -p build
cmake -B build -S . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ADM2_LIBS}" \
    -DBUILD_SHARED_LIBS=ON

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
cmake --build build --parallel $PROCS --target install

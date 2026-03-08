#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

REV=288ad69242232a60dac6dca5697cb0154a7f39dc
PKGNAME=aom

if [ ! -d ${PKGNAME} ]; then
    git clone --branch main https://aomedia.googlesource.com/aom ${PKGNAME} && cd ${PKGNAME} && git checkout --force $REV && cd ..
    if [ -f ../patches/${PKGNAME}.patch ]; then cat ../patches/${PKGNAME}.patch | patch -p1 -d ${PKGNAME}; fi
fi

cd ${PKGNAME}

mkdir -p build
cmake -B build -S . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ADM2_LIBS}" \
    -DBUILD_SHARED_LIBS=ON \
    -DENABLE_EXAMPLES=OFF \
    -DENABLE_TESTS=OFF \
    -DENABLE_DOCS=OFF \
    -DAOM_TARGET_CPU=arm64

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
cmake --build build --parallel $PROCS --target install

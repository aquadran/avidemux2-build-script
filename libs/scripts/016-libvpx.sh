#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

REV=9a2d3d1f46afbdfa9b9820a9fd3aacb084e65e2f
PKGNAME=libvpx

if [ ! -d ${PKGNAME} ]; then
    git clone --branch main https://chromium.googlesource.com/webm/libvpx ${PKGNAME} && cd ${PKGNAME} && git checkout --force $REV && cd ..
    if [ -f ../patches/${PKGNAME}.patch ]; then cat ../patches/${PKGNAME}.patch | patch -p1 -d ${PKGNAME}; fi
fi

cd ${PKGNAME}

./configure \
    --prefix="$ADM2_LIBS" \
    --enable-shared \
    --disable-debug-libs \
    --disable-install-docs \
    --disable-examples \
    --enable-experimental \
    --enable-multithread \
    --enable-pic \
    --enable-postproc \
    --disable-unit-tests \
    --enable-vp8 \
    --enable-vp9 \
    --enable-vp9-highbitdepth

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS && ${MAKE:-make} install

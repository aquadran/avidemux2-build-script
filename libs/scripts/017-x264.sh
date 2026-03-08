#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

REV=0480cb05fa188d37ae87e8f4fd8f1aea3711f7ee
PKGNAME=x264

if [ ! -d ${PKGNAME} ]; then
    git clone --branch master https://code.videolan.org/videolan/x264.git ${PKGNAME} && cd ${PKGNAME} && git checkout --force $REV && cd ..
    if [ -f ../patches/${PKGNAME}.patch ]; then cat ../patches/${PKGNAME}.patch | patch -p1 -d ${PKGNAME}; fi
fi

cd ${PKGNAME}

./configure \
    --prefix="$ADM2_LIBS" \
    --enable-shared \
    --enable-pic \
    --disable-avs \
    --disable-swscale \
    --disable-lavf \
    --disable-ffms \
    --disable-gpac \
    --disable-lsmash

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS && ${MAKE:-make} install

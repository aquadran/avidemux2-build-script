#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=2.14.2
PKGNAME=freetype

if [ ! -f ${PKGNAME}-${VER}.tar.xz ]; then wget --continue https://sourceforge.net/projects/freetype/files/freetype2/${VER}/${PKGNAME}-${VER}.tar.xz/download -O ${PKGNAME}-${VER}.tar.xz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.xz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

CFLAGS="-I${ADM2_LIBS}/include" \
LDFLAGS="-L${ADM2_LIBS}/lib" \
ac_cv_prog_AWK=/usr/bin/awk \
./configure \
    --prefix="$ADM2_LIBS" \
    --build="x86_64-apple-darwin" \
    --enable-shared \
    --disable-static \
    --without-harfbuzz \
    --without-brotli \
    --without-librsvg \
    --without-zlib \
    --without-bzip2 \
    --without-png

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS

mkdir -p ${ADM2_LIBS}/include/freetype2/freetype/config
cp include/ft2build.h ${ADM2_LIBS}/include/freetype2
cp include/freetype/*.h ${ADM2_LIBS}/include/freetype2/freetype
cp include/freetype/config/*.h ${ADM2_LIBS}/include/freetype2/freetype/config
mkdir -p ${ADM2_LIBS}/lib
cp -P objs/.libs/*.dylib ${ADM2_LIBS}/lib
install -m 644  builds/unix/freetype2.pc ${ADM2_LIBS}/lib/pkgconfig

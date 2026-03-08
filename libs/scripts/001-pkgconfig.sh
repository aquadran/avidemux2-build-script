#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=0.29.2
PKGNAME=pkg-config

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue https://pkgconfig.freedesktop.org/releases/${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.gz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

PKG_CONFIG=false \
CFLAGS="-Wno-error=int-conversion" \
./configure \
    --prefix="$ADM2_LIBS" \
    --disable-silent-rules \
    --disable-host-tool \
    --with-internal-glib \
    --with-pc-path=${ADM2_LIBS}/lib/pkgconfig

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS

install -d ${ADM2_LIBS}/bin
install -m 755 pkg-config ${ADM2_LIBS}/bin
install -d ${ADM2_LIBS}/share/aclocal
install -m 644 pkg.m4 ${ADM2_LIBS}/share/aclocal

#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

VER=0.26
PKGNAME=gettext

if [ ! -f ${PKGNAME}-${VER}.tar.gz ]; then wget --continue https://ftp.gnu.org/pub/gnu/gettext/${PKGNAME}-${VER}.tar.gz; fi

rm -Rf ${PKGNAME}-${VER} && tar xf ${PKGNAME}-${VER}.tar.gz && cd ${PKGNAME}-${VER}

if [ -f ../../patches/${PKGNAME}.patch ]; then cat ../../patches/${PKGNAME}.patch | patch -p1; fi

export CFLAGS="-Wno-incompatible-function-pointer-types"

ac_cv_prog_AWK=/usr/bin/awk \
ac_cv_path_GMSGFMT=: \
ac_cv_path_GREP=/usr/bin/grep \
ac_cv_path_MSGFMT=: \
ac_cv_path_MSGMERGE=: \
ac_cv_path_SED=/usr/bin/sed \
ac_cv_path_XGETTEXT=: \
am_cv_func_iconv_works=yes \
./configure \
    --prefix="$ADM2_LIBS" \
    --enable-shared \
    --disable-static \
    --without-xz \
    --without-bzip2 \
    --without-git \
    --without-cvs \
    --without-emacs \
    --disable-openmp \
    --disable-libasprintf \
    --without-libunistring \
    --without-libtextstyle \
    --disable-csharp \
    --disable-java

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS

mkdir -p ${ADM2_LIBS}/include
cp gettext-runtime/intl/libintl.h ${ADM2_LIBS}/include
mkdir -p ${ADM2_LIBS}/lib
cp -P gettext-runtime/intl/.libs/*.dylib ${ADM2_LIBS}/lib

#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

REV=b7cdf09167124136d7b6bc9f7aa5ebdc95ed5d61
PKGNAME=mp4v2

if [ ! -d ${PKGNAME} ]; then
    git clone --branch main https://github.com/TechSmith/mp4v2.git ${PKGNAME} && cd ${PKGNAME} && git checkout --force $REV && cd ..
    if [ -f ../patches/${PKGNAME}.patch ]; then cat ../patches/${PKGNAME}.patch | patch -p1 -d ${PKGNAME}; fi
fi

cd ${PKGNAME}

CXXFLAGS=-Wno-narrowing \
./configure \
    --prefix="$ADM2_LIBS" \
    --enable-shared

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
${MAKE:-make} -j $PROCS && ${MAKE:-make} install

#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

REV=d8e6b1a3aa606c450241632b64b703f21ea31ce3
PKGNAME=fdk-aac

if [ ! -d ${PKGNAME} ]; then
    git clone --branch master https://github.com/mstorsjo/fdk-aac.git ${PKGNAME} && cd ${PKGNAME} && git checkout --force $REV && cd ..
    if [ -f ../patches/${PKGNAME}.patch ]; then cat ../patches/${PKGNAME}.patch | patch -p1 -d ${PKGNAME}; fi
fi

cd ${PKGNAME}

mkdir -p build
cmake -B build -S . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ADM2_LIBS}" \
    -DENABLE_SHARED=ON

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
cmake --build build --parallel $PROCS --target install

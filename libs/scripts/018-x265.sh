#!/bin/sh -e

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

REV=419182243fb2e2dfbe91dfc45a51778cf704f849
PKGNAME=x265

if [ ! -d ${PKGNAME} ]; then
    git clone --branch master https://github.com/videolan/x265.git ${PKGNAME} && cd ${PKGNAME} && git checkout --force $REV && cd ..
    if [ -f ../patches/${PKGNAME}.patch ]; then cat ../patches/${PKGNAME}.patch | patch -p1 -d ${PKGNAME}; fi
fi

cd ${PKGNAME}/source

mkdir -p build
cmake -B build -S . \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${ADM2_LIBS}" \
    -DENABLE_SHARED=ON \
    -DHIGH_BIT_DEPTH=ON \
    -DENABLE_CLI=OFF

PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
cmake --build build --parallel $PROCS --target install

#!/bin/bash

REV=8c482973c17c9b007444fc3f67e12b2942506701

if [ ! -d avidemux2 ]; then
    git clone --branch master https://github.com/mean00/avidemux2.git avidemux2 && cd avidemux2 && git checkout --force $REV && cd ..
    patch -p1 -d avidemux2 < patches/case-fs-wa.patch
    patch -p1 -d avidemux2 < patches/qt6-wa.patch
    patch -p1 -d avidemux2 < patches/libs-fixes.patch
fi

BUILDTOP=$PWD
SRCTOP=$PWD/avidemux2

pushd "${SRCTOP}" > /dev/null

export MAJOR=`cat avidemux_core/cmake/avidemuxVersion.cmake | grep "VERSION_MAJOR " | sed 's/..$//g' | sed 's/^.*"//g'`
export MINOR=`cat avidemux_core/cmake/avidemuxVersion.cmake | grep "VERSION_MINOR " | sed 's/..$//g' | sed 's/^.*"//g'`
export PATCH=`cat avidemux_core/cmake/avidemuxVersion.cmake | grep "VERSION_P " | sed 's/..$//g' | sed 's/^.*"//g'`
export API_VERSION="${MAJOR}.${MINOR}"
export ADM_VERSION="${MAJOR}.${MINOR}.${PATCH}"

DAT=`date +"%y%m%d-%Hh%Mm"`
gt=`git log --format=oneline -1 | head -c 11`
REV="${DAT}_$gt"

popd > /dev/null

export SDKROOT=$(xcrun --sdk macosx --show-sdk-path)
export MACOSX_DEPLOYMENT_TARGET=$(xcrun --sdk macosx --show-sdk-version)

EXTRA_CMAKE_DEFS="-DUSE_EXTERNAL_LIBA52=true -DUSE_EXTERNAL_MP4V2=true"
DO_BUNDLE="-DCREATE_BUNDLE=true"

export BASE_INSTALL_DIR="/"
export BASE_APP="${BUILDTOP}/Avidemux${API_VERSION}.app"
export PREFIX="${BASE_APP}/Contents/Resources"
if [ ! -e "${BASE_APP}/Contents/Resources" ] ; then
    mkdir -p "${BASE_APP}/Contents/Resources"
fi

if [ ! -e $PWD/libs/target ]; then cd $PWD/libs; ./build-libs.sh; cd ..; fi

cp -R "$PWD/libs/target/"* "${BASE_APP}/Contents/Resources"

export ADM2_LIBS="${PREFIX}"
export QTDIR="${PREFIX}"
export PATH="${QTDIR}/bin:$PATH"

export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

Process()
{
    BASE=$1
    SOURCEDIR=$2
    EXTRA="$3"
    echo "**************** $1 *******************"
    BUILDDIR="${PWD}/${BASE}"
    PROCS="$(sysctl -n hw.ncpu 2>/dev/null)"
    echo "Building in \"${BUILDDIR}\" from \"${SOURCEDIR}\" with EXTRA=<$EXTRA>"
    rm -Rf "$BUILDDIR"
    mkdir "$BUILDDIR"
    pushd "$BUILDDIR" > /dev/null
    cmake \
        -DCMAKE_OSX_ARCHITECTURES="arm64" \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DCMAKE_PREFIX_PATH="$PREFIX" \
        -DAVIDEMUX_SOURCE_DIR="$SOURCEDIR" \
        -DAVIDEMUX_VERSION="$ADM_VERSION" \
        -DENABLE_QT6=True \
        $EXTRA \
        -G "Unix Makefiles" \
        "$SOURCEDIR"
    ${MAKE:-make} -j $PROCS
    echo "** installing to $PREFIX **"
    ${MAKE:-make} install
    popd > /dev/null
}

Process buildCore "${SRCTOP}/avidemux_core" "-DCREATE_BUNDLE=true"
Process buildQt6 "${SRCTOP}/avidemux/qt4" "-DCREATE_BUNDLE=true"
Process buildCli "${SRCTOP}/avidemux/cli"
Process buildPluginsCommon "${SRCTOP}/avidemux_plugins" "-DPLUGIN_UI=COMMON $EXTRA_CMAKE_DEFS"
Process buildPluginsQt6 "${SRCTOP}/avidemux_plugins" "-DPLUGIN_UI=QT4 $EXTRA_CMAKE_DEFS"
Process buildPluginsCLI "${SRCTOP}/avidemux_plugins" "-DPLUGIN_UI=CLI $EXTRA_CMAKE_DEFS"
Process buildPluginsSettings "${SRCTOP}/avidemux_plugins" "-DPLUGIN_UI=SETTINGS $EXTRA_CMAKE_DEFS"


mkdir "${PREFIX}/fonts"
cp "${SRCTOP}/avidemux/qt4/cmake/osx/fonts.conf" "${PREFIX}/fonts"
cp "${SRCTOP}"/avidemux/qt4/cmake/osx/*.icns "${PREFIX}"
mkdir -p "${PREFIX}"/../MacOS
if [ -d "${PREFIX}"/../PlugIns ]; then
    rm -Rf "${PREFIX}"/../PlugIns
fi
mkdir -p "${PREFIX}"/../PlugIns
if [ -e "${PREFIX}"/../lib ]; then
    rm "${PREFIX}"/../lib
fi
ln -s "${PREFIX}/lib" "${PREFIX}"/../
ln -s "${QTDIR}/share/qt/plugins/platforms" "${PREFIX}"/../PlugIns/
ln -s "${QTDIR}/share/qt/plugins/styles" "${PREFIX}"/../PlugIns/
echo "[Paths]" > "${PREFIX}"/../Resources/qt.conf
echo "Plugins = PlugIns" >> "${PREFIX}"/../Resources/qt.conf
if [ -e installer ]; then
    chmod -R +w installer
    rm -Rf installer
fi

mkdir -p installer
cd installer
cmake \
    -DAVIDEMUX_VERSION="$ADM_VERSION" \
    -DAVIDEMUX_MAJOR_MINOR="${MAJOR}.${MINOR}" \
    -DBUILD_REV="$REV" \
    -DENABLE_QT6=True \
    "${SRCTOP}/avidemux/osxInstaller"
make package

#!/bin/bash

ADM2_LIBS=${ADM2_LIBS:=$(PWD)/../target}

PATH=${ADM2_LIBS}/bin:${PATH}

QT_VERSION=6.9.3
QT_VERSION_BASE=`echo $QT_VERSION | cut -d'.' -f 1,2`

if [ ! -f "qt-everywhere-src-$QT_VERSION.tar.xz" ]; then
	wget https://download.qt.io/archive/qt/$QT_VERSION_BASE/$QT_VERSION/single/qt-everywhere-src-$QT_VERSION.tar.xz
	if [ $? != 0 ]; then
		echo "ERROR: Failed to download Qt sources!"
		exit 1
	fi
fi

if [ ! -d "qt-everywhere-src-$QT_VERSION" ]; then
	tar xf qt-everywhere-src-$QT_VERSION.tar.xz
	if [ $? != 0 ]; then
		echo "ERROR: Failed to unpack Qt archive!"
		exit 1
	fi
	pushd qt-everywhere-src-$QT_VERSION
	rm qtbase/cmake/FindWrapZSTD.cmake
	touch qtbase/cmake/FindWrapZSTD.cmake
	#cat ../patches/patch | patch -p1
	popd
fi

OPTS="\
-Wno-dev --log-level=STATUS -G Ninja \
-DINPUT_pcre=qt -DINPUT_libpng=qt -DINPUT_libjpeg=qt -DINPUT_doubleconversion=qt \
-DINPUT_harfbuzz=qt -DFEATURE_dbus=ON -DFEATURE_icu=OFF \
-DFEATURE_gif=OFF -DFEATURE_ico=OFF -DFEATURE_eglfs=OFF -DFEATURE_gbm=OFF -DFEATURE_tiff=OFF \
-DFEATURE_webp=OFF -DFEATURE_journald=OFF -DFEATURE_syslog=OFF -DFEATURE_testlib=OFF \
-DFEATURE_printsupport=OFF -DFEATURE_slog2=OFF -DFEATURE_opengl=ON -DFEATURE_concurrent=OFF \
-DFEATURE_sql=OFF -DFEATURE_xml=OFF \
-DQT_QMAKE_TARGET_MKSPEC=macx-clang -DFEATURE_glib=OFF \
-DQT_BUILD_TESTS=OFF -DQT_BUILD_EXAMPLES=OFF \
-DBUILD_qt3d=OFF -DBUILD_qt5compat=OFF -DBUILD_qtactiveqt=OFF -DBUILD_qtcoap=OFF -DBUILD_qtcharts=OFF \
-DBUILD_qtconnectivity=OFF -DBUILD_qtdatavis3d=OFF -DBUILD_qtdeclarative=OFF -DBUILD_qtdoc=OFF \
-DBUILD_qtgrpc=OFF -DBUILD_qtgraphs=OFF -DBUILD_qthttpserver=OFF \
-DBUILD_qttools=ON -DBUILD_qtlocation=OFF -DBUILD_qtlottie=OFF -DBUILD_qtmqtt=OFF -DBUILD_qtmultimedia=OFF \
-DBUILD_qtnetworkauth=OFF -DBUILD_qtopcua=OFF -DBUILD_qtpositioning=OFF -DBUILD_qtquick3d=OFF \
-DBUILD_qtquick3dphysics=OFF -DBUILD_qtquickeffectmaker=OFF -DBUILD_qtquicktimeline=OFF \
-DBUILD_qtremoteobjects=OFF -DBUILD_qtscxml=OFF -DBUILD_qtsensors=OFF -DBUILD_qtserialbus=OFF \
-DBUILD_qtserialport=OFF -DBUILD_qtshadertools=OFF -DBUILD_qtspeech=OFF -DBUILD_qtsvg=OFF \
-DBUILD_qttools=OFF -DBUILD_qttranslations=OFF -DBUILD_qtvirtualkeyboard=OFF -DBUILD_qtwayland=OFF \
-DBUILD_qtwebchannel=OFF -DBUILD_qtwebengine=OFF -DBUILD_qtwebsockets=OFF -DBUILD_qtwebview=OFF \
"

NUM_THREADS="$(sysctl -n hw.ncpu 2>/dev/null)"

pushd qt-everywhere-src-$QT_VERSION
./configure -- $OPTS -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${ADM2_LIBS} && cmake --build . --parallel $NUM_THREADS && cmake --install .
popd

#!/bin/bash
# build.sh
# 
# libxml2-2.7.8_ios6
# 
# Build thread safe libxml2 for iOS 7.1 with Xcode 6.1 and iOS SDK 8.1
# 
# Reference
# http://coin-c.tumblr.com/post/18063869172/thread-safe-xmllib2
# http://pastie.org/3429938
# https://github.com/ashtons/libtiff-ios/blob/master/build-png.sh
# https://github.com/gali8/Tesseract-OCR-iOS/blob/master/TesseractOCR/build_dependencies.sh
#
IOS_BASE_SDK="8.1"
IOS_DEPLOY_TGT="7.1"

LIB_NAME="libxml2"
LIB_ZIP="`pwd`/libxml2-2.7.8.tar.gz"
LIB_DIR="`pwd`/libxml2-2.7.8"
BUILD_DIR="`pwd`/libxml2-2.7.8/build"
BUILD_LIB_DIR="`pwd`/libxml2-2.7.8/build/include/libxml2/libxml"
LOG_DIR="`pwd`/log"

CONFIGURE_OPTIONS="--with-zlib --with-modules --with-valid --with-tree --with-xpath --with-xptr --with-modules --with-reader --with-regexps --with-schemas --with-html --with-iconv --with-threads"

build()
{
	ARCH=$1
	ARCH_HOST=$2
	
	make clean > /dev/null 2> /dev/null
	make distclean > /dev/null 2> /dev/null
	unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS
	
	mkdir -p $BUILD_DIR/$ARCH
	
	case "$ARCH" in
		"armv7" | "armv7s" | "arm64")
		 	export DEVROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer"
			export SDKROOT="$DEVROOT/SDKs/iPhoneOS$IOS_BASE_SDK.sdk"
			;;
		"i386" | "x86_64")
		 	export DEVROOT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer"
			export SDKROOT="$DEVROOT/SDKs/iPhoneSimulator$IOS_BASE_SDK.sdk"
			;;
	esac
	
	export CFLAGS="-arch $ARCH -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$IOS_DEPLOY_TGT -I$SDKROOT/usr/include/ -I$BUILD_DIR/include -L$BUILD_DIR/lib"
	
	export CXX=`xcrun -find -sdk iphoneos clang++`
	export CC=`xcrun -find -sdk iphoneos clang`
	export LD=`xcrun -find -sdk iphoneos ld`
	export AR=`xcrun -find -sdk iphoneos ar`
	export AS=`xcrun -find -sdk iphoneos as`
	export NM=`xcrun -find -sdk iphoneos nm`
	export RANLIB=`xcrun -find -sdk iphoneos ranlib`
	export LDFLAGS="-L$SDKROOT/usr/lib/ -L$OUTDIR/lib -lz"
	export CPPFLAGS=$CFLAGS
	export CXXFLAGS=$CFLAGS
	
	CONFIGURE_LOGFILE=$LOG_DIR/$ARCH"_configure.log"
	CONFIGURE_ERROR_LOGFILE=$LOG_DIR/$ARCH"_configure-error.log"
	MAKE_LOGFILE=$LOG_DIR/$ARCH"_make.log"
	MAKE_ERROR_LOGFILE=$LOG_DIR/$ARCH"_make-error.log"
	MAKE_INSTALL_LOGFILE=$LOG_DIR/$ARCH"_make-install.log"
	MAKE_INSTALL_ERROR_LOGFILE=$LOG_DIR/$ARCH"_make-install-error.log"
	
	echo ""
	echo "======================"
	echo "BUILD $ARCH"
	echo "======================"
	echo "ARCH:		"$ARCH
	echo "ARCH_HOST:	"$ARCH_HOST
	echo "IOS_BASE_SDK:	"$IOS_BASE_SDK
	echo "IOS_DEPLOY_TGT:	"$IOS_DEPLOY_TGT
	echo "LIB_DIR:	"$LIB_DIR
	echo "BUILD_DIR:	"$BUILD_DIR
	echo "DEVROOT:	"$DEVROOT
	echo "SDKROOT:	"$SDKROOT
	echo "CFLAGS:		"$CFLAGS
	echo "CC:		"$CC
	echo "CXX:		"$CXX
	echo "AR:		"$AR
	echo "AS:		"$AS
	echo "LD:		"$LD
	echo "NM:		"$NM
	echo ""
	echo "./configure --host=${ARCH_HOST} --enable-shared=no $CONFIGURE_OPTIONS --prefix $BUILD_DIR > $CONFIGURE_LOGFILE 2> $CONFIGURE_ERROR_LOGFILE"
	
	./configure --host=${ARCH_HOST} --enable-shared=no $CONFIGURE_OPTIONS --prefix $BUILD_DIR > $CONFIGURE_LOGFILE 2> $CONFIGURE_ERROR_LOGFILE
	
	make > $MAKE_LOGFILE 2> $MAKE_ERROR_LOGFILE
	make install > $MAKE_INSTALL_LOGFILE 2> $MAKE_INSTALL_ERROR_LOGFILE
	
	mv $BUILD_DIR/lib/$LIB_NAME.a $BUILD_DIR/$LIB_NAME-$ARCH.a
}

merge_libraries()
{
	echo ""
	echo "======================"
	echo "MERGE LIBRARIES"
	echo "======================"
	echo "xcrun -sdk iphoneos lipo \\"
	echo "-arch armv7 $BUILD_DIR/$LIB_NAME-armv7.a \\"
	echo "-arch armv7s $BUILD_DIR/$LIB_NAME-armv7s.a \\"
	echo "-arch arm64 $BUILD_DIR/$LIB_NAME-arm64.a \\"
	echo "-arch i386 $BUILD_DIR/$LIB_NAME-i386.a \\"
	echo "-arch x86_64 $BUILD_DIR/$LIB_NAME-x86_64.a \\"
	echo "-create -output $BUILD_DIR/$LIB_NAME.a"
	echo ""

	xcrun -sdk iphoneos lipo \
	-arch armv7 $BUILD_DIR/$LIB_NAME-armv7.a \
	-arch armv7s $BUILD_DIR/$LIB_NAME-armv7s.a \
	-arch arm64 $BUILD_DIR/$LIB_NAME-arm64.a \
	-arch i386 $BUILD_DIR/$LIB_NAME-i386.a \
	-arch x86_64 $BUILD_DIR/$LIB_NAME-x86_64.a \
	-create -output $BUILD_DIR/$LIB_NAME.a
}

build_all()
{
	rm -rf $LOG_DIR
	rm -rf $LIB_DIR
	rm -rf $LIB_NAME.a
	rm -rf libxml 
	
	tar zxf $LIB_ZIP
	
	mkdir $LOG_DIR
	mkdir $BUILD_DIR
	cd $LIB_DIR
	
	build "armv7" "arm-apple-darwin7"
	build "armv7s" "arm-apple-darwin7s"
	build "arm64" "arm-apple-darwin8"
	build "i386" "i386-apple-darwin"
	build "x86_64" "x86_64-apple-darwin"
	
	merge_libraries
	
	cd ../
	cp -rf $BUILD_DIR/$LIB_NAME.a ./
	cp -rf $BUILD_LIB_DIR ./
}

build_all

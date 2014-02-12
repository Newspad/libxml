#!/bin/bash
# build.sh
# 
# libxml2-2.7.8_ios6
# 
# Build thread safe libxml2 for iOS 6
# 
# 1) Download libxml2-2.7.8
#	 ftp://xmlsoft.org/libxml2/libxml2-2.7.8.tar.gz
# 2) Run build.sh in unzipped libxml2-2.7.8 directory
# 3) Copy libxml2.a and header files to your project directory
# 4) Add Header Search Path
#	 Example: $(SRCROOT)/Submodules/libxml2-2.7.8_ios6
# 
# Reference
# http://coin-c.tumblr.com/post/18063869172/thread-safe-xmllib2
# http://pastie.org/3429938
#

LIB_NAME="libxml2"

GLOBAL_OUTDIR="`pwd`/build"
LOCAL_OUTDIR="`pwd`/build"

CONFIGURE_OPTIONS="--with-zlib --with-modules --with-valid --with-tree --with-xpath --with-xptr --with-modules --with-reader --with-regexps --with-schemas --with-html --with-iconv --with-threads"

build()
{
	arg_arch=$1
	arg_host=$2
	arg_ios_base_sdk=$3
	arg_ios_deploy_tgt=$4
	arg_xcode_ver=$5
	if [ $arg_xcode_ver -lt 5 ]; then
		arg_xcode="Xcode4.6.3.app"
	else
		arg_xcode="Xcode.app"
	fi
	
	make clean 2> /dev/null
	make distclean 2> /dev/null
	
	mkdir -p $LOCAL_OUTDIR/$arg_arch
	
	unset DEVROOT SDKROOT CFLAGS CC LD CPP CXX AR AS NM CXXCPP RANLIB LDFLAGS CPPFLAGS CXXFLAGS
	
 	export DEVROOT="/Applications/$arg_xcode/Contents/Developer/Platforms/iPhoneOS.platform/Developer"
	export SDKROOT="$DEVROOT/SDKs/iPhoneOS$arg_ios_base_sdk.sdk"
	
	export CFLAGS="-arch $arg_arch -pipe -no-cpp-precomp -isysroot $SDKROOT -miphoneos-version-min=$arg_ios_deploy_tgt -I$SDKROOT/usr/include/ -I$GLOBAL_OUTDIR/include -L$GLOBAL_OUTDIR/lib"
	
	case "$arg_arch" in
		"armv7" | "armv7s" | "i386")
			export CC="$DEVROOT/usr/bin/llvm-gcc"
			export CXX="$DEVROOT/usr/bin/llvm-g++"
			;;
		"arm64")
			export CC="`xcrun -find -sdk iphoneos clang`"
			export CXX="`xcrun -find -sdk iphoneos clang++`"
# 			export CC="`xcrun -find -sdk iphoneos gcc`"
# 			export CXX="`xcrun -find -sdk iphoneos g++`"
			;;
		"x86_64")
			export CC="`xcrun -find -sdk iphoneos clang`"
			export CXX="`xcrun -find -sdk iphoneos clang++`"
# 			export CC="$DEVROOT/usr/bin/gcc"
# 			export CXX="$DEVROOT/usr/bin/g++"
			;;
	esac

	export LD=$DEVROOT/usr/bin/ld
	export AR=$DEVROOT/usr/bin/ar
	export AS=$DEVROOT/usr/bin/as
	export NM=$DEVROOT/usr/bin/nm
	
	export RANLIB=$DEVROOT/usr/bin/ranlib
	export LDFLAGS="-L$SDKROOT/usr/lib/"
	
	export CPPFLAGS=$CFLAGS
	export CXXFLAGS=$CFLAGS
	
	
	echo -e "\\n\\n\\n\\n\\n\\n\\n\\nbuild "$arg_arch"\\n"
	echo "DEVROOT="$DEVROOT
	echo "SDKROOT="$SDKROOT
	echo "CFLAGS="$CFLAGS
	echo "CC="$CC
	echo "CXX="$CXX
	echo "LD="$LD
	echo "AR="$AR
	echo "AS="$AS
	echo "NM="$NM
	echo ""
	
	./configure --host=${arg_host} --enable-shared=no ${CONFIGURE_OPTIONS} --prefix $LOCAL_OUTDIR
	
	make; make install
	
	mv build/lib/$LIB_NAME.a $LIB_NAME-$arg_arch.a
}

rm -rf $LOCAL_OUTDIR; mkdir $LOCAL_OUTDIR

# build "armv7" "arm-apple-darwin7" "6.1" "6.0" 4
# build "armv7s" "arm-apple-darwin7s" "6.1" "6.0" 4 
# build "arm64" "arm-apple-darwin8" "7.0" "7.0" 5
build "i386" "i386-apple-darwin" "6.1" "6.0" 4
build "x86_64" "x86_64-apple-darwin" "7.0" "6.0" 5

echo -e "\\n\\n\\n\\n\\n\\n\\n\\nbuild all"
xcrun -sdk iphoneos lipo -arch armv7 $LIB_NAME-armv7.a -arch armv7s $LIB_NAME-armv7s.a -arch arm64 $LIB_NAME-arm64.a -arch x86_64 $LIB_NAME-x86_64.a -create -output build/$LIB_NAME.a








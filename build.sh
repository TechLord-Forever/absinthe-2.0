#!/bin/bash

if [ "x$1" = "xclean" ]; then
  rm -f build
  make clean
fi

if ! test -f configure; then
    ./autogen.sh
fi

do_linux_x86_64=no
do_osx_10_5=no

case `uname` in
	Darwin*)
	rm -f absinthe-10.5
	if test -d "/Developer/SDKs/MacOSX10.5.sdk"; then
		do_osx_10_5=yes
	fi
	;;
	MINGW*)
	windres resources/win32/res.rc -O coff gui/win32res.o
	;;
	Linux*)
	rm -f absinthe.x86_64 absinthe-cli.x86_64
	if [ "x`uname -p`" = "xx86_64" ]; then
		do_linux_x86_64=yes
	else
		./autogen.sh
		make clean
	fi
	;;
esac

rm -rf build

if [ "x$do_osx_10_5" = "xyes" ]; then
  BUILD_10_5=1 ./autogen.sh
  make clean
  if ! make; then
    exit 1
  fi
  cp gui/absinthe absinthe-10.5
  cp src/absinthe absinthe-cli-10.5
  make clean
  ./autogen.sh
fi

if [ "x$do_linux_x86_64" = "xyes" ]; then
  echo Building x86_64...
  BUILD_HOST_CPU=x86_64 ./autogen.sh
  make clean
  if ! make; then
    exit 1
  fi
  cp gui/absinthe absinthe.x86_64
  cp src/absinthe absinthe-cli.x86_64
  make clean
  ./autogen.sh
fi

if ! make; then
  exit 1
fi

CLIDEST=build/absinthe/cli
GUIDEST=build/absinthe/gui

mkdir -p $CLIDEST
mkdir -p $GUIDEST

case `uname` in
	Darwin)
	OSX_BUNDLE_NAME=Absinthe
	cp src/absinthe build/absinthe/cli/
	mkdir -p $GUIDEST/${OSX_BUNDLE_NAME}.app/Contents/MacOS
	mkdir -p $GUIDEST/${OSX_BUNDLE_NAME}.app/Contents/Resources
	echo "APPL????" > $GUIDEST/${OSX_BUNDLE_NAME}.app/Contents/PkgInfo
	cp resources/osx/Info.plist $GUIDEST/${OSX_BUNDLE_NAME}.app/Contents/
	cp resources/osx/Icon.icns $GUIDEST/${OSX_BUNDLE_NAME}.app/Contents/Resources/
	GUIDEST=$GUIDEST/${OSX_BUNDLE_NAME}.app/Contents/MacOS
	if test -f absinthe-10.5; then
		cp gui/absinthe $GUIDEST/${OSX_BUNDLE_NAME}-10.6
		cp absinthe-10.5 $GUIDEST/${OSX_BUNDLE_NAME}-10.5
		cp resources/osx/Absinthe-launcher.sh $GUIDEST/${OSX_BUNDLE_NAME}
		chmod 755 $GUIDEST/${OSX_BUNDLE_NAME}
	else
		cp gui/absinthe $GUIDEST/${OSX_BUNDLE_NAME}
	fi
	# if running as root required:
	#cp gui/absinthe $GUIDEST/${OSX_BUNDLE_NAME}_
	#cp resources/osx/launcher $GUIDEST/${OSX_BUNDLE_NAME}
	;;
	Linux)
	cp src/absinthe $CLIDEST/
	if test -f absinthe-cli.x86_64; then
 		cp absinthe-cli.x86_64 $CLIDEST/absinthe.x86_64
	fi
	if test -f absinthe.x86_64; then
		cp gui/absinthe $GUIDEST/absinthe.x86
		cp absinthe.x86_64 $GUIDEST/
		cp resources/linux/absinthe-launcher.sh $GUIDEST/absinthe
		chmod 755 $GUIDEST/absinthe
	else
		cp gui/absinthe $GUIDEST/
	fi
	mkdir -p $GUIDEST/data
	cp resources/linux/icon.png $GUIDEST/data/
	;;
	MINGW*)
	cp src/absinthe.exe $CLIDEST/
	cp gui/absinthe.exe $GUIDEST/
	;;
esac

mkdir -p $CLIDEST/data/common/corona
mkdir -p $GUIDEST/data/common/corona

# common files
cp data/common/webclip_icon*.png $CLIDEST/data/common/
cp data/common/webclip_Info.plist $CLIDEST/data/common/
cp data/common/webclip_icon*.png $GUIDEST/data/common/
cp data/common/webclip_Info.plist $GUIDEST/data/common/

cp -r data/common/corona $CLIDEST/data/common/
cp -r data/common/corona $GUIDEST/data/common/

cp iOS/cleanup/cleanup $CLIDEST/data/common/corona/
cp iOS/filemover/filemover $CLIDEST/data/common/corona/
cp iOS/filemover/filemover.plist $CLIDEST/data/common/corona/
cp iOS/cleanup/cleanup $GUIDEST/data/common/corona/
cp iOS/filemover/filemover $GUIDEST/data/common/corona/
cp iOS/filemover/filemover.plist $GUIDEST/data/common/corona/


# device specific files

function devfiles()
{
  for I in data/$1/*; do
    mkdir -p $CLIDEST/$I
    mkdir -p $GUIDEST/$I
    cp -r $I/corona $CLIDEST/$I/
    cp -r $I/corona $GUIDEST/$I/
    cp -r $I/fsgen $CLIDEST/$I/
    cp -r $I/fsgen $GUIDEST/$I/
  done
}

devfiles 9A334
devfiles 9A405
devfiles 9A406


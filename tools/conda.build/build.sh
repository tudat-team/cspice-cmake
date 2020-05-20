#!/usr/bin/env bash

mkdir build
cd build

#INCLUDE_PATH="${PREFIX}/include"
#LIBRARY_PATH="${PREFIX}/lib"

# Always build PIC code for enable static linking into other shared libraries
#CXXFLAGS="${CXXFLAGS} -fPIC"

#if [ "$(uname)" == "Darwin" ]; then
#    TOOLSET=clang
#elif [ "$(uname)" == "Linux" ]; then
#    TOOLSET=gcc
#fi

#LINKFLAGS="${LINKFLAGS} -L${LIBRARY_PATH}"

#if [[ "$(uname)" == "Darwin" ]]; then
#    export ENABLE_TESTS=no
#else
#    LDFLAGS="-lrt ${LDFLAGS}"
#    export ENABLE_TESTS=yes
#fi

cmake \
    -DCMAKE_CXX_STANDARD=17 \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    ..

make -j16

#ctest

make install
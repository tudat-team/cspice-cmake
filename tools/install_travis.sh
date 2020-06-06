#!/usr/bin/env bash

# Echo each command
set -x

# Exit on error.
set -e

export deps_dir=$HOME/local
export PATH="$HOME/miniconda/bin:$PATH"
export PATH="$deps_dir/bin:$PATH"

if [[ "${BUILD_TYPE}" == "OSXDebug" ]]; then
    CXX=clang++ CC=clang cmake -DCMAKE_PREFIX_PATH=$deps_dir -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS_DEBUG="-g0 -Os" ../;
    make -j2 VERBOSE=1;
    ctest -VV;

    cd ..
    mkdir build_static
    cd build_static

    CXX=clang++ CC=clang cmake -DCMAKE_PREFIX_PATH=$deps_dir -DCMAKE_BUILD_TYPE=Debug -DCSPICE_BUILD_STATIC_LIBRARY=yes  ../; #-DCMAKE_CXX_FLAGS_DEBUG="-g0 -Os"
    make -j2 VERBOSE=1;
    ctest -VV;
elif [[ "${BUILD_TYPE}" == "OSXRelease" ]]; then
    CXX=clang++ CC=clang cmake -DCMAKE_PREFIX_PATH=$deps_dir -DCMAKE_BUILD_TYPE=Release ../;
    make -j2 VERBOSE=1;
    ctest -VV;
fi

set +e
set +x
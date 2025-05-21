#!/bin/bash -eu

# 1. Build libqrencode
cd $SRC/libqrencode
./autogen.sh
./configure --disable-shared
make -j$(nproc)

# 2. Build fuzzers
$CC $CFLAGS -I. -c $SRC/qrencode_fuzzer.c -o $SRC/qrencode_fuzzer.o
$CXX $CXXFLAGS -o $OUT/qrencode_fuzzer $SRC/qrencode_fuzzer.o \
    -L$SRC/libqrencode/.libs -lqrencode \
    $LIB_FUZZING_ENGINE

#!/bin/bash -eu

# libtiff ソースディレクトリに移動
cd $SRC/libtiff

# autoconf 系ビルド
./autogen.sh
./configure
make -j$(nproc)

# Fuzzerのソース（自作したものを使う）
FUZZER_SRC=$SRC/libtiff/tools/tiffcp_fuzzer.cc

# libFuzzer付きでFuzzerバイナリを生成
$CXX $CXXFLAGS -std=c++11 -I. -Ilibtiff \
  $FUZZER_SRC -o $OUT/tiffcp_fuzzer \
  $LIB_FUZZING_ENGINE libtiff/.libs/libtiff.a

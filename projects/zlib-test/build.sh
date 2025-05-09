#!/bin/bash -eu
# Copyright 2016 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

cd $SRC/zlib

# 1. abort() を挿入する
echo "[INFO] Patching deflate.c"
sed -i '/if *(.*s->level.*)/s/{/{ if (strm->avail_in > 0) abort();/' deflate.c

# 2. 確認ログ
echo "==== PATCHED deflate.c HEAD ===="
if ! grep 'abort' deflate.c; then
    echo "[ERROR] Patch not applied"
    echo "Showing first 20 lines of deflate.c:"
    head -n 20 deflate.c
fi

# 3. ビルド
./configure
make -j$(nproc) clean
make -j$(nproc) all
make -j$(nproc) check

for f in $(find $SRC -name '*_fuzzer.cc'); do
    b=$(basename -s .cc $f)
    $CXX $CXXFLAGS -std=c++11 -I. $f -o $OUT/$b $LIB_FUZZING_ENGINE ./libz.a
done

zip $OUT/seed_corpus.zip *.*

for f in $(find $SRC -name '*_fuzzer.c'); do
    b=$(basename -s .c $f)
    $CC $CFLAGS -I. $f -c -o /tmp/$b.o
    $CXX $CXXFLAGS -o $OUT/$b /tmp/$b.o -stdlib=libc++ $LIB_FUZZING_ENGINE ./libz.a
    rm -f /tmp/$b.o
    ln -sf $OUT/seed_corpus.zip $OUT/${b}_seed_corpus.zip
done

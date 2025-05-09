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

# # 1. 故意のバグを挿入
# echo "[INFO] Inserting abort() into deflate()"
# # abort(); を deflate() の本体直前に強制挿入
# sed -i '/deflate(z_streamp strm, int flush)/a\
#   abort();
# ' deflate.c

# # パッチ確認ログ
# echo "==== CHECK deflate.c ===="
# grep -A5 'deflate(z_streamp strm, int flush)' deflate.c


# 2. ビルド
./configure
make -j$(nproc)
# make -j$(nproc) clean
# make -j$(nproc) all
# make -j$(nproc) check

# 3. Fuzzer ビルド
for f in $(find $SRC -name '*_fuzzer.c'); do
    b=$(basename -s .c $f)
    $CC $CFLAGS -I. $f -c -o /tmp/$b.o
    $CXX $CXXFLAGS -o $OUT/$b /tmp/$b.o -stdlib=libc++ $LIB_FUZZING_ENGINE ./libz.a
    rm -f /tmp/$b.o
    ln -sf $OUT/seed_corpus.zip $OUT/${b}_seed_corpus.zip
done

# 4. Seed Corpus
zip $OUT/seed_corpus.zip *.*

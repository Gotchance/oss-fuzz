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

FROM gcr.io/oss-fuzz-base/base-builder
RUN apt-get update && apt-get install -y make autoconf automake libtool
# 最新の develop ブランチをクローン（任意で固定バージョンにしてもOK）
RUN git clone --depth 1 -b develop https://github.com/madler/zlib.git
# 作業ディレクトリを zlib に設定
WORKDIR zlib

# 🔧 deflate() 関数に abort(); を挿入（確実に反映させる）
RUN sed -i '/deflate(z_streamp strm, int flush)/a\
  abort();' deflate.c \
  && echo "==== Confirm inserted abort() ====" \
  && grep -A5 'deflate(z_streamp strm, int flush)' deflate.c

# OSS-Fuzzが使うビルドスクリプトやfuzzerをコピー
COPY build.sh *_fuzzer.c* $SRC/

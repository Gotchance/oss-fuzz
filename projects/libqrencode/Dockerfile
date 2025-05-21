# Dockerfile for libqrencode fuzzing
FROM gcr.io/oss-fuzz-base/base-builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    libtool \
    pkg-config

# Clone the libqrencode repository
RUN git clone https://github.com/fukuchi/libqrencode.git

# Set working directory for build.sh
WORKDIR /src/libqrencode

# Copy build script and fuzz target
COPY build.sh $SRC/
COPY qrencode_fuzzer.c $SRC/

#!/bin/bash

PREFIX=/opt/local/toolchain
mkdir ~/toolchain
pushd ~/toolchain
git clone https://github.com/tpoechtrager/cctools-port.git
git clone https://github.com/tpoechtrager/apple-libtapi.git

pushd apple-libtapi
sudo mkdir -p $PREFIX
INSTALLPREFIX=$PREFIX ./build.sh
sudo ./install.sh
popd

pushd cctools-port/cctools/
CC=/usr/bin/clang-10 CXX=/usr/bin/clang++-10 ./configure --prefix=$PREFIX --with-libtapi=$PREFIX --target=aarch64-apple-darwin14 --with-llvm-config=/usr/bin/llvm-config-10
make
sudo make install


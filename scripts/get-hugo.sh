#!/usr/bin/env bash

function arq {
    if [ `uname -m` == 'x86_64' ]; then
      echo "64"
    else
      echo "32"
    fi
}

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     PLATFORM=Linux-`arq`;;
    Darwin*)    PLATFORM=macOS-`arq`;;
    CYGWIN*)    PLATFORM=Windows-`arq`;;
    MINGW*)     PLATFORM=Windows-`arq`;;
    *)          PLATFORM="UNKNOWN"
esac

if [ "${PLATFORM}" == 'UNKNOWN' ] || [ "${BUILD_HUGO}" == 'TRUE' ]; then
  echo "Downloading hugo source code and compiling"
  mkdir -p ${GOPATH}/src/github.com/gohugoio/
  wget -qO- https://github.com/gohugoio/hugo/archive/v${HUGO_VERSION}.tar.gz | tar xvz -C ${GOPATH}/src/github.com/gohugoio/
  mv ${GOPATH}/src/github.com/gohugoio/hugo-${HUGO_VERSION} ${GOPATH}/src/github.com/gohugoio/hugo; cd ${GOPATH}/src/github.com/gohugoio/hugo; go build -o ${GOPATH}/bin/hugo
else
  echo "Downloading hugo binary from https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_${PLATFORM}bit.tar.gz"
  mkdir -p ${GOPATH}/bin
  wget -qO- https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_${PLATFORM}bit.tar.gz | tar xvz -C ${GOPATH}/bin hugo
fi
#!/usr/bin/env bash
set -e

VERSION=$1
if [[ -z "$VERSION" ]]; then
  VERSION=$(curl -s 'https://go.dev/VERSION?m=text' | perl -wln -e 'm{^go(\d+\.\d+\.\d)$} and print $1')
  if [[ -z "VERSION" ]]; then
    echo "Usage: Cannot get latest version"
    exit 1
  fi
  if which go >/dev/null 2>&1; then
    CURRENT_VERSION=$(go version | perl -wln -e 'm{go(\S+)} and print $1')
    if [[ $CURRENT_VERSION == $VERSION ]]; then
       echo "You install latest version: $VERSION"
       exit 0
    fi
  fi
fi

TAR_FILE="go${VERSION}.linux-amd64.tar.gz"
URL="https://go.dev/dl/${TAR_FILE}"

cd ~/local
if [[ -d go ]]; then
  OLD_VERSION=$(go version | awk '{print $3}')
  echo "Remove ${OLD_VERSION}"
  rm -rf go
fi

echo "Download $URL"
curl -LO $URL

echo "Extract $TAR_FILE"
tar xf $TAR_FILE

echo "Remove $TAR_FILE"
rm -f $TAR_FILE

echo "Install success!!"

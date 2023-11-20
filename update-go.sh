#!/usr/bin/env bash
set -e

VERSION=$1
if [[ -z "$VERSION" ]]; then
  echo "Usage: update-go.sh version"
  exit 1
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

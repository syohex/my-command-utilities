#!/usr/bin/env bash
set -e

VERSION=$1
if [[ -z "$VERSION" ]]; then
  echo "Usage: update_node.sh version"
  exit 1
fi

cd ~/local
echo "Clean old node.js"
rm -rf node-v*

FILE="node-v${VERSION}-linux-x64.tar.xz"
URL="https://nodejs.org/dist/v${VERSION}/$FILE"
curl -s -LO "$URL"

echo "extract ${FILE}"
tar xf "$FILE"

echo "Success to install node.js v${VERSION}"

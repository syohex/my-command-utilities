#!/usr/bin/env bash
set -e

if ! command -v jq 2>&1; then
  echo "Please install 'jq' to update node"
  exit 1
fi

# get latest node version
VERSION=
if command -v npm 2>&1; then
  VERSION=$(npm info --json node | jq --raw-output '.versions | last')
elif [[ -n "$1" ]]; then
  VERSION=$1
else
  echo "Usage: update_node.sh version"
  exit 1
fi

FILE="node-v${VERSION}-linux-x64.tar.xz"
URL="https://nodejs.org/dist/v${VERSION}/$FILE"
curl -s -LO "$URL"

cd ~/local
echo "Clean old node.js"
rm -rf node-v*

echo "extract ${FILE}"
tar xf "$FILE"

rm "$FILE"
echo "Success to install node.js v${VERSION}"

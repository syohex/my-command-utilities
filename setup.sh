#!/usr/bin/env bash
set -e

mkdir -p ~/bin

commands=(
  gencask
  git-ignore
  cdr_cleanup
  git-blame-pr
  git-pullclean
  weblio
  lang-setup
  update-go.sh
  update-packages.sh
)

for file in "${commands[@]}"; do
  echo "Install $file"

  dest="${HOME}/bin/${file}"
  ln -fs "${PWD}/${file}" "$dest"
  chmod +x "$dest"
done

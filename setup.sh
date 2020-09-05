#!/usr/bin/env bash
set -e

mkdir -p ~/bin

commands=(
  gencask
  git-ignore
  test-emacs
  cdr_cleanup
  git-delete-merged-branches
  git-blame-pr
  git-pullclean
  git-pr
  weblio
  lang-setup
)

for file in "${commands[@]}"; do
  echo "Install $file"

  dest="${HOME}/bin/${file}"
  ln -fs "${PWD}/${file}" "$dest"
  chmod +x "$dest"
done

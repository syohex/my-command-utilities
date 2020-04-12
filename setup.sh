#!/usr/bin/env bash
set -e

if [[ ! -d ~/bin ]]; then
  mkdir -p ~/bin
fi

commands=(
  gencask
  git-ignore
  license-gen.pl
  test-emacs
  cdr_cleanup
  git-delete-merged-branches
)

for file in "${commands[@]}"; do
  echo "Install $file"

  dest="${HOME}/bin/${file}"
  ln -fs "${PWD}/${file}" "$dest"
  chmod +x "$dest"
done

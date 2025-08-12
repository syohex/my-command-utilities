#!/usr/bin/env bash
set -e

mkdir -p ~/bin

commands=(
  git-ignore
  cdr_cleanup
  git-blame-pr
  git-pullclean
  lang-setup
  update-go.sh
  update-node.sh
  update-packages.sh
)

for file in "${commands[@]}"; do
  echo "Install $file"

  dest="${HOME}/bin/${file}"
  ln -fs "${PWD}/${file}" "$dest"

  if [[ "$file" != "update-node.sh" && "$file" != "update-go.sh" ]]; then
    chmod +x "$dest"
  fi
done

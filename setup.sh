#!/usr/bin/env bash
set -e

if [[ ! -d ~/bin ]]; then
    mkdir -p ~/bin
fi

for file in gencask git-ignore license-gen.pl test-emacs
do
    echo "Install $file"
    ln -fs ${PWD}/${file} ~/bin
    chmod +x ~/bin/${file}
done

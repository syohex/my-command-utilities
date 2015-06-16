#!/bin/sh

set -e
set -x

if [ ! -d ~/bin ]; then
    mkdir -p ~/bin
fi

for file in *
do
    if [ $file != "setup.sh" -a $file != "README.md" ]; then
        ln -fs ${PWD}/${file} ~/bin
        chmod +x ~/bin/${file}
    fi
done

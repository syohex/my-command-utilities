#!/bin/sh

set -e

if [ ! -d ~/bin ]; then
    mkdir -p ~/bin
fi

for file in *
do
    if [ $file != "setup.sh" -a $file != "README.md" ]; then
        echo "Install $file"
        ln -fs ${PWD}/${file} ~/bin
        chmod +x ~/bin/${file}
    fi
done

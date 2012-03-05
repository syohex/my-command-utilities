#!/bin/sh

for file in *
do
    if [ $file != "setup.sh" ]
    then
        ln -fs ${PWD}/${file} ~/bin
        chmod +x ~/bin/${file}
    fi
done

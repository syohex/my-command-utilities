#!/bin/sh

for file in *.sh *.pl
do
    if [ $file != "setup.sh" ]
    then
        ln -fs ${PWD}/${file} ~/bin
        chmod +x ~/bin/${file}
    fi
done

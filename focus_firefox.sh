#!/bin/sh

set -e
wmctrl -a 'Firefox'

if [ $? -ne 0 ]; then
    exec firefox
fi

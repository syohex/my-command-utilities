#!/usr/bin/env bash
set -e
set -x

sudo apt update \
	&& sudo apt upgrade -y \
	&& sudo apt autoclean -y \
	&& sudo apt autoremove -y \
	&& sudo apt purge -y $(dpkg -l |grep '^rc' | awk '{print $2}')

sudo snap refresh

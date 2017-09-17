#!/usr/bin/env bash

apt-get -qq -o Dpkg::Use-Pty=0 update
apt-get -qq -o Dpkg::Use-Pty=0 -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

echo "Installation succeeded"
echo "Now run vagrant ssh"
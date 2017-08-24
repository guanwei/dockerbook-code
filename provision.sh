#!/usr/bin/env bash

mkdir -p /data/jenkins && chown -R 1000 /data/jenkins
apt-get -qq update && apt-get -qq install redis-tools
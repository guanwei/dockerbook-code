#!/usr/bin/env bash

mkdir -p /data/jenkins && chown -R 1000 /data/jenkins
apt-get update && apt-get -y install redis-tools
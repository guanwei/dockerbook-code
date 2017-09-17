#!/usr/bin/env bash

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://b4c64qge.mirror.aliyuncs.com"]
}
EOF
systemctl daemon-reload
systemctl restart docker
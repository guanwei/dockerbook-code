#!/usr/bin/env bash

DOCKER_IP="$(ifconfig docker0 | awk -F ' *|:' '/inet addr/{print $4}')"

if ! grep -q "^DOCKER_OPTS=" /etc/default/docker; then
    sed -i "/^#DOCKER_OPTS=.*/a\DOCKER_OPTS=\"--dns $DOCKER_IP --dns 8.8.8.8 --dns-search service.consul\"" /etc/default/docker
fi

if ! grep -q "^EnvironmentFile=" /lib/systemd/system/docker.service; then
    sed -i '/^ExecStart=.*/i\EnvironmentFile=/etc/default/docker' /lib/systemd/system/docker.service
fi

sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/dockerd -H fd:// $DOCKER_OPTS|' /lib/systemd/system/docker.service

systemctl daemon-reload
systemctl restart docker
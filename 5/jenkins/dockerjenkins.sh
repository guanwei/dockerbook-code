#!/bin/bash

tee /etc/default/docker <<EOF
HTTP_PROXY=http://180.166.223.108:10015/
NO_PROXY=127.0.0.1,localhost,.philips.com,.philips.com.cn
http_proxy=http://180.166.223.108:10015/
no_proxy=127.0.0.1,localhost,.philips.com,.philips.com.cn
EOF

sudo service docker start

/bin/tini -- /usr/local/bin/jenkins.sh
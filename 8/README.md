## 使用Docker API

在Docker生态系统中一个有3种API
- Registry API: 提供了与存储Docker镜像的Docker Registry集成的功能
- Docker Hub API: 提供了与Docker Hub集成的功能
- Docker Remote API: 提供了与Docker守护进程集成的功能

#### Remote API

在本地查询Docker API
```
$ echo -e "GET /info HTTP/1.0\r\n" | sudo nc -U /var/run/docker.sock
```

将Docker守护进程绑定到该宿主机的所有网络接口的2375端口上

修改`/etc/default/docker`文件
```
# Use DOCKER_OPTS to modify the daemon startup options.
#DOCKER_OPTS=""
DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4 -H tcp://127.0.0.1:2375"
```

修改`/lib/systemd/system/docker.service`文件
```
## Add EnviromentFile + add "$DOCKER_OPTS" at end of ExecStart
## After change exec "systemctl daemon-reload"

EnvironmentFile=/etc/default/docker
ExecStart=/usr/bin/dockerd -H fd:// $DOCKER_OPTS
```

重新加载和启动守护进程
```
$ sudo systemctl daemon-reload
$ sudo service docker restart
```

连接到远程Docker守护进程
```
$ sudo docker -H docker.example.com:2375 info
```

使用info API接入点
```
$ curl http://docker.example.com:2375/info
```

通过API获取镜像列表
```
$ curl http://docker.example.com:2375/images/json | python -mjson.tool
```

通过API获取指定镜像
```
$ curl http://docker.example.com:2375/images/15d0178048e904fee25354db77091b935423a829f171f3e3cf27f04ffcf7cf56/json | python -mjson.tool
```

通过API搜索镜像
```
$ curl http://docker.example.com:2375/images/search?term=jamtur01 | python -mjson.tool
```

通过API列出正在运行的容器
```
$ curl http://docker.example.com:2375/containers/json | python -mjson.tool
```

通过API列出所有容器
```
$ curl http://docker.example.com:2375/containers/json?all=1 | python -mjson.tool
```

通过API创建容器
```
$ curl -X POST -H "Content-Type: application/json" \
http://docker.example.com:2375/containers/create \
-d '{
    "Image": "jamtur01/jekyll"
}'
```

通过API创建容器，提供更多配置
```
$ curl -X POST -H "Content-Type: application/json" \
"http://docker.example.com:2375/containers/create?name=jekyll" \
-d '{
    "Image": "jamtur01/jekyll",
    "Hostname": "jekyll"
}'
```

通过API启动容器
```
$ curl -X POST -H "Content-Type: application/json" \
http://docker.example.com:2375/containers/591ba02d8d149e5ae5ec2ea30ffe85ed47558b9a40b7405e3b71553d9e59bed3/start \
-d '{
    "PublishAllPorts": true 
}'
```

### 对Docker Remote API进行认证

这种认证机制采用TLS/SSL证书确保用户与API之间连接的安全性

#### 建立证书授权中心

检查是否已安装openssl
```
$ which openssl
```

创建CA目录
```
$ sudo mkdir /etc/docker && cd /etc/docker
```

生成私钥
```
$ echo 01 | sudo tee ca.srl
$ sudo openssl genrsa -des3 -out ca-key.pem
```

创建私钥过程中，需要为CA秘钥设置一个密码

创建CA证书
```
$ sudo openssl req -new -x509 -days 365 -key ca-key.pem -out ca.pem
```

#### 创建服务器的证书签名请求和密钥

创建服务器端密钥
```
$ sudo openssl genrsa -des3 -out server-key.pem
```

这一步需要设置一个密码，将会在正式使用之前清除这个密码

创建服务器CSR
```
$ sudo openssl req -new -key server-key.pem -out server.csr
```

对CSR进行签名
```
$ sudo openssl x509 -req -days 365 -in server.csr -CA ca.pem \
-CAkey ca-key.pem -out server-cert.pem
```

移除服务器端密钥的密码
```
$ sudo openssl rsa -in server-key.pem -out server-key.pem
```

设置Docker服务器端密钥和证书的安全属性
```
$ sudo chmod 0600 /etc/docker/server-key.pem /etc/docker/server-cert.pem \
/etc/docker/ca-key.pem /etc/docker/ca.pem
```

#### 创建客户端证书和密钥

创建客户端密钥
```
$ sudo openssl genrsa -des3 -out client-key.pem
```

同样需要创建一个临时性的密码

创建客户端CSR
```
$ sudo openssl req -new -key client-key.pem -out client.csr
```

添加客户端认证属性
```
$ echo extendedKeyUsage = clientAuth > extfile.cnf
```

对客户端CSR进行签名
```
$ sudo openssl x509 -req -days 365 -in client.csr -CA ca.pem \
-CAkey ca-key.pem -out client-cert.pem -extfile extfile.cnf
```

移除客户端密钥的密码
```
$ sudo openssl rsa -in client-key.pem -out client-key.pem
```

#### 配置Docker守护进程

修改`/etc/default/docker`文件中的Docker启动选项
```
DOCKER_OPTS="-H tcp://0.0.0.0:2376 --tlsverify --tlscacert=/etc/docker/ca.pem --tlscert=/etc/docker/server-cert.pem --tlskey=/etc/docker/server-key.pem"
```

`--tlsverify`标志启用TLS
`--tlscacert`指定CA证书的位置
`--tlscert`指定服务器端证书的位置
`--tlskey`指定服务器端密钥的位置


修改`/lib/systemd/system/docker.service`文件
```
## Add EnviromentFile + add "$DOCKER_OPTS" at end of ExecStart
## After change exec "systemctl daemon-reload"

EnvironmentFile=/etc/default/docker
ExecStart=/usr/bin/dockerd -H fd:// $DOCKER_OPTS
```

重新加载和启动守护进程
```
$ sudo systemctl daemon-reload
$ sudo service docker restart
```

#### 配置Docker客户端开启认证功能

复制Docker客户端的证书和密码
```
$ mkdir ~/.docker
$ cp ca.pem ~/.docker/ca.pem
$ cp client-key.pem ~/.docker/key.pem
$ cp client-cert.pem ~/.docker/cert.pem
```

测试TLS连接
```
$ sudo docker -H docker.example.com:2376 --tlsverify info
```

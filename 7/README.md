## Docekr 编排和服务发现

- 简单的容器编配 Docker Compose
- 分布式服务发现 Consul
- Docker的编配和集群 Swarm

### Docker Compose

#### 安装Docker Compose

在Linux上安装Docker Compose
```
$ sudo curl -L https://github.com/docker/compose/releases/download/1.15.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
```

或者通过Pip安装Docker Compose
```
$ sudo pip install -U docker-compose
```

测试Docker Compose是否工作
```
$ docker-compose --version
```

#### 获取示例应用

- 应用容器，运行Python示例程序
- Redis容器，运行Redis数据库

创建app.py文件
```
from flask import Flask
from redis import Redis
import os

app = Flask(__name__)
redis = Redis(host="redis", port=6379)

@app.route('/')
def hello():
    redis.incr('hits')
    return 'Hello Docker Book reader! I have been seen {0} times'.format(redis.get('hits'))

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)
```

创建requirements.txt
```
flask
redis
```

创建composeapp的Dockerfile
```
$ mkdir composeapp && cd composeapp
$ touch Dockerfile
```

构建composeapp镜像
```
$ sudo docker build -t jamtur01/composeapp .
```

创建docker-compose.yml文件
```
web:
  image: jamtur01/composeapp
  command: python app.py
  ports:
   - "5000:5000"
  volumes:
   - .:/composeapp
  links:
   - redis
redis:
  image: redis
```

启动示例应用服务，必须在docker-compose.yml文件所在目录执行
```
$ sudo docker-compose up
```

以守护进程方式运行Compose
```
$ sudo docker-compose up -d
```

查看服务的运行状态
```
$ sudo docker-compose ps
```

查看服务的日志事件
```
$ sudo docker-compose logs
```

停止正在运行的服务
```
$ sudo docker-compose stop
```

启动这些服务
```
$ sudo docker-compose start
```

删除这些服务（必须服务停止的状态下）
```
$ sudo docker-compose rm
```

### Consul、服务发现和Docker

Docker主要关注分布式应用以及面向服务架构与微服务架构，Consul是一个使用一致性算法的特殊数据存储器

- 创建Consul服务的Docker镜像
- 构建3台运行Docker的宿主机，并在每台上运行一个Consul，提供一个分布式环境
- 构建服务，并将其注册到Consul，然后从其他服务查询该数据

#### 构建Consul镜像

创建Consul配置文件
```
{
  "data_dir": "/data",
  "ui_dir": "/webui",
  "client_addr": "0.0.0.0",
  "ports": {
    "dns": 53
  },
  "recursor": "8.8.8.8"
}
```

创建Consul的Dockerfile
```
$ mkdir consul && cd consul
$ touch Dockerfile
```

构建Consul镜像
```
$ sudo docker build -t="jamtur01/consul" .
```

#### 在本地测试Consul容器

执行一个本地Consul节点
```
$ sudo docker run -p 8500:8500 -p 53:53/udp -h node1 jamtur01/consul -server -bootstrap
```

`-server`告诉Consul代理以服务器的模式运行
`-bootstrap`告诉Consul本节点可以自选举为集群领导者

#### 使用Docker运行Consul集群

拉取Consul镜像
```
$ sudo docker pull jamtur01/consul
```

查看eth0的IP地址
```
$ ifconfig eth0 | awk -F ' *|:' '/inet addr/{print $4}'
```

查看docker0的IP地址
```
$ ip addr show docker0
```

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

通过浏览 `http://localhost:8500` 访问Consul网页界面

#### 使用Docker运行Consul集群

创建3台Ubuntu16.04的宿主机: larry, curly 和 moe

机器名 | IP
---|---
larry | 10.10.10.11
curly | 10.10.10.12
moe | 10.10.10.13

拉取Consul镜像
```
$ sudo docker pull jamtur01/consul
```

查看外网IP地址(假设eth0是外网网卡)
```
$ PUBLIC_IP="$(ifconfig eth0 | awk -F ' *|:' '/inet addr/{print $4}')"
```

查看docker0的IP地址
```
$ DOCKER_IP="$(ifconfig docker0 | awk -F ' *|:' '/inet addr/{print $4}')"
```

修改`/etc/default/docker`文件中的Docker启动选项
```
DOCKER_OPTS="--dns $DOCKER_IP --dns 8.8.8.8 --dns-search service.consul"
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

在larry上启动具有自启动功能的Consul节点
```
larry$ sudo docker run -d -h larry \
-p 8300:8300 -p 8500:8500 \
-p 8301:8301 -p 8301:8301/udp \
-p 8302:8302 -p 8302:8302/udp \
-p 53:53/udp \
--name larry_agent jamtur01/consul \
-server -advertise 10.10.10.11 -bootstrap-expect 3 -ui
```

`-server`告诉Consul代理以服务器的模式运行
`-advertise`告诉代理通过指定的IP广播自己
`-bootstrap-expect`告诉Consul集群有多少代理，还指定该节点具有自启动功能
`-ui`告诉Consul开启内置Web UI服务器

在curly上启动代理
```
curly$ sudo docker run -d -h curly \
-p 8300:8300 -p 8500:8500 \
-p 8301:8301 -p 8301:8301/udp \
-p 8302:8302 -p 8302:8302/udp \
-p 53:53/udp \
--name curly_agent jamtur01/consul \
-server -advertise 10.10.10.12 -join 10.10.10.11 -ui
```

在moe上启动代理
```
curly$ sudo docker run -d -h moe \
-p 8300:8300 -p 8500:8500 \
-p 8301:8301 -p 8301:8301/udp \
-p 8302:8302 -p 8302:8302/udp \
-p 53:53/udp \
--name moe_agent jamtur01/consul \
-server -advertise 10.10.10.13 -join 10.10.10.11 -ui
```

`-join`告诉Consul要连接的主机IP所在的集群

测试Consul的DNS服务
```
larry$ dig @172.17.0.1 consul.service.consul

...
;; ANSWER SECTION:
consul.service.consul.	0	IN	A	10.10.10.11
consul.service.consul.	0	IN	A	10.10.10.12
consul.service.consul.	0	IN	A	10.10.10.13
...
```

#### 配合Consul，在Docker里运行一个分布式服务

- 一个Web应用: distributed_app。启动相关Web工作进程，并注册到Consul
- 一个应用客户端: distributed_client。从Consul读取distributed_app相关信息，并报告当前应用程序的状态和配置

distributed_app会在两个Consul节点（larry和curly）上运行，而distributed_client会在moe节点上运行

创建distributed_app的Dockerfile
```
$ mkdir distributed_app && cd distributed_app
$ touch Dockerfile
```

创建uwsgi-consul.ini文件
```
[uwsgi]
plugins = consul
socket = 127.0.0.1:9999
master = true
enable-threads = true

[server1]
consul-register = url=http://%h.node.consul:8500,name=distributed_app,id=server1,port=2001
mule = config.ru

[server2]
consul-register = url=http://%h.node.consul:8500,name=distributed_app,id=server2,port=2002
mule = config.ru
```

创建config.ru文件
```
require 'rubygems'
require 'sinatra'

get '/' do
  "Hello World!"
end

run Sinatra::Application
```

构建distributed_app镜像
```
$ sudo docker build -t="jamtur01/distributed_app" .
```

创建distributed_client的Dockerfile
```
$ mkdir distributed_client && cd distributed_client
$ touch Dockerfile
```

创建client.rb文件
```
require "rubygems"
require "json"
require "net/http"
require "uri"
require "resolv"

empty = "There are no distributed applications registered in Consul"
 
uri = URI.parse("http://consul.service.consul:8500/v1/catalog/service/distributed_app")

http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.request_uri)

response = http.request(request)

while true
  if response.body == "{}"
    puts empty
    sleep(1)
  elsif
    result = JSON.parse(response.body)
    result.each do |service|
      puts "Application #{service['ServiceName']} with element #{service["ServiceID"]} on port #{service["ServicePort"]} found on node #{service["Node"]} (#{service["Address"]})."
      dns = Resolv::DNS.new.getresources("distributed_app.service.consul", Resolv::DNS::Resource::IN::A)
      puts "We can also resolve DNS - #{service['ServiceName']} resolves to #{dns.collect { |d| d.address }.join(" and ")}."
      sleep(1)
    end
  end
end
```

构建distributed_client镜像
```
$ sudo docker build -t="jamtur01/distributed_client" .
```

在larry,curly上启动distributed_app
```
larry$ sudo docker run -h $HOSTNAME -d --name larry_distributed jamtur01/distributed_app
curly$ sudo docker run -h $HOSTNAME -d --name curly_distributed jamtur01/distributed_app
```

在larry上查看distributed_app日志输出
```
$ sudo docker logs larry_distributed
```

在moe上启动distributed_client
```
moe$ sudo docker run -h $HOSTNAME -d --name moe_distributed jamtur01/distributed_client
```

在moe上查看distributed_client
```
$ sudo docker logs moe_distributed
```

### Docker Swarm

Docker Swarm是一个原生的Docker集群管理工具。Swarm将一组Docker主机作为一个虚拟的Docker主机来管理

#### 安装Swarm

将在两台主机上安装Swarm

主机名 | IP
---|---
smoker | 10.10.10.11
joker | 10.10.10.12

拉取Docker Swarm镜像
```
$ sudo docker pull swarm
```

查看Docker Swarm镜像
```
$ docker images swarm
```

获取Docker Swarm集群ID
```
$ sudo docker run --rm swarm create

b811b0bc438cb9a06fb68a25f1c9d8ab
```

在smoker,joker上运行swarm代理
```
smoker$ sudo docker run -d swarm join --addr=10.10.10.11:2375 token://b811b0bc438cb9a06fb68a25f1c9d8ab
joker$ sudo docker run -d swarm join --addr=10.10.10.12:2375 token://b811b0bc438cb9a06fb68a25f1c9d8ab
```

列出Docker Swarm节点
```
$ sudo docker run --rm swarm list token://b811b0bc438cb9a06fb68a25f1c9d8ab
```

启动Swarm集群管理者
```
$ sudo docker run -d -p 2380:2375 swarm manage token://b811b0bc438cb9a06fb68a25f1c9d8ab
```

在Swarm集群中运行docker info命令
```
$ sudo docker -H tcp://localhost:2380 info
```

通过循环创建6个Nginx容器
```
$ for i in `seq 1 6`; do sudo docker -H tcp://localhost:2380 run -d --name www-$i -p 80 nginx; done
```

在Swarm集群中执行docker ps命令
```
$ sudo docker -H tcp://localhost:2380 ps
```

#### 过滤器

过滤器是告知Swarm该优先在哪个节点上运行容器的明确指令

目前Swarm具有如下5种过滤器：
- 约束过滤器（constraint filter）
- 亲和过滤器（affinity filter）
- 依赖过滤器（dependency filter）
- 端口过滤器（port filter）
- 健康过滤器（health filter）

约束过滤器依赖与用户给每个节点赋予的标签

运行docker守护进程时设置约束标签
```
$ sudo docker daemon --label datacenter=us-east1
```

启动容器时指定约束过滤器
```
$ sudo docker -H tcp://localhost:2380 run -e constraint:datacenter==us-east1 -d --name www-use1 -p 80 nginx
```

启动容器时指定亲和过滤器
```
$ sudo docker run -d --name www-use2 -e affinity:container==www-use1 nginx
```

启动容器时在亲和过滤器中使用正则表达式
```
$ sudo docker run -d --name db1 -e affinity:container!=www-use* mysql
```

通过`-e`选项指定约束条件

#### 策略

策略允许用户用集群节点更隐式的特性来对容器进行调度

Docker Swarm现在有3种策略:
- 平铺策略
- 紧凑策略
- 随机策略

### 其他编排工具和组件

#### Fleet和etcd

Fleet是一个集群管理工具，而etcd是一个高可用键值数据库

#### Kubernetes

Kubernetes主要关注需要使用多个容器的应用程序，如弹性分布式微服务

#### Apache Mesos

#### Helios

#### Centurion

这个工具的目的是帮助开发者利用Docker做持续部署
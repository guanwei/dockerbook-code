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

已守护进程方式运行Compose
```
$ sudo docker-compose up -d
```


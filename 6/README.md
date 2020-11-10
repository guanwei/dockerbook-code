### 构建使用Jekyll框架的自定义网站

构建两个镜像
- 一个镜像安装了Jekyll及其他用于构建Jekyll网站的必要软件包
- 一个镜像通过Apache来让Jekyll网站工作起来

#### Jekyll基础镜像

创建Jekyll的Dockerfile
```
$ mkdir jekyll && cd jekyll
$ touch Dockerfile
```

#### 构建Jekyll镜像

构建Jekyll镜像
```
$ sudo docker build -t jamtur01/jekyll .
```

查看新的Jekyll镜像
```
$ sudo docker images
```

#### Apache镜像

创建Apache的Dockerfile
```
$ mkdir apache && cd apache
$ touch Dockerfile
```

#### 构建Apache镜像

构建Apache镜像
```
$ sudo docker build -t jamtur01/apache .
```

查看新的Apache镜像
```
$ sudo docker images
```

#### 启动Jekyll网站

创建示例Jekyll博客
```
$ git clone https://github.com/jamtur01/james_blog.git
$ rm -rf james_blog/.git
```

创建Jekyll容器
```
$ sudo docker run -v $PWD/james_blog:/data --name james_blog jamtur01/jekyll
```

卷的几个有用的特征
- 卷可以在容器间共享和重用
- 共享卷时不一定要运行相应的容器
- 对卷的修改会直接在卷上反映出来
- 更新镜像时不会包含对卷的修改
- 卷会一直存在，直到没有容器使用他们

查看james_blog卷的具体位置
```
$ sudo docker inspect -f "{{ range .Mounts }}{{.}}{{end}}" james_blog
```

创建Apache容器
```
$ sudo docker run -d -P --volumes-from james_blog --name apache jamtur01/apache
```

查看Apache容器的端口
```
$ sudo docker port apache
```

现在Docker宿主机上Jekyll网站已正常运行

#### 更新Jekyll网站

编辑Jekyll博客
```
$ vi james_blog/_config.yml
```

`_config.yml`不会自动被监控，需要再次启动james_blog容器
```
$ sudo docker restart james_blog
```

查看james_blog容器的日志
```
$ sudo docker logs james_blog
```

备份/var/www/html卷，--rm标志表示只用一次的容器
```
$ sudo docker run --rm --volumes-from james_blog -v $(pwd):/backup ubuntu tar zcvf /backup/james_blog_backup.tar.gz /var/www/html
```

### 构建一个Java应用程序

构建两个镜
- 一个镜像从URL拉取指定的WAR文件并将其保存到卷里
- 一个含有Tomcat服务器的镜像运行这些下载的WAR文件

#### 获取程序的镜像

创建获取程序的Dockerfile
```
$ mkdir fetcher && cd fetcher
$ touch Dockerfile
```

构建获取程序的镜像
```
$ sudo docker build -t jamtur01/fetcher .
```

获取WAR文件
```
$ sudo docker run -it --name sample jamtur01/fetcher https://tomcat.apache.org/tomcat-8.0-doc/appdev/sample/sample.war
```

查看sample容器的卷
```
$ sudo docker inspect -f "{{ range .Mounts }}{{.}}{{end}}" sample
```

查看卷所在的目录
```
$ sudo ls -l /var/lib/docker/volumes
```

#### Tomcat8应用服务器的镜像

创建Tomcat8的Dockerfile
```
$ mkdir tomcat8 && cd tomcat8
$ touch Dockerfile
```

构建Tomcat8的镜像
```
$ sudo docker build -t jamtur01/tomcat8 .
```

创建一个Tomcat8容器
```
$ sudo docker run --name sample_app --volumes-from sample -d -P jamtur01/tomcat8
```

查找tomcat应用端口
```
$ sudo docker port sample_app
```

在Docker宿主机上访问`http://IP:PORT/sample`，网站已正常运行

#### 使用TProv展示Tomcat应用

创建TProv的Dockerfile
```
$ mkdir tprov && cd tprov
$ touch Dockerfile
```

构建TProv的镜像
```
$ sudo docker build -t jamtur01/tprov .
```

创建一个TProv容器
```
$ sudo docker run --name tprov -d -P jamtur01/tprov
```

查找TProv应用端口
```
$ sudo docker port tprov
```

在Docker宿主机上访问TProv网站,已正常运行

### 多容器的应用栈

构建一系列的镜像来支持部署多容器的应用
- 一个Node容器，用于服务与Node应用
- 一个Redis主容器，用于保存和集群化应用状态
- 两个Redis副本容器，用于集群化应用状态
- 一个日志容器，用于捕获应用日志

#### Node.js镜像

创建Node.js的Dockerfile
```
$ mkdir -p nodejs/nodeapp && cd nodejs/nodeapp
$ wget https://raw.githubusercontent.com/jamtur01/dockerbook-code/master/code/6/node/nodejs/nodeapp/package.json -P nodeapp
$ wget https://raw.githubusercontent.com/jamtur01/dockerbook-code/master/code/6/node/nodejs/nodeapp/server.js -P nodeapp
$ cd ..
$ touch Dockerfile
```

构建Node.js镜像
```
$ sudo docker build -t jamtur01/nodejs .
```

#### Redis基础镜像

创建Redis基础镜像的Dockerfile
```
$ mkdir redis_base && cd redis_base
$ touch Dockerfile
```

构建Redis基础镜像
```
$ sudo docker build -t jamtur01/redis .
```

#### Redis主镜像

创建Redis主服务器的Dockerfile
```
$ mkdir redis_primary && cd redis_primary
$ touch Dockerfile
```

构建Redis主镜像
```
$ sudo docker build -t jamtur01/redis_primary .
```

#### Redis副本镜像

创建Redis副本镜像的Dockerfile
```
$ mkdir redis_replica && cd redis_replica
$ touch Dockerfile
```

构建Redis副本镜像
```
$ sudo docker build -t jamtur01/redis_replica .
```

#### 创建后端集群

创建express网络
```
$ sudo docker network create express
```

运行Redis主容器 ,`-h`标志用来设置容器的主机名
```
$ sudo docker run -d -h redis_primary --net express --name redis_primary jamtur01/redis_primary
```

查看Redis主容器日志
```
$ sudo docker logs redis_primary
```

读取Redis主日志，`--volumes-from`标志告诉它从redis_primary容器挂载所有的卷
```
$ sudo docker run -it --rm --volumes-from redis_primary ubuntu cat /var/log/redis/redis-server.log
```

运行第一个Redis副本容器
```
$ sudo docker run -d -h redis_replica1 --name redis_replica1 --net express jamtur01/redis_replica
```

读取Redis副本容器的日志
```
$ sudo docker run -it --rm --volumes-from redis_replica1 ubuntu cat /var/log/redis/redis-replica.log
```

运行第二个Redis副本容器
```
$ sudo docker run -d -h redis_replica2 --name redis_replica2 --net express jamtur01/redis_replica
```

读取第二个Redis副本容器的日志
```
$ sudo docker run -it --rm --volumes-from redis_replica2 ubuntu cat /var/log/redis/redis-replica.log
```

#### 创建Node容器

运行Node.js容器
```
$ sudo docker run -d --name nodeapp -p 3000:3000 --net express jamtur01/nodejs
```

查看nodeapp容器的日志
```
$ sudo docker logs nodeapp
```

在Docker宿主机上访问nodeapp网站,已正常运行

#### 捕获应用日志

创建Logstash的Dockerfile
```
$ mkdir logstash && cd logstash
$ touch Dockerfile
```

创建Logstash配置文件
```
input {
  file {
    type => "syslog"
    path => ["/var/log/nodeapp/nodeapp.log", "/var/log/redis/redis-server.log"]
  }
}
output {
  stdout {
    codec => rubydebug
  }
}
```

构建Logstash镜像
```
$ sudo docker build -t jamtur01/logstash .
```

启动Logstash容器
```
$ sudo docker run -d --name logstash --volumes-from redis_primary --volumes-from nodeapp jamtur01/logstash
```

查看Logstash容器的日志
```
$ sudo docker logs -f logstash
```

刷新Web应用，就能在Logstash容器的日志中看到这个事件

#### 不使用SSH管理Docker容器

使用docker kill发送信号
```
$ sudo docker kill -s <signal> <container>
```

安装 nsenter
```
$ sudo docker run -v /usr/local/bin/:/target jpetazzo/nsenter
```

获取容器的进程ID
```
$ sudo docker inspect --format '{{.State.Pid}}' <container>
```

使用 nsenter 进入容器
```
$ sudo nsenter --target $PID --mount --uts --ipc --net --pid
```

使用 nsenter 在容器内执行命令
```
sudo nsenter --target $PID --mount --uts --ipc --net --pid ls
```





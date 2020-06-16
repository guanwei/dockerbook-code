### 使用Docker测试静态网站

创建sample站点的Dockerfile
```
$ mkdir sample && cd sample
$ touch Dockerfile
```

获取Nginx配置文件
```
$ mkdir nginx && cd nginx
$ wget https://raw.githubusercontent.com/jamtur01/dockerbook-code/master/code/5/sample/nginx/global.conf
$ wget http://raw.githubusercontent.com/jamtur01/dockerbook-code/master/code/5/sample/nginx/nginx.conf
$ cd ..
```

Dockerfile 内容

```
FROM ubuntu:14.04
MAINTAINER James Turnbull "james@example.com"
ENV REFRESHED_AT 2014-06-01
RUN apt-get -yqq update && apt-get -yqq install nginx
RUN mkdir -p /var/www/html/website
ADD nginx/global.conf /etc/nginx/conf.d/
ADD nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
```

构建新的Nginx镜像
```
$ sudo docker build -t jamtur01/nginx .
```

展示Nginx镜像的构建历史
```
$ sudo docker history jamtur01/nginx
```

下载Sample网站
```
$ mkdir website && cd website
$ wget https://raw.githubusercontent.com/jamtur01/dockerbook-code/master/code/5/sample/website/index.html
$ cd ..
```

构建第一个Nginx测试容器
```
$ sudo docker run -d -p 80 --name website \
  -v $PWD/website:/var/www/html/website \
  jamtur01/nginx nginx
```

`-v`选项允许我们将宿主机的目录作为卷，挂载到容器里。卷可以在容器间共享，即便容器停止，卷里的内容依旧存在

可以通过在目录后面加上`rw`或者`ro`来指定容器内目录的读写状态
```
$ sudo docker run -d -p 80 --name website \
  -v $PWD/website:/var/www/html/website:ro \
  jamtur01/nginx nginx
```

查看Sample网站容器
```
$ sudo docker ps website
```

在宿主机上打开浏览器访问Sample网站

修改宿主机上website目录下的index.html文件，刷新下浏览器，Sample网站内容更新为修改后的状态

### 使用Docker构建并测试Web应用程序

创建Sinatra站点的Dockerfile
```
$ mkdir sinatra && cd sinatra
$ touch Dockerfile
```

Dockerfile 内容

```
FROM ubuntu:14.04
MAINTAINER James Turnbull "james@example.com"
ENV REFRESHED_AT 2014-06-01

RUN apt-get -yqq update && apt-get -yqq install wget curl gnupg2  libcurl3 build-essential redis-tools
RUN apt-get install -y --force-yes zlib1g-dev libssl-dev libreadline-dev libyaml-dev libxml2-dev libxslt-dev

RUN cd /tmp
COPY ruby-2.5.0.tar.gz /tmp/
#RUN wget  http://ftp.ruby-lang.org/pub/ruby/2.5/ruby-2.5.0.tar.gz
#RUN wget  http://mirrors.nju.edu.cn/ruby/2.5/ruby-2.5.0.tar.gz
RUN tar -xvzf /tmp/ruby-2.5.0.tar.gz -C /tmp/
RUN cd /tmp/ruby-2.5.0/ && ./configure --prefix=/usr/local; make; make install
RUN ruby -v

RUN ln -s   /usr/local/bin/ruby /usr/bin/ruby

RUN gem install --no-rdoc --no-ri sinatra json redis

RUN mkdir -p /opt/webapp

EXPOSE 4567

CMD [ "/opt/webapp/bin/webapp" ]
```


构建新的Sinatra镜像
```
$ sudo docker build -t jamtur01/sinatra .
```

下载Sinatra Web应用程序
```
$ cd sinatra
$ wget --cut-dirs=3 -nH -r --reject Dockerfile,index.html --no-parent http://dockerbook.com/code/5/sinatra/webapp/
$ ls -l webapp
```

确保webapp/bin/webapp可以执行
```
$ chmod +x webapp/bin/webapp
```

启动第一个Sinatra容器
```
$ sudo docker run -d -p 4567 --name webapp \
  -v $PWD/webapp:/opt/webapp jamtur01/sinatra
```

检查Sinatra容器的日志
```
$ sudo docker logs webapp
```

跟踪Sinatra容器的日志
```
$ sudo docker logs -f webapp
```

列出Sinatra容器的进程
```
$ sudo docker top webapp
```

检查Sinatra容器的端口映射
```
$ sudo docker port webapp 4567
```

测试Sinatra应用程序
```
$ curl -i -H 'Accept: application/json' \
  -d 'name=Foo&status=Bar' http://localhost:49160/json
```

#### 扩展Sinatra应用程序来使用Redis

下载升级版的Sinatra应用程序
```
$ cd sinatra
$ wget --cut-dirs=3 -nH -r --reject Dockerfile,index.html --no-parent http://dockerbook.com/code/5/sinatra/webapp_redis/
$ ls -l webapp_redis
```

使webapp_redis/bin/webapp文件可执行
```
$ chmod +x webapp_redis/bin/webapp
```

创建Redis镜像的Dockerfile
```
$ mkdir sinatra/redis && cd sinatra/redis
$ touch Dockerfile
```

Dockerfile 内容
```
FROM ubuntu:14.04
MAINTAINER James Turnbull "james@example.com"
ENV REFRESHED_AT 2014-06-01

RUN apt-get -yqq update && apt-get -yqq install redis-server redis-tools
RUN sysctl -w vm.overcommit_memory=1

EXPOSE 6379

ENTRYPOINT ["/usr/bin/redis-server"]
```

构建Redis镜像
```
$ sudo docker build -t jamtur01/redis .
```

启动Redis容器
```
$ sudo docker run -d -p 6379 --name redis jamtur01/redis
```

检查Redis容器端口映射
```
$ sudo docker port redis 6379
```

在Ubuntu系统上安装redis客户端，并测试Redis连接
```
$ sudo apt-get install -y redis-tools
$ redis-cli -h 127.0.0.1 -p 49161
```

查看docker0网络接口
```
$ ip a show docker0
```

查看Redis容器的IP地址
```
$ sudo docker inspect -f '{{ .NetworkSettings.IPAddress }}' redis
```

通过`--link`标志创建两个容器间的父子连接,这个例子中，新容器连接到redis容器，并使用db作为别名
```
$ sudo docker run -p 4567:4567 \
  --name webapp --link redis:db \
  -v $PWD/webapp_redis:/opt/webapp jamtur01/sinatra
```

在宿主机上使用curl命令测试Sinatra应用程序
```
$ curl -i -H 'Accept: application/json' -d 'name=Foo&status=Bar' http://localhost:4567/json
$ curl -i http://localhost:4567/json
```

#### Docker Networking

创建Docker网络
```
$ sudo docker network create app
```

查看app网络
```
$ sudo docker network inspect app
```

列出Docker的所有网络
```
$ sudo docker network ls
```

删除一个Docker网络
```
$ sudo docker network rm app
```

在Docker网络中创建Redis容器
```
$ sudo docker run -d --net=app --name db jamtur01/redis
```

链接redis容器
```
$ sudo docker run -p 4567 \
  --net=app --name webapp \
  -v $PWD/webapp_redis:/opt/webapp jamtur01/sinatra
```

### Docker用于持续集成

#### 构建Jenkins和Docker服务器

构建Docker-Jenkins镜像
```
$ sudo docker build -t jamtur01/dockerjenkins .
```

运行Docker-Jenkins镜像
```
$ sudo docker run -p 8080:8080 --name jenkins --privileged -d jamtur01/dockerjenkins
```

检查Docker Jenkins容器的日志
```
$ sudo docker logs jenkins
```

#### 创建新的Jenkins作业

第一次运行需要解锁Jenkins
```
$ sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

创建`Docker_test_job`自由风格的软件项目，选择Git并指定测试仓库`https://github.com/jamtur01/docker-jenkins-sample.git`，选择`Delete workspace before build starts`在构建前删除工作空间，点击`Add Build Step`增加一个构建步骤，选择`Execute shell`，使用定义的脚本来启动测试Docker，点击`Add post-build action`加入构建后的动作，加入一个`Publish JUnit test result report`公布JUnit测试结果报告，指定`Test report XMLs`测试报告的XML文件为`spec/reports/*.xml`，最后点击Save保存作业

#### 运行Jenkins作业

点击`Build Now`按钮，运行Jenkins作业，`Build History`中会出现新的构建，点击该构建，再点击`Console Output`查看控制台输出

#### 创建多配置作业

创建`Docker_matrix_job`多配置项目，选择Git并指定测试仓库`https://github.com/jamtur01/docker-jenkins-sample.git`，点击`Add Axis`按钮，并选择`User-defined Axis`，定义名字为`OS`，值为`centos debian ubuntu`，选择`Delete workspace before build starts`在构建前删除工作空间，点击`Add Build Step`增加一个构建步骤，选择`Execute shell`，使用定义的脚本来启动测试Docker，点击`Add post-build action`加入构建后的动作，加入一个`Publish JUnit test result report`公布JUnit测试结果报告，指定`Test report XMLs`测试报告的XML文件为`spec/reports/*.xml`，最后点击Save保存作业

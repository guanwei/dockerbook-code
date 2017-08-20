列出镜像
```
$ sudo docker images
```

所有容器都保存在`/var/lib/docker/containers`目录下

拉取Ubuntu镜像
```
$ sudo docker pull ubuntu:16.04
```

如果没有指定具体的镜像标签，Docker会自动下载latest标签的镜像

列出所有Ubuntu Docker镜像
```
$ sudo docker images
```

运行一个带有标签的Docker镜像
```
$ sudo docker run -t -i --name new_container ubuntu:16.04 /bin/bash
```

Docker Hub中有两种类型的仓库：用户仓库（user repository）和顶层仓库（top-level repository）

用户仓库的命名由用户名和仓库名两部分组成，如jamtur01/puppet
- 用户名： jamtur01
- 仓库名： puppet

顶层仓库只包含仓库名，由Docker公司和选定的能提供优质基础镜像的厂商管理

只查看ubuntu镜像
```
$ sudo docker images ubuntu
```

查找Docker Hub上公共的可用镜像
```
$ sudo docker search puppet
```

在Docker Hub上创建账号，之后使用`docker login`登录Docker Hub
```
$ sudo docker login
```

创建一个apache定制容器
```
$ sudo docker -it ubuntu /bin/bash
root@4aab3ce3cb76:/# apt-get update && apt-get install -y apache2
$ exit
```

提交定制容器
```
$ sudo docker commit 4aab3ce3cb76 jamtur01/apache2
```

提交时指定更多的选项，`-m`选项指定新创建镜像的提交信息，`-a`选项指定创建镜像的作者信息
```
$ sudo docker commit -m "A new custom image" -a "James Turnbull" 4aab3ce3cb76 jamtur01/apache2:webserver
```

推送镜像到Docker Hub
```
$ sudo docker push jamtur01/apache2
```

除了从命令行构建和推送镜像,Docker Hub还允许我们定义自动构建,我们只需将Git Hub或BitBucket中含有Dockerfile文件的仓库连接到Docker Hub即可

推荐使用`Dockerfile`文件和`docker build`命令来构建容器

创建一个示例仓库
```
$ mkdir static_web && cd static_web
$ touch Dockerfile
```

基于Dockerfile构建新镜像
```
$ sudo docker build -t jamtur01/static_web .
```

在构建时为镜像设置标签
```
$ sudo docker build -t jamtur01/static_web:v1 .
```

从Git仓库构建Docker镜像
```
$ sudo docker build -t jamtur01/static_web:v1 \
  git@github.com:jamtur01/docker-static_web
```

通过`-f`标志指定Dockerfile的位置
```
$ sudo docker build -t jamtur01/static_web -f path-to-file
```

基于最后的成功步骤创建创建新容器
```
$ sudo docker run -it 997485f46ec4 /bin/bash
```

忽略Dockerfile的构建缓存
```
$ sudo docker build --no-cache -t jamtur01/static_web .
```

Ubuntu系统的Dockerfile模板
```
FROM ubuntu:16.04
MAINTAINER James Turnbull "james@example.com"
ENV REFRESHED_AT 2016-06-01
RUN apt-get -qq update
```

Fedora系统的Dockerfile模板
```
FROM fedora:26
MAINTAINER James Turnbull "james@example.com"
ENV REFRESHED_AT 2016-06-01
RUN yum -q makecache
```

查看镜像的构建历史
```
$ sudo docker history 22d47c8cb6e5
```

通过`-p`选项映射到特定端口
```
$ sudo docker run -d -p 80:80 --name static_web jamtur01/status_web nginx -g "daemon off;"
```

绑定到特定的网络接口的随机端口
```
$ sudo docker run -d -p 127.0.0.1::80 --name static_web jamtur01/static_web nginx -g "daemon off;"
```

查看该容器映射的端口
```
$ sudo docker ports static_web
```

使用curl测试容器中的web服务器
```
$ curl localhost:8080
```

CMD指令用于指定一个容器启动时要运行的命令
```
CMD ["/bin/bash","-l"]
```

如果不使用数组结构指定CMD指令，Docker会在指定的命令前加上`/bin/sh -c`,执行该命令时有可能导致意外的行为

`docker run`命令行中指定的命令会覆盖Dockerfile中的CMD命令
```
$ sudo docker run -it jamtur01/test /bin/ps
```

使用ENTRYPOINT指令时，`docker run`命令行中指定的任何参数都会被当做参数再次传递给ENTRYPOINT指令中指定的命令
```
ENTRYPOINT ["/usr/sbin/nginx"]
```

讲`-g "daemon off;"`作为参数传递给ENTRYPOINT指令
```
$ sudo docker run -it jamtur01/static_web -g "daemon off;"
```

同时使用ENTRYPOINT和CMD指令时，如果在启动容器时不指定任何参数，则CMD指令中指定的参数会被传递给ENTRYPOINT指令
```
ENTRYPOINT ["/usr/sbin/nginx"]
CMD ["-h"]
```

WORKDIR指令用于在容器内部设置一个工作目录
```
WORKDIR /opt/webapp/db
RUN bundle install
WORKDIR /opt/webapp
ENTRYPOINT ["rackup"]
```

通过`-w`标志在运行时覆盖工作目录
```
$ sudo docker run -it -w /var/log ubuntu pwd
```

ENV指令用来在镜像构建过程中设置环境变量
```
ENV RVM_PATH /home/rvm/
```

使用ENV设置多个环境变量
```
ENV RVM_PATH=/home/rvm RVM_ARCHFLAGS="-arch i386"
```

在Dockerfile中使用环境变量
```
ENV TARGET_DIR /opt/app
WORKDIR $TARGET_DIR
```

这些环境变量也会被持久保存到从该镜像创建的任何容器中

运行`docker run`命令时，可以使用`-e`标志传递环境变量，这些变量只在运行时有效
```
$ sudo docker run -it -e "WEB_PORT=8080" ubuntu env
```

USER指令用来指定该镜像会以什么用户去运行
```
USER user
USER user:group
USER uid
USER uid:gid
USER user:gid
USER uid:group
```

如果不通过USER指令指定用户，默认以root用户去运行

VOLUME指令用来向基于镜像创建的容器添加卷,我们可以将外部目录挂载到容器卷上
```
VOLUME ["/opt/projects","/data"]
```

ADD指令用来将构建环境下的文件和目录复制到镜像中
```
ADD software.lic /opt/application/software.lic
ADD http://wordpress.org/latest.zip /root/wordpress.zip
```

ADD指令会自动将归档文件latest.tar.gz解压到/var/www/wordpress/目录下
```
ADD latest.tar.gz /var/www/wordpress/
```

COPY指令只关心在构建上下文中复制本地文件,而不会去做文件提取和解压的工作
```
COPY conf.d/ /etc/apache2/
```

LABEL指令用于为Docker镜像添加元数据
```
LABEL version="1.0"
LABEL location="New York" type="Data Center" role="Web Server"
```

STOPSIGNAL指令用来设置停止容器时发送什么系统调用信号给容器

ARG指令用来定义在`docker build`命令运行时传递给构建运行时的变量
```
ARG build
ARG webapp_user=user
```

通过`--build-arg`标志传递构建变量
```
$ docker build --build-arg build=1234 -t jamtur01/webapp .
```

ONBUILD指令用来为镜像添加触发器,ONBUILD触发器会按照父镜像中指定的顺序执行，并且只能被继承一次
```
ONBUILD ADD . /app/src
ONBUILD RUN cd /app/src && make
```

删除Docker镜像
```
$ sudo docker rmi jamtur01/static_web
```

如果想删除Docker Hub上的镜像仓库，需要登录到Docker Hub后使用Delete repository链接来删除

删除所有镜像
```
$ sudo docker rmi `sudo docker ps imgages -a -q`
```
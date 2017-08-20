查看docker程序是否正常工作
```
$ sudo docker info
```

运行我们的第一个容器
```
$ sudo docker run -i -t ubuntu /bin/bash
```

查看当前系统中容器的列表
```
$ docker ps -a
```

列出最后一个运行的容器
```
$ docker ps -l
```

给容器命名
```
$ docker run --name bob_the_container -i -t ubuntu /bin/bash
```

启动已经停止运行的容器
```
$ sudo docker start bob_the_container
```

通过ID启动已经停止运行的容器
```
$ sudo docker start aa3f365f0f4e
```

附着到正在运行的容器
```
$ sudo docker attach bob_the_container
```

通过ID附着到正在运行的容器
```
$ sudo docker attach aa3f365f0f4e
```

创建长期运行的容器
```
$ sudo docker run --name daemon_dave -d ubuntu /bin/sh -c "while true; do echo hello world; sleep 1; done"
```

获取守护式容器的日志
```
$ sudo docker logs daemon_dave
```

跟踪守护式容器的日志
```
$ sudo docker logs -f daemon_dave
```

使用`-t`标志为每条日志加上时间戳
```
$ sudo docker logs -ft daemon_dave
```

设置容器所用的日志驱动为`syslog`,会将容器的日志输出到`Syslog`,导致`docker logs`命令不输出任何东西
```
$ sudo docker run --log-driver="syslog" --name daemon_dwayne -d ubuntu /bin/sh -c "while true; do echo hello world; sleep 1; done"
```

查看守护式容器的进程
```
$ sudo docker top daemon_dave
```

显示一个或多个容器的统计信息
```
$ sudo docker stats daemon_dave daemon_kate daemon_clare daemon_sarah
```

在容器中运行后台任务
```
$ sudo docker exec -d daemon_dave touch /etc/new_config/file
```

在容器内运行交互命令
```
$ sudo docker exec -i -t daemon_dave /bin/bash
```

停止正在运行的容器
```
$ sudo docker stop daemon_dave
```

可以通过`--restart`标志，让Docker自动重启容器
```
$ sudo docker run --restart=always --name daemon_dave -d ubuntu /bin/sh -c "while true; do echo hello world; sleep 1; done"
```

通过`on-failure`标志，设置容器重启次数
```
--restart=on-failure:5
```

查看容器
```
$ sudo docker inspect daemon_dave
```

通过`-f`或者`--format`标志了来选定查看结果
```
$ sudo docker inspect --format='{{ .State.Running }}' daemon_dave
```

查看容器的IP地址
```
$ sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' daemon_dave
```

查看多个容器
```
$ sudo docker inspect --format '{{.Name}} {{.State.Running}}' daemon_dave bob_the_container
```

删除容器
```
$ sudo docker rm 80430f8d0921
```

删除所有容器
```
$ sudo docker rm `sudo docker ps -a -q`
```
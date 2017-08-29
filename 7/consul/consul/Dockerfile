FROM ubuntu:16.04
MAINTAINER James Turnbull <james@example.com>
ENV REFRESHED_AT 2014-08-01

RUN apt-get -qq update
RUN apt-get -qq install curl unzip

ADD consul_0.9.2_linux_amd64.zip /tmp/consul.zip
RUN cd /usr/local/bin && unzip /tmp/consul.zip && chmod +x /usr/local/bin/consul && rm /tmp/consul.zip

ADD consul.json /etc/consul.d

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8500 53/udp

VOLUME ["/data"]

ENTRYPOINT [ "consul", "agent", "-config-dir=/etc/consul.d" ]
CMD []
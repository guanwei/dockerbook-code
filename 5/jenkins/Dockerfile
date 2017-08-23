FROM jenkins
MAINTAINER james@example.com
ENV REFRESHED_AT 2016-06-01

#USER root
#RUN apt-get -qq update && apt-get -qq install apt-transport-https ca-certificates curl software-properties-common
#RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#RUN apt-get -qq update && apt-get -qq install docker-ce
#USER jenkins

COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
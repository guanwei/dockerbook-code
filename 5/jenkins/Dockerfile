FROM jenkins
MAINTAINER james@example.com
ENV REFRESHED_AT 2016-06-01

USER root
RUN apt-get -qq update && apt-get -qq install sudo
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN curl -sSL https://get.docker.com/ | sh
RUN usermod -aG docker jenkins

VOLUME [ "/var/lib/docker" ]

RUN mkdir -p /var/log/jenkins && chown -R jenkins:jenkins /var/log/jenkins
RUN mkdir -p /var/cache/jenkins && chown -R jenkins:jenkins /var/cache/jenkins
ENV JENKINS_OPTS="--logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war --prefix=/jenkins"

COPY dockerjenkins.sh /usr/local/bin/dockerjenkins.sh
RUN chmod +x /usr/local/bin/dockerjenkins.sh

USER jenkins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

CMD [ "dockerjenkins.sh" ]
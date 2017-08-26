FROM ubuntu:16.04
MAINTAINER James Turnbull <james@example.com>
ENV REFRESHED_AT 2016-06-01

RUN apt-get -qq update
RUN apt-get -qq install ruby ruby-dev build-essential
RUN gem install --no-rdoc --no-ri tprov

EXPOSE 4567

ENTRYPOINT [ "tprov" ]
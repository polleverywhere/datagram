FROM ubuntu:trusty
MAINTAINER Andy Shinn <andys@andyshinn.as>

ENV DEBIAN_FRONTEND noninteractive
ENV PORT 5000

EXPOSE 5000

RUN apt-get update -q
RUN apt-get install -y -q \
  ruby \
  ruby-dev \
  ruby-bundler \
  libmysqlclient-dev \
  libsqlite3-dev

ADD . /datagram

RUN bundle install \
  --without development test \
  --gemfile /datagram/Gemfile \
  --binstubs /usr/local/bin

ENV PATH /datagram/bin:$PATH

CMD thin start -R /datagram/config.ru -p $PORT

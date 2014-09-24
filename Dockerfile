FROM ubuntu:trusty

ENV PORT 5000
ENV PATH /datagram/bin:$PATH

EXPOSE 5000

RUN apt-get update -q \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
  ruby ruby-dev ruby-bundler libmysqlclient-dev libsqlite3-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./Gemfile /datagram/Gemfile
ADD ./Gemfile.lock /datagram/Gemfile.lock

RUN bundle install \
  --without development test \
  --gemfile /datagram/Gemfile \
  --binstubs /usr/local/bin

ADD . /datagram

CMD thin start -R /datagram/config.ru -p $PORT

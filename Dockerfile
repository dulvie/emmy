FROM debian:jessie

ENV TERM=screen-256color

EXPOSE 3000 1080

# Install needed packages
RUN apt-get update && \
    apt-get install -y \
      git \
      curl \
      vim \
      openssl \
      build-essential \
      libssl-dev \
      zlib1g-dev \
      pkg-config

RUN apt-get install -y \
      libreadline-dev \
      libffi-dev \
      libxml2-dev \
      libpq-dev \
      sqlite3 \
      libsqlite3-dev \
      libqt4-dev \
      libqt4-core \
      libqt4-gui \
      nodejs \
      ruby \
      ruby-dev \
      qt4-dev-tools \
      xvfb \
      file \
      runit

# Install bundler and gems
COPY Gemfile Gemfile.lock /setup/
RUN cd /setup && \
    gem install bundler && \
    bundle install && \
    gem install --no-ri --no-rdoc mailcatcher && \
    rm -rf /setup/*

# The runit boot scripts is needed since /sbin/runit-init relies on them.
COPY docker/runit /etc/runit

# We always wants to run the mailcatcher service.
# Start it using runit /etc/service
COPY docker/mailcatcher /etc/service/mailcatcher


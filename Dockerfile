FROM dulvie/rubyweb
ENV APP_NAME=emmy
RUN apt-get update \
    && apt-get install -y \
      file \
      qt5-default \
      libqt5webkit5-dev \
      gstreamer1.0-plugins-base \
      gstreamer1.0-tools \
      gstreamer1.0-x

RUN gem update --system && \
    echo y | gem uninstall bundler && \
    gem install bundler
COPY docker/ /
COPY Gemfil* /tmp/
RUN /opt/bin/post-install

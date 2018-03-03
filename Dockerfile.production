FROM dulvie/ruby-node
ENV APP_NAME=emmy \
    PUBLIC_DIR=/shared/sites/emmy/public \
    RESTART_NOTIFY_FILE=/tmp/restart-emmy.inotify \
    RACK_ENV=production

#RUN apt-get update \
#    && apt-get install -y \
#      file \
#      qt5-default \
#      libqt5webkit5-dev \
#      gstreamer1.0-plugins-base \
#      gstreamer1.0-tools \
#      gstreamer1.0-x

COPY docker/ /
COPY Gemfil* /tmp/
RUN /opt/bin/post-install

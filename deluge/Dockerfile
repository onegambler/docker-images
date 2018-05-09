# Sets up a Deluge server and web client.

FROM resin/rpi-raspbian:stretch

# Install required packages.
RUN apt-get update; apt-get install wget python python-twisted python-openssl python-setuptools intltool python-xdg python-chardet geoip-database python-libtorrent python-notify python-pygame python-glade2 librsvg2-common xdg-utils python-mako -y

ARG PGID=1000
ARG PUID=1000

# Setup a user.
RUN addgroup --gid ${PGID} deluge 
RUN adduser --system --ingroup deluge --uid ${PUID} deluge 

# Clean up.
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Deluge version.
ARG DELUGE_VERSION=1.3.15

# Install Deluge.
WORKDIR /
RUN wget http://download.deluge-torrent.org/source/deluge-${DELUGE_VERSION}.tar.gz
RUN tar -zxvf deluge-${DELUGE_VERSION}.tar.gz
RUN rm deluge-${DELUGE_VERSION}.tar.gz
RUN cd deluge-${DELUGE_VERSION}; python setup.py build; python setup.py install

# Expose the deluge control port and the web UI port.
EXPOSE 58846 8112

# Setup volumes.
VOLUME /volumes/config
VOLUME /volumes/data
VOLUME /volumes/download
VOLUME /volumes/complete

# Add the setup script.
ADD setup.sh /setup.sh
ADD config /tmp/config
RUN chmod a+x /setup.sh

# Run the setup script on boot.
CMD ["/setup.sh"]
# Sets up a Deluge server and web client.

FROM resin/rpi-raspbian:stretch

# Install required packages.
RUN apt-get update && \ 
    apt-get install wget python python-twisted python-openssl python-setuptools intltool \
    python-xdg python-chardet geoip-database python-libtorrent python-notify python-pygame \
    python-glade2 librsvg2-common xdg-utils python-mako -y 

# Deluge version.
ARG DELUGE_VERSION=1.3.15

# Clean up.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Deluge.
WORKDIR /
RUN wget http://download.deluge-torrent.org/source/deluge-${DELUGE_VERSION}.tar.gz && tar -zxvf deluge-${DELUGE_VERSION}.tar.gz && rm deluge-${DELUGE_VERSION}.tar.gz && cd deluge-${DELUGE_VERSION}; python setup.py build; python setup.py install

# Expose the deluge control port and the web UI port.
EXPOSE 58846 8112 30000

# Setup volumes.
VOLUME /volumes/config
VOLUME /volumes/data
VOLUME /volumes/download
VOLUME /volumes/complete

# Add the setup script.
ADD run.sh /run.sh
ADD config /tmp/config
RUN chmod a+x /run.sh

# Run the setup script on boot.
CMD ["/run.sh"]
FROM resin/rpi-raspbian:stretch

RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y mldonkey-server && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/mldonkey && \
    rm /var/lib/mldonkey/*

ENV MLDONKEY_DIR /var/lib/mldonkey

VOLUME /var/lib/mldonkey
VOLUME /download/incomplete
VOLUME /download/complete

ARG PGID=1000
ARG PUID=1000

# Setup a user.
RUN usermod -u ${PUID} mldonkey
RUN groupmod -g ${PGID} mldonkey

EXPOSE 4000 4080 20562 20566/udp 16965/udp 3617/udp 6881 6882

COPY run.sh /run.sh
RUN chmod -v +x /run.sh
CMD /run.sh
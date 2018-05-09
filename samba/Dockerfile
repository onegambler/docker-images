FROM resin/rpi-raspbian:stretch

RUN apk update && apk upgrade && apk add bash samba-common-tools samba && rm -rf /var/cache/apk/*

COPY setup.sh /setup.sh
RUN chmod u+x /setup.sh

EXPOSE 445 137 138 139

ENTRYPOINT ["/setup.sh"]
CMD ["-h"]
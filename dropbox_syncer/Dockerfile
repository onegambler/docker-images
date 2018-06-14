FROM armhf/alpine

COPY dropbox_uploader.sh /bin/dropbox/dropbox_uploader.sh
COPY entry_point.sh /bin/dropbox/entry_point.sh
COPY dropbox.py /bin/dropbox/dropbox.py

COPY root /var/spool/cron/crontabs/root

RUN apk update && apk upgrade && \
    apk add python3 bash curl && \
    ln -sf `which python3` /usr/bin/python && \
    apk add --virtual=build-dependencies curl && \
    curl https://bootstrap.pypa.io/get-pip.py | python3 && \
    apk del build-dependencies && \
    rm -Rf /root/.cache && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /bin/dropbox && \
    dos2unix /bin/dropbox/dropbox_uploader.sh && \
    chmod +x /bin/dropbox/dropbox_uploader.sh && \
    dos2unix /bin/dropbox/entry_point.sh && \
    chmod +x /bin/dropbox/entry_point.sh

ENTRYPOINT ["/bin/dropbox/entry_point.sh"]
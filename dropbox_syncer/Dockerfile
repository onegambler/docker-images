FROM armhf/alpine

COPY . /bin/dropbox

COPY root /var/spool/cron/crontabs/root

RUN apk update && apk upgrade && \
    apk add python3 && \
    ln -sf `which python3` /usr/bin/python && \
    apk add --virtual=build-dependencies curl && \
    curl https://bootstrap.pypa.io/get-pip.py | python3 && \
    apk del build-dependencies && \
    rm -Rf /root/.cache && \
    rm -rf /var/cache/apk/* && \
    mkdir -p /bin/dropbox && \
    dos2unix /bin/dropbox/entry_point.sh && \
    chmod +x /bin/dropbox/entry_point.sh && \
    pip install -r /bin/dropbox/requirements.txt

ENTRYPOINT ["/bin/dropbox/entry_point.sh"]
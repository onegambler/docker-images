FROM armhf/alpine

COPY . /var/lib/dropbox

RUN apk update && apk upgrade && \
    apk add python3 && \
    ln -sf `which python3` /usr/bin/python && \
    python -m ensurepip --upgrade && \
    ln -sf `which pip3` /usr/bin/pip && \
    rm -Rf /root/.cache && \
    rm -rf /var/cache/apk/* && \
    chmod +x /var/lib/dropbox/syncer.py && \
    pip install -r /var/lib/dropbox/requirements.txt

CMD ["/var/lib/dropbox/syncer.py"]
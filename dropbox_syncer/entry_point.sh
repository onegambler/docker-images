#!/bin/sh

if [ ! -f /bin/dropbox/.dropbox_uploader ]; then
    echo "OAUTH_ACCESS_TOKEN=${ACCESS_TOKEN}" >> /bin/dropbox/.dropbox_uploader
fi

crond -l 2 -f

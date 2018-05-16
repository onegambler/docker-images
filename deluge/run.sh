#!/bin/bash

CONFIGDIR=/volumes/config
DATADIR=/volumes/data
DOWNLOAD_DIR=/volumes/download
COMPLETE_DIR=/volumes/complete

echo "Creating config and data directories."
mkdir -p -m 777 /volumes/{$CONFIGDIR,$DATADIR,$DOWNLOAD_DIR,$COMPLETE_DIR}
chown -R deluge /volumes

if [ ! -d $CONFIGDIR ]; then
        echo "The config directory does not exist! Please add it as a volume."
        exit 1
fi
if [ ! -d $DATADIR ]; then
        echo "The data directory does not exist! Please add it as a volume."
        exit 1
fi
if [ ! -d $DOWNLOAD_DIR ]; then
        echo "The download directory does not exist! Defaulting to data dir."
        $DOWNLOAD_DIR=$DATADIR
fi
if [ ! -d $COMPLETE_DIR ]; then
        echo "The complete directory does not exist! Defaulting to data dir."
        $COMPLETE_DIR=$DATADIR
fi

# Check if the authentication file exists.
if [ ! -f $CONFIGDIR/auth ]; then
        AUTHMISSING=true
fi

if [ $AUTHMISSING ]; then
        echo "Doing initial setup."
        # Starting deluge
        su -s /bin/bash deluge -c 'deluged -c /volumes/config'

        # Wait until auth file created.
        while [ ! -f $CONFIGDIR/auth ]; do
                sleep 1
        done

        # Stop deluged.
        pkill deluged

        #Add plugins
        cp -fr /tmp/config/* /volumes/config
        chown -R deluge:deluge /volumes/config

        echo "Adding initial authentication details."
        echo deluge:deluge:10 >>  $CONFIGDIR/auth

        # Starting deluge again
        su -s /bin/bash deluge -c 'deluged -c /volumes/config'

        # allow remote access
        deluge-console -c $CONFIGDIR "config -s allow_remote True"

        # setup default paths to go to the user's defined data folder.
        deluge-console -c $CONFIGDIR "config -s download_location $DOWNLOAD_DIR"
        deluge-console -c $CONFIGDIR "config -s torrentfiles_location $DATADIR"
        deluge-console -c $CONFIGDIR "config -s move_completed_path $COMPLETE_DIR"
        deluge-console -c $CONFIGDIR "config -s move_completed True∂"
        deluge-console -c $CONFIGDIR "config -s autoadd_location $DATADIR"
        deluge-console -c $CONFIGDIR "plugin --enable AutoRemovePlus"
        deluge-console -c $CONFIGDIR "plugin --enable Label"
        deluge-console "config --set listen_ports ($PORT $PORT)"
        deluge-console -c $CONFIGDIR "config -s listen_ports (30000, 30000)"
        
        # Stop deluged.
        pkill deluged
fi

echo "Starting deluged and deluge-web."
su -s /bin/bash deluge -c 'umask 002 && deluged -c /volumes/config'
su -s /bin/bash deluge -c 'umask 002 && deluge-web -c /volumes/config'
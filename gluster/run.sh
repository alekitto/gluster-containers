#!/bin/sh

HOST_DEV_DIR=${HOST_DEV_DIR:-/mnt/host-dev}
LOG_LEVEL=${LOG_LEVEL:-INFO}

if [ -c "${HOST_DEV_DIR}/zero" ] && [ -c "${HOST_DEV_DIR}/null" ]; then
    # looks like an alternate "host dev" has been provided
    # to the container. Use that as our /dev ongoing
    mount --rbind "${HOST_DEV_DIR}" /dev
fi

/sbin/glustereventsd &
/sbin/glusterd -N --log-file=- --log-level=$LOG_LEVEL $GLUSTERD_OPTIONS &

wait

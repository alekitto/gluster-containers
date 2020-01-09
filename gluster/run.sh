#!/bin/sh

LOG_LEVEL=${LOG_LEVEL:-INFO}

/sbin/glustereventsd &
/sbin/glusterd -N --log-file=- --log-level=$LOG_LEVEL $GLUSTERD_OPTIONS &

wait

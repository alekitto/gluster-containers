#!/bin/sh

HOST_DEV_DIR=${HOST_DEV_DIR:-/mnt/host-dev}
LOG_LEVEL=${LOG_LEVEL:-INFO}

if [ -c "${HOST_DEV_DIR}/zero" ] && [ -c "${HOST_DEV_DIR}/null" ]; then
    # looks like an alternate "host dev" has been provided
    # to the container. Use that as our /dev ongoing
    mount --rbind "${HOST_DEV_DIR}" /dev
fi

/lib/systemd/systemd-udevd & UDEVD_PID=$!

HEKETI_CUSTOM_FSTAB=${HEKETI_CUSTOM_FSTAB:-/var/lib/heketi/fstab}
if [ -f $HEKETI_CUSTOM_FSTAB ]; then
      pvscan
      vgscan
      lvscan
      vgchange -an

      pvscan
      vgscan
      lvscan
      vgchange -ay

      mount -a --fstab $HEKETI_CUSTOM_FSTAB
      sts=$?
      if [ $sts -eq 0 ]; then
            echo "Mount command Successful"
      fi
fi

/sbin/glustereventsd & EVENTS_PID=$!
/sbin/glusterd -N --log-file=- --log-level=$LOG_LEVEL $GLUSTERD_OPTIONS & GLUSTERD_PID=$!
/sbin/gluster-exporter & EXPORTER_PID=$!

(while true; do
  if ( pgrep systemd-udevd && pgrep glustereventsd && pgrep glusterd ) > /dev/null; then
    sleep 5
  else
    break
  fi
done)

kill $UDEVD_PID /dev/null 2>&1 ; kill $EVENTS_PID /dev/null 2>&1 ; kill $GLUSTERD_PID /dev/null 2>&1 ; kill $EXPORTER_PID /dev/null 2>&1 ;
sleep 10
kill -9 $UDEVD_PID /dev/null 2>&1 ; kill -9 $EVENTS_PID /dev/null 2>&1 ; kill -9 $GLUSTERD_PID /dev/null 2>&1 ; kill -9 $EXPORTER_PID /dev/null 2>&1 ;

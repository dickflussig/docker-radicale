#!/bin/sh

if [ -e storage/${LOCK_FILE} ]
then
    rm -f storage/${LOCK_FILE}
else
    flock --exclusive storage/.Radicale.lock /app/hold_lock.sh &
fi

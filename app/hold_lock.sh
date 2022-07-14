#!/bin/sh

touch storage/${LOCK_FILE}
while [ -e storage/${LOCK_FILE} ]; do sleep 1; done
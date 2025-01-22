#!/bin/sh
set -euo pipefail

: "${FLOCK_TIMEOUT:=10}"
: "${FLOCK_LOCKFILE:=/var/lock/s3-sync.lock}"
: "${SYNC_OPTIONS:=}"

args=("$@")

another_instance()
{
  echo "There is another instance running (${FLOCK_LOCKFILE}) and timedout after ${FLOCK_TIMEOUT}s, exiting"
  exit 1
}

s3Sync() {
  /usr/local/bin/aws s3 sync "$@"
}

echo "Starting sync with $@"

( flock --exclusive --wait $FLOCK_TIMEOUT 100 || another_instance; s3Sync ) 100>$FLOCK_LOCKFILE
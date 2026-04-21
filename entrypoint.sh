#!/bin/sh
set -e

# Set a default schedule, if the user didn't provide one
if [ -z "$CRON_SCHEDULE" ]; then
  export CRON_SCHEDULE='*/2 * * * *'
fi

if [ -z "$SYNC_CMD" ]; then
  export SYNC_CMD='move'
fi

if [ -z "$SYNC_OPTIONS" ]; then
  export SYNC_OPTIONS='--checksum --delete-empty-src-dirs --retries 10 --low-level-retries 20'
fi

echo "Updating cron schedule to $CRON_SCHEDULE"

# Run substitutions on the template file
envsubst < /app/crontab > /app/crontab.live

# Run the main container command
exec "$@"
